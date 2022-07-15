import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:signale/signale.dart';
import 'package:speed_share/app/controller/chat_controller.dart';
import 'package:speed_share/global/global.dart';
import 'package:speed_share/model/model.dart';
import 'package:speed_share/utils/http/http.dart';

class JoinUtil {
  static Future<void> sendJoinEvent(
    List<String> addrs,
    int shelfBindPort,
    int chatBindPort,
    String url,
  ) async {
    JoinMessage message = JoinMessage();
    message.deviceName = Global().deviceId;
    message.addrs = addrs;
    message.deviceType = type;
    message.filePort = shelfBindPort;
    message.messagePort = chatBindPort;
    try {
      Response res = await httpInstance.post('$url/', data: message.toJson());
    } on DioError catch (e) {
      Log.e(e);
    }
  }
}

List<String> _hasSendJoin = [];
Future<void> sendJoinEvent(String url) async {
  if (_hasSendJoin.contains(url)) {
    return;
  }
  _hasSendJoin.add(url);
  Log.i('sendJoinEvent : $url');
  ChatController controller = Get.find();
  await controller.initLock.future;
  JoinUtil.sendJoinEvent(
    controller.addrs,
    controller.shelfBindPort,
    controller.messageBindPort,
    url,
  );
}