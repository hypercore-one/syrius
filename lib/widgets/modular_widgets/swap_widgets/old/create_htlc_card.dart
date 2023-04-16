import 'dart:math';

import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:zenon_syrius_wallet_flutter/blocs/dashboard/balance_bloc.dart';
import 'package:zenon_syrius_wallet_flutter/blocs/htlc/create_htlc_bloc.dart';
import 'package:zenon_syrius_wallet_flutter/blocs/notifications_bloc.dart';
import 'package:zenon_syrius_wallet_flutter/main.dart';
import 'package:zenon_syrius_wallet_flutter/model/basic_dropdown_item.dart';
import 'package:zenon_syrius_wallet_flutter/model/database/notification_type.dart';
import 'package:zenon_syrius_wallet_flutter/model/database/wallet_notification.dart';
import 'package:zenon_syrius_wallet_flutter/utils/app_colors.dart';
import 'package:zenon_syrius_wallet_flutter/utils/clipboard_utils.dart';
import 'package:zenon_syrius_wallet_flutter/utils/constants.dart';
import 'package:zenon_syrius_wallet_flutter/utils/global.dart';
import 'package:zenon_syrius_wallet_flutter/utils/input_validators.dart';
import 'package:zenon_syrius_wallet_flutter/utils/notification_utils.dart';
import 'package:zenon_syrius_wallet_flutter/utils/zts_utils.dart';
import 'package:zenon_syrius_wallet_flutter/widgets/reusable_widgets/buttons/loading_button.dart';
import 'package:zenon_syrius_wallet_flutter/widgets/reusable_widgets/dialogs/swap_dialogs/old/deposit_dialog.dart';
import 'package:zenon_syrius_wallet_flutter/widgets/reusable_widgets/dropdown/addresses_dropdown.dart';
import 'package:zenon_syrius_wallet_flutter/widgets/reusable_widgets/dropdown/basic_dropdown.dart';
import 'package:zenon_syrius_wallet_flutter/widgets/reusable_widgets/error_widget.dart';
import 'package:zenon_syrius_wallet_flutter/widgets/reusable_widgets/input_field/amount_input_field.dart';
import 'package:zenon_syrius_wallet_flutter/widgets/reusable_widgets/input_field/input_field.dart';
import 'package:zenon_syrius_wallet_flutter/widgets/reusable_widgets/layout_scaffold/card_scaffold.dart';
import 'package:zenon_syrius_wallet_flutter/widgets/reusable_widgets/loading_widget.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

class SwapOptionsCard extends StatefulWidget {
  const SwapOptionsCard({
    Key? key,
  }) : super(key: key);

  @override
  State<SwapOptionsCard> createState() => _SwapOptionsCardState();
}

class _SwapOptionsCardState extends State<SwapOptionsCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<LoadingButtonState> _createAtomicSwapButtonKey = GlobalKey();

  final Duration _animationDuration = const Duration(milliseconds: 200);

  final List<BasicDropdownItem<int>> _lockDurationItems = [
    BasicDropdownItem(label: '3 hours', value: kOneHourInSeconds * 3),
    BasicDropdownItem(
        label: '12 hours (default)', value: kOneHourInSeconds * 12),
    BasicDropdownItem(label: '24 hours', value: kOneHourInSeconds * 24),
  ];

  final List<BasicDropdownItem<int>> _hashTypeItems = [
    BasicDropdownItem(label: 'SHA-3 (default)', value: htlcHashTypeSha3),
    BasicDropdownItem(label: 'SHA-256', value: htlcHashTypeSha256),
  ];

  late final AnimationController _animationController;

  TextEditingController _recipientController = TextEditingController();
  TextEditingController _amountController = TextEditingController();
  TextEditingController _hashlockController = TextEditingController();

  String? _selectedSelfAddress = kSelectedAddress;
  BasicDropdownItem<int>? _selectedLockDuration;
  BasicDropdownItem<int>? _selectedHashType;
  Token _selectedToken = kDualCoin.first;
  bool _isAmountValid = false;
  bool _isAdvancedOptionsExpanded = false;

  @override
  void initState() {
    super.initState();
    sl.get<BalanceBloc>().getBalanceForAllAddresses();
    _animationController = AnimationController(
      duration: _animationDuration,
      vsync: this,
    );
  }

  //TODO: Confirm CardScaffold description
  @override
  Widget build(BuildContext context) {
    return CardScaffold(
      title: '  Create HTLC',
      description: 'update this text',
      childBuilder: () => _getWidgetBody(context),
    );
  }

  Widget _getWidgetBody(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20.0),
      child: ListView(
        children: [
          _getMandatoryInputFields(),
          kVerticalSpacing,
          _getAdvancedOptions(),
          kVerticalSpacing,
          _getCreateAtomicSwapViewModel(),
        ],
      ),
    );
  }

  Column _getMandatoryInputFields() {
    return Column(
      children: [
        AddressesDropdown(
          _selectedSelfAddress,
          (address) => setState(() {
            _selectedSelfAddress = address;
            sl.get<BalanceBloc>().getBalanceForAllAddresses();
          }),
        ),
        kVerticalSpacing,
        InputField(
          onChanged: (value) {
            setState(() {});
          },
          validator: (value) => InputValidators.checkAddress(value),
          controller: _recipientController,
          suffixIcon: RawMaterialButton(
            child: const Icon(
              Icons.content_paste,
              color: AppColors.darkHintTextColor,
              size: 15.0,
            ),
            shape: const CircleBorder(),
            onPressed: () {
              ClipboardUtils.pasteToClipboard(context, (String value) {
                _recipientController.text = value;
                setState(() {});
              });
            },
          ),
          suffixIconConstraints: const BoxConstraints(
            maxWidth: 45.0,
            maxHeight: 20.0,
          ),
          hintText: 'Recipient address',
        ),
        kVerticalSpacing,
        StreamBuilder<Map<String, AccountInfo>?>(
          stream: sl.get<BalanceBloc>().stream,
          builder: (_, snapshot) {
            if (snapshot.hasData) {
              return AmountInputField(
                controller: _amountController,
                accountInfo: (snapshot.data![_selectedSelfAddress]!),
                valuePadding: 20.0,
                textColor: Theme.of(context).colorScheme.inverseSurface,
                initialToken: _selectedToken,
                onChanged: (token, isValid) {
                  setState(() {
                    _selectedToken = token;
                    _isAmountValid = isValid;
                  });
                },
              );
            }
            if (snapshot.hasError) {
              return SyriusErrorWidget(snapshot.error!);
            }
            return const SyriusLoadingWidget();
          },
        ),
      ],
    );
  }

  Widget _getAdvancedOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(4),
          hoverColor: Colors.transparent,
          onTap: () {
            setState(() {
              _isAdvancedOptionsExpanded = !_isAdvancedOptionsExpanded;
              _isAdvancedOptionsExpanded
                  ? _animationController.forward()
                  : _animationController.reverse();
            });
          },
          child: SizedBox(
            height: 30.0,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Advanced options',
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                const SizedBox(
                  width: 3.0,
                ),
                RotationTransition(
                  turns:
                      Tween(begin: 0.0, end: 0.5).animate(_animationController),
                  child: const Icon(Icons.keyboard_arrow_down, size: 18.0),
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: _animationDuration,
          curve: Curves.easeInOut,
          child: Visibility(
            visible: _isAdvancedOptionsExpanded,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                kVerticalSpacing,
                BasicDropdown<int>(
                  'Lock duration',
                  _selectedLockDuration,
                  _lockDurationItems,
                  (duration) => setState(() {
                    if (duration != null) {
                      _selectedLockDuration = duration;
                    }
                  }),
                ),
                kVerticalSpacing,
                BasicDropdown<int>(
                  'Hash type',
                  _selectedHashType,
                  _hashTypeItems,
                  (hashType) => setState(() {
                    if (hashType != null) {
                      _selectedHashType = hashType;
                    }
                  }),
                ),
                kVerticalSpacing,
                InputField(
                  onChanged: (value) {
                    setState(() {});
                  },
                  validator: (value) => InputValidators.checkHash(value),
                  controller: _hashlockController,
                  suffixIcon: RawMaterialButton(
                    child: const Icon(
                      Icons.content_paste,
                      color: AppColors.darkHintTextColor,
                      size: 15.0,
                    ),
                    shape: const CircleBorder(),
                    onPressed: () {
                      ClipboardUtils.pasteToClipboard(context, (String value) {
                        _recipientController.text = value;
                        setState(() {});
                      });
                    },
                  ),
                  suffixIconConstraints: const BoxConstraints(
                    maxWidth: 45.0,
                    maxHeight: 20.0,
                  ),
                  hintText: 'Pre-existing hashlock',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  _getCreateAtomicSwapViewModel() {
    return ViewModelBuilder<CreateHtlcBloc>.reactive(
      onModelReady: (model) {
        model.stream.listen(
          (event) {
            if (event is AccountBlockTemplate) {
              _sendConfirmationNotification();
              setState(() {
                _createAtomicSwapButtonKey.currentState?.animateReverse();
                _recipientController = TextEditingController();
                _amountController = TextEditingController();
                _hashlockController = TextEditingController();
                _selectedLockDuration = null;
                _selectedHashType = null;
              });
            }
          },
          onError: (error) {
            //TODO: remove pending swap
            //Example: create a swap with a net id that doesn't match the node
            _sendErrorNotification(error);
            _createAtomicSwapButtonKey.currentState?.animateReverse();
          },
        );
      },
      builder: (_, model, __) => _getCreateAtomicSwapButton(model),
      viewModelBuilder: () => CreateHtlcBloc(),
    );
  }

  Widget _getCreateAtomicSwapButton(CreateHtlcBloc model) {
    return LoadingButton.stepper(
      onPressed: _isInputValid() ? () => _onCreateButtonPressed(model) : null,
      text: 'Create HTLC',
      key: _createAtomicSwapButtonKey,
    );
  }

  void _onCreateButtonPressed(CreateHtlcBloc model) async {
    late final Hash hashLock;
    List<int>? preimage;

    if (_hashlockController.text.isEmpty) {
      preimage = _generatePreimage();
      hashLock =
          (_selectedHashType?.value ?? htlcHashTypeSha3) == htlcHashTypeSha3
              ? Hash.digest(preimage)
              : Hash.fromBytes(await Crypto.sha256Bytes(preimage));
    } else {
      hashLock = Hash.parse(_hashlockController.text);
    }

    final newHtlc = HtlcInfo(
        id: Hash.parse('0' * Hash.length * 2),
        timeLocked: Address.parse(_selectedSelfAddress!),
        hashLocked: Address.parse(_recipientController.text),
        tokenStandard: _selectedToken.tokenStandard,
        amount: _amountController.text
            .toNum()
            .extractDecimals(_selectedToken.decimals),
        expirationTime: await _getExpirationTime(),
        hashType: _selectedHashType?.value ?? 0,
        keyMaxSize: 255,
        hashLock: hashLock.getBytes()!);

    final TextEditingController _secretController = TextEditingController();
    final GlobalKey<FormState> _secretKey = GlobalKey();

    showDepositDialog(
      context: context,
      title: 'Create HTLC',
      htlc: newHtlc,
      token: _selectedToken,
      controller: _secretController,
      key: _secretKey,
      preimage: preimage,
      onCreateButtonPressed: () {
        _createAtomicSwapButtonKey.currentState?.animateForward();
        /* sl.get<P2pSwapsWorker>().addPendingSwap(
              htlc: newHtlc,
              preimage: preimage,
            ); */
        model.createHtlc(
          timeLocked: newHtlc.timeLocked,
          token: _selectedToken,
          amount: _amountController.text,
          hashLocked: newHtlc.hashLocked,
          expirationTime: newHtlc.expirationTime,
          hashType: newHtlc.hashType,
          keyMaxSize: newHtlc.keyMaxSize,
          hashLock: newHtlc.hashLock,
        );
        Navigator.pop(context);
      },
    );
  }

  List<int> _generatePreimage([int length = htlcPreimageDefaultLength]) {
    const maxInt = 256;
    return List<int>.generate(length, (i) => Random.secure().nextInt(maxInt));
  }

  Future<int> _getExpirationTime() async {
    final currentTime = (await zenon!.ledger.getFrontierMomentum()).timestamp;
    const defaultDuration = kOneHourInSeconds * 12;
    return _selectedLockDuration != null
        ? _selectedLockDuration!.value + currentTime
        : defaultDuration + currentTime;
  }

  bool _isInputValid() =>
      _isAmountValid &&
      InputValidators.checkAddress(_recipientController.text) == null &&
      (_hashlockController.text.isEmpty ||
          (_hashlockController.text.isNotEmpty &&
              InputValidators.checkHash(_hashlockController.text) == null));

  void _sendConfirmationNotification() {
    sl.get<NotificationsBloc>().addNotification(
          WalletNotification(
            title: 'Sent ${_amountController.text} ${_selectedToken.symbol} '
                'to $htlcAddress',
            timestamp: DateTime.now().millisecondsSinceEpoch,
            details: 'Sent ${_amountController.text} ${_selectedToken.symbol} '
                'from $_selectedSelfAddress to $htlcAddress',
            type: NotificationType.paymentSent,
            id: null,
          ),
        );
  }

  void _sendErrorNotification(error) {
    NotificationUtils.sendNotificationError(
      error,
      'Couldn\'t send ${_amountController.text} ${_selectedToken.symbol} '
      'to $htlcAddress',
    );
  }

  @override
  void dispose() {
    _recipientController.dispose();
    _amountController.dispose();
    _hashlockController.dispose();
    super.dispose();
  }
}
