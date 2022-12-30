import 'package:zenon_syrius_wallet_flutter/blocs/blocs.dart';
import 'package:zenon_syrius_wallet_flutter/main.dart';
import 'package:zenon_syrius_wallet_flutter/utils/constants.dart';
import 'package:zenon_syrius_wallet_flutter/utils/global.dart';
import 'package:zenon_syrius_wallet_flutter/utils/keystore_utils.dart';
import 'package:zenon_syrius_wallet_flutter/utils/widget_utils.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

class HideWidgetStatusBloc extends BaseBloc<bool?> {
  Future<void> checkPassAndMarkWidgetWithHiddenValue(
    String widgetTitle,
    String password,
    bool isHidden,
  ) async {
    try {
      addEvent(null);
      if (!isHidden) {
        await KeyStoreUtils.decryptKeyStoreFile(kKeyStorePath!, password);
      }
      await _markWidgetAsHidden(widgetTitle, isHidden);
      addEvent(isHidden);
    } on IncorrectPasswordException {
      addError(kIncorrectPasswordNotificationTitle);
    } catch (e) {
      addError(e);
    }
  }

  Future<void> _markWidgetAsHidden(String widgetTitle, bool isHidden) async {
    await sharedPrefsService!.put(
      WidgetUtils.isWidgetHiddenKey(widgetTitle),
      isHidden,
    );
  }
}
