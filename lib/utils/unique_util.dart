import 'dart:io';

import 'package:get/utils.dart';
import 'package:global_repository/global_repository.dart';

class UniqueUtil {
  UniqueUtil._();
  static String devicesId;
  static Future<String> getDevicesId() async {
    if (devicesId != null) {
      return devicesId;
    }
    if (GetPlatform.isWeb) {
      return 'web';
    } else if (GetPlatform.isDesktop) {
      return Platform.operatingSystem;
    } else {
      props ??= await YanProcess().exec('getprop');
      // print(props);
      // print(getValueFromProps('ro.product.model'));
      return devicesId = getValueFromProps('ro.product.model');
    }
  }

  static String props;
  static String getValueFromProps(String key) {
    final List<String> tmp = props.split('\n');
    for (final String line in tmp) {
      if (line.contains(key)) {
        return line.replaceAll(RegExp('.*\\]: |\\[|\\]'), '');
      }
    }
    return '';
    // print(key);
  }
}