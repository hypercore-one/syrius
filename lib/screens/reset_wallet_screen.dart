import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:zenon_syrius_wallet_flutter/screens/screens.dart';
import 'package:zenon_syrius_wallet_flutter/utils/utils.dart';
import 'package:zenon_syrius_wallet_flutter/widgets/widgets.dart';

class ResetWalletScreen extends StatefulWidget {
  const ResetWalletScreen({Key? key}) : super(key: key);

  @override
  State<ResetWalletScreen> createState() => _ResetWalletScreenState();
}

class _ResetWalletScreenState extends State<ResetWalletScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.only(
                    bottom: 10.0,
                  ),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      width: 4.0,
                      color: AppColors.errorColor,
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Icon(
                      Feather.alert_triangle,
                      color: AppColors.errorColor,
                      size: 50.0,
                    ),
                  ),
                ),
                kVerticalSpacing,
                Text(
                  'Reset wallet',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                kVerticalSpacing,
                SizedBox(
                  width: 500.0,
                  child: Text(
                    'All your wallet data will be erased permanently. Make sure '
                    'you have a backup of your mnemonic or Seed Vault & Seed Vault Key before you proceed '
                    'with erasing the wallet',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              MyOutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                outlineColor: Colors.white,
                text: 'Cancel',
                minimumSize: const Size(100.0, 40.0),
              ),
              const SizedBox(
                width: 20.0,
              ),
              MyOutlinedButton(
                outlineColor: AppColors.errorColor,
                onPressed: _onResetPressed,
                text: 'Reset',
                textColor: AppColors.errorColor,
                minimumSize: const Size(100.0, 40.0),
              )
            ],
          ),
          const SizedBox(
            height: 30.0,
          ),
        ],
      ),
    );
  }

  void _onResetPressed() async {
    NodeUtils.closeEmbeddedNode();

    kLastDismissedNotification = kLastNotification;

    Navigator.pop(context);

    NavigationUtils.pushReplacement(
      context,
      const SplashScreen(
        resetWalletFlow: true,
      ),
    );
  }
}
