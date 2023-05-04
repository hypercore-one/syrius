import 'dart:async';
import 'dart:math';

import 'package:zenon_syrius_wallet_flutter/blocs/auto_unlock_htlc_worker.dart';
import 'package:zenon_syrius_wallet_flutter/main.dart';
import 'package:zenon_syrius_wallet_flutter/model/block_data.dart';
import 'package:zenon_syrius_wallet_flutter/model/p2p_swap/htlc_swap.dart';
import 'package:zenon_syrius_wallet_flutter/model/p2p_swap/p2p_swap.dart';
import 'package:zenon_syrius_wallet_flutter/utils/account_block_utils.dart';
import 'package:zenon_syrius_wallet_flutter/utils/format_utils.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

class HtlcSwapsHandler {
  static HtlcSwapsHandler? _instance;

  static HtlcSwapsHandler getInstance() {
    _instance ??= HtlcSwapsHandler();
    return _instance!;
  }

  Future<void> runPeriodically() async {
    final unresolvedSwaps = htlcSwapsService!.getSwapsByState(
        [P2pSwapState.pending, P2pSwapState.active, P2pSwapState.reclaimable]);
    if (unresolvedSwaps.isNotEmpty) {
      if (await _areThereNewHtlcBlocks()) {
        final newBlocks = await _getNewHtlcBlocks(unresolvedSwaps);
        await _goThroughHtlcBlocks(newBlocks);
      }
      await _checkForExpiredSwaps();
      _checkForAutoUnlockableSwaps();
    }
    sl<AutoUnlockHtlcWorker>().autoUnlock();

    Future.delayed(const Duration(seconds: 5), () async {
      runPeriodically();
    });
  }

  Future<int?> _getHtlcFrontierHeight() async {
    final frontier = await zenon!.ledger.getFrontierAccountBlock(htlcAddress);
    return frontier?.height;
  }

  Future<bool> _areThereNewHtlcBlocks() async {
    final frontier = await _getHtlcFrontierHeight();
    return frontier != null &&
        frontier > htlcSwapsService!.getLastCheckedHtlcBlockHeight();
  }

  Future<List<AccountBlock>> _getNewHtlcBlocks(List<HtlcSwap> swaps) async {
    final lastCheckedHeight = htlcSwapsService!.getLastCheckedHtlcBlockHeight();
    final oldestSwapStartTime = _getOldestSwapStartTime(swaps) ?? 0;
    int lastCheckedBlockTime = 0;

    if (lastCheckedHeight > 0) {
      lastCheckedBlockTime = (await AccountBlockUtils.getTimeForBlockHeight(
              htlcAddress, lastCheckedHeight)) ??
          lastCheckedBlockTime;
    }

    return AccountBlockUtils.getBlocksAfterTime(
        htlcAddress, max(oldestSwapStartTime, lastCheckedBlockTime));
  }

  Future<void> _goThroughHtlcBlocks(List<AccountBlock> blocks) async {
    for (final block in blocks) {
      await _extractSwapDataFromBlock(block);

      // TODO: Take into use. Not used for now to make debugging easier.
      // htlcSwapsService!.storeLastCheckedHtlcBlockHeight(block.height);
    }
  }

  Future<void> _extractSwapDataFromBlock(AccountBlock htlcBlock) async {
    if (htlcBlock.blockType != BlockTypeEnum.contractReceive.index) {
      return;
    }

    final pairedBlock = htlcBlock.pairedAccountBlock!;
    final blockData = AccountBlockUtils.getDecodedBlockData(
        Definitions.htlc, pairedBlock.data);

    if (blockData == null) {
      return;
    }

    final swap = _tryGetSwapFromBlockData(blockData);
    if (swap == null) {
      return;
    }

    if (swap.chainId != pairedBlock.chainIdentifier) {
      return;
    }

    switch (blockData.function) {
      case 'Create':
        if (swap.state == P2pSwapState.pending) {
          swap.state = P2pSwapState.active;
          await htlcSwapsService!.storeSwap(swap);
        } else if (swap.state == P2pSwapState.active &&
            pairedBlock.hash.toString() != swap.initialHtlcId &&
            swap.counterHtlcId == null) {
          if (!_isValidCounterHtlc(pairedBlock, blockData, swap)) {
            return;
          }
          swap.counterHtlcId = pairedBlock.hash.toString();
          swap.toAmount = pairedBlock.amount;
          swap.toTokenStandard = pairedBlock.token!.tokenStandard.toString();
          swap.toDecimals = pairedBlock.token!.decimals;
          swap.toSymbol = pairedBlock.token!.symbol;
          swap.counterHtlcExpirationTime =
              blockData.params['expirationTime'].toInt();
          await htlcSwapsService!.storeSwap(swap);
        }
        return;
      case 'Unlock':
        if (swap.preimage == null) {
          if (!blockData.params.containsKey('preimage')) {
            return;
          }
          swap.preimage =
              FormatUtils.encodeHexString(blockData.params['preimage']);
          await htlcSwapsService!.storeSwap(swap);
        }

        if (swap.direction == P2pSwapDirection.incoming &&
            blockData.params['id'].toString() == swap.initialHtlcId) {
          swap.state = P2pSwapState.completed;
          await htlcSwapsService!.storeSwap(swap);
        }

        // Handle the situation where the counter HTLC of an outgoing swap
        // has been unlocked by someone else.
        if (swap.direction == P2pSwapDirection.outgoing &&
            swap.state == P2pSwapState.active &&
            blockData.params['id'].toString() == swap.counterHtlcId) {
          swap.state = P2pSwapState.completed;
          await htlcSwapsService!.storeSwap(swap);
        }
        return;
      case 'Reclaim':
        bool isSelfReclaim = false;
        if (swap.direction == P2pSwapDirection.outgoing &&
            blockData.params['id'].toString() == swap.initialHtlcId) {
          isSelfReclaim = true;
        } else if (swap.direction == P2pSwapDirection.incoming &&
            blockData.params['id'].toString() == swap.counterHtlcId) {
          isSelfReclaim = true;
        }
        if (isSelfReclaim) {
          swap.state = P2pSwapState.unsuccessful;
          await htlcSwapsService!.storeSwap(swap);
        }
        return;
    }
  }

  HtlcSwap? _tryGetSwapFromBlockData(BlockData data) {
    HtlcSwap? swap;
    if (data.params.containsKey('id')) {
      swap = htlcSwapsService!.getSwapByHtlcId(data.params['id'].toString());
    }
    if (data.params.containsKey('hashLock') && swap == null) {
      swap = htlcSwapsService!.getSwapByHashLock(
          Hash.fromBytes(data.params['hashLock']).toString());
    }
    return swap;
  }

  bool _isValidCounterHtlc(AccountBlock block, BlockData data, HtlcSwap swap) {
    // Verify that the recipient is the initiator's address
    if (!data.params.containsKey('hashLocked') ||
        data.params['hashLocked'] != Address.parse(swap.selfAddress)) {
      return false;
    }

    // Verify that the creator is the counterparty.
    if (block.address != Address.parse(swap.counterpartyAddress)) {
      return false;
    }

    // Verify that the hash types match.
    if (!data.params.containsKey('hashType') ||
        data.params['hashType'].toInt() != swap.hashType) {
      return false;
    }

    // Verify that block data contains an expiration time parameter.
    if (!data.params.containsKey('expirationTime')) {
      return false;
    }

    return true;
  }

  Future<void> _checkForExpiredSwaps() async {
    final swaps = htlcSwapsService!
        .getSwapsByState([P2pSwapState.pending, P2pSwapState.active]);
    final now = DateTime.now().millisecondsSinceEpoch / 1000;
    for (final swap in swaps) {
      if (swap.initialHtlcExpirationTime < now ||
          (swap.counterHtlcExpirationTime != null &&
              swap.counterHtlcExpirationTime! < now)) {
        swap.state = P2pSwapState.reclaimable;
        await htlcSwapsService!.storeSwap(swap);
      }
    }
  }

  void _checkForAutoUnlockableSwaps() {
    // It is important to check swaps that are in reclaimable state as well,
    // since the counterparty may have published the preimage at the last moment
    // before the HTLC would have expired. In this situation the swap's state
    // may have already been changed to reclaimable.
    final swaps = htlcSwapsService!
        .getSwapsByState([P2pSwapState.active, P2pSwapState.reclaimable]);
    for (final swap in swaps) {
      if (swap.direction == P2pSwapDirection.incoming &&
          swap.preimage != null) {
        sl<AutoUnlockHtlcWorker>().addHash(Hash.parse(swap.initialHtlcId));
      }
    }
  }

  int? _getOldestSwapStartTime(List<HtlcSwap> swaps) {
    return swaps.isNotEmpty
        ? swaps
            .reduce((e1, e2) => e1.startTime > e2.startTime ? e1 : e2)
            .startTime
        : null;
  }
}
