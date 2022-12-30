import 'package:flutter/material.dart';
import 'package:zenon_syrius_wallet_flutter/screens/screens.dart';
import 'package:zenon_syrius_wallet_flutter/utils/utils.dart';
import 'package:zenon_syrius_wallet_flutter/widgets/reusable_widgets/buttons/onboarding_button.dart';
import 'package:zenon_syrius_wallet_flutter/widgets/reusable_widgets/dotted_border_info_widget.dart';
import 'package:zenon_syrius_wallet_flutter/widgets/reusable_widgets/input_field/password_input_field.dart';
import 'package:zenon_syrius_wallet_flutter/widgets/reusable_widgets/progress_bars.dart';

class NewWalletPasswordScreen extends StatefulWidget {
  final List<String> seedWords;

  const NewWalletPasswordScreen(this.seedWords, {Key? key}) : super(key: key);

  @override
  _NewWalletPasswordScreenState createState() =>
      _NewWalletPasswordScreenState();
}

class _NewWalletPasswordScreenState extends State<NewWalletPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final GlobalKey<FormState> _passwordKey = GlobalKey();
  final GlobalKey<FormState> _confirmPasswordKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 30.0,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              children: [
                const ProgressBar(
                  currentLevel: 3,
                ),
                const SizedBox(
                  height: 30.0,
                ),
                Text('Create a wallet password',
                    style: Theme.of(context).textTheme.headline1),
                kVerticalSpacing,
                Text(
                    'This is the password that will be required to unlock the wallet',
                    style: Theme.of(context).textTheme.headline4),
                const SizedBox(
                  height: 65.0,
                ),
                Column(
                  children: [
                    Form(
                      key: _passwordKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: PasswordInputField(
                        controller: _passwordController,
                        validator: InputValidators.validatePassword,
                        onChanged: (value) {
                          setState(() {});
                        },
                        hintText: 'Password',
                      ),
                    ),
                    kVerticalSpacing,
                    Form(
                      key: _confirmPasswordKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: PasswordInputField(
                        controller: _confirmPasswordController,
                        validator: (value) =>
                            InputValidators.checkPasswordMatch(
                                _passwordController.text, value),
                        onChanged: (value) {
                          setState(() {});
                        },
                        hintText: 'Confirm password',
                      ),
                    ),
                    const SizedBox(
                      height: 35.0,
                    ),
                    PasswordProgressBar(
                      password: _passwordController.text,
                      passwordKey: _passwordKey,
                    ),
                  ],
                ),
              ],
            ),
            const DottedBorderInfoWidget(
              text: 'Use a password that has at least 8 characters, one '
                  'number, one uppercase letter, one lowercase letter and '
                  'one symbol',
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _getPassiveButton(),
                kSpacingBetweenActionButtons,
                _getActionButton()
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _getActionButton() {
    return OnboardingButton(
      onPressed: _arePasswordsValid()
          ? () {
              NavigationUtils.push(
                context,
                CreateKeyStoreScreen(
                  widget.seedWords.join(' '),
                  _passwordController.text,
                ),
              );
            }
          : null,
      text: 'Confirm password',
    );
  }

  Widget _getPassiveButton() {
    return OnboardingButton(
      onPressed: () {
        Navigator.pop(context, false);
      },
      text: 'Go back',
    );
  }

  bool _arePasswordsValid() {
    return InputValidators.validatePassword(_passwordController.text) == null &&
        InputValidators.checkPasswordMatch(
              _passwordController.text,
              _confirmPasswordController.text,
            ) ==
            null;
  }

  @override
  void dispose() {
    _confirmPasswordController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
