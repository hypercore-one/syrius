import 'package:convert/convert.dart';
import 'package:zenon_syrius_wallet_flutter/blocs/base_bloc.dart';
import 'package:zenon_syrius_wallet_flutter/main.dart';
import 'package:zenon_syrius_wallet_flutter/utils/account_block_utils.dart';
import 'package:zenon_syrius_wallet_flutter/utils/address_utils.dart';
import 'package:zenon_syrius_wallet_flutter/utils/global.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

class UnlockHtlcBloc extends BaseBloc<AccountBlockTemplate?> {
  void unlockHtlc({
    required Hash id,
    required String preimage,
    required String hashLocked,
  }) {
    try {
      addEvent(null);
      AccountBlockTemplate transactionParams =
          zenon!.embedded.htlc.unlock(id, hex.decode(preimage));
      KeyPair blockSigningKeyPair = kKeyStore!.getKeyPair(
        kDefaultAddressList.indexOf(hashLocked),
      );
      AccountBlockUtils.createAccountBlock(transactionParams, 'unlock swap',
              blockSigningKey: blockSigningKeyPair, waitForRequiredPlasma: true)
          .then(
        (response) {
          AddressUtils.refreshBalance();
          addEvent(response);
        },
      ).onError(
        (error, stackTrace) {
          addError(error.toString());
        },
      );
    } catch (e) {
      addError(e);
    }
  }
}
