import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:global_repository/global_repository.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:speed_share/config/candy_colors.dart';
import 'package:speed_share/config/dimens.dart';
import 'package:speed_share/utils/file_manager_server.dart';
import 'package:speed_share/utils/server.dart';
import 'package:speed_share/utils/shelf_static.dart';
import 'package:speed_share/utils/toast.dart';
import 'package:supercharged/supercharged.dart';
import 'package:speed_share/main.dart';

import 'setting_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool serverOpend = false;
  String content = '';
  List<String> addreses = [];
  @override
  void initState() {
    super.initState();
    request();
  }

  Future<void> request() async {
    final Permission permission = Permission.storage;
    // bool isShown =
    //     await Permission.contacts.shouldShowRequestRationale;
    if (Platform.isAndroid) {
      final PermissionStatus status = await permission.request();
      print(status);
    }
    addreses = await PlatformUtil.localAddress();

    setState(() {});
  }

  Widget addressItem(String uri) {
    return InkWell(
      onTap: () async {
        await Clipboard.setData(ClipboardData(
          text: uri,
        ));
        content = uri;
        setState(() {});
        showToast('已复制到剪切板');
      },
      child: SizedBox(
        height: Dimens.gap_dp48,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Dimens.gap_dp8,
          ),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.deepPurple,
                ),
                height: Dimens.gap_dp8,
                width: Dimens.gap_dp8,
              ),
              SizedBox(width: Dimens.gap_dp16),
              Text(uri),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('速享'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              NiNavigator.of(context).push<void>(SettingPage());
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          QrImage(
            data: content,
            version: QrVersions.auto,
            size: 300.0,
          ),
          Column(
            children: [
              Text(
                '局域网的设备使用浏览器打开以下链接即可浏览本机文件，点击可复制链接和更新二维码',
                style: Theme.of(context).textTheme.subtitle1,
              ),
              Builder(builder: (_) {
                List<Widget> list = [];
                for (String address in addreses) {
                  if (address.startsWith('192')) {
                    String uri = 'http://$address:8001';
                    list.add(addressItem(uri));
                    uri = 'http://$address:8002';
                    list.add(addressItem(uri));
                  }
                }
                return Column(
                  children: list,
                );
              })
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Dimens.gap_dp8,
            ),
            child: Material(
              color: Color(0xfff0f0f0),
              borderRadius: BorderRadius.circular(Dimens.gap_dp12),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: Dimens.gap_dp4,
                          height: Dimens.gap_dp24,
                          color: CandyColors.candyPink,
                        ),
                        SizedBox(
                          width: Dimens.gap_dp8,
                        ),
                        Expanded(
                          child: Text(
                            '8001端口可提供断点续传，可在线浏览视频，但对于内存较大(大于2GB)文件的下载与视频播放会存在内存占用过高的问题',
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                        ),
                      ],
                    ),
                    Divider(
                      color: Colors.grey,
                      height: 1.0,
                    ),
                    Row(
                      children: [
                        Container(
                          width: Dimens.gap_dp4,
                          height: Dimens.gap_dp24,
                          color: CandyColors.candyPink,
                        ),
                        SizedBox(
                          width: Dimens.gap_dp8,
                        ),
                        Expanded(
                          child: Text(
                            '8002端口对于视频的在线非常不友好，但大文件的下载内存正常',
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: serverOpend
                ? LoginButton(
                    title: '关闭服务',
                    backgroundColor: Colors.grey,
                    onTap: () async {
                      await Future<void>.delayed(Duration(milliseconds: 300));
                      ServerUtil.close();
                      FileManagerServer.close();
                      ShelfStatic.close();
                      serverOpend = false;
                      setState(() {});
                      return true;
                    },
                  )
                : LoginButton(
                    backgroundColor: Theme.of(context).accentColor,
                    title: '开启服务',
                    onTap: () async {
                      await Future<void>.delayed(Duration(milliseconds: 300));
                      ServerUtil.start();
                      FileManagerServer.start();
                      ShelfStatic.start();
                      serverOpend = true;
                      setState(() {});
                      return true;
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class AddressItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class LoginButton extends StatefulWidget {
  const LoginButton({
    Key key,
    this.onTap,
    this.title,
    this.backgroundColor,
  }) : super(key: key);
  final Future<bool> Function() onTap;
  final String title;
  final Color backgroundColor;

  @override
  _LoginButtonState createState() => _LoginButtonState();
}

class _LoginButtonState extends State<LoginButton> with AnimationMixin {
  bool successExec = false;
  CustomAnimationControl tapControl = CustomAnimationControl.STOP;
  CustomAnimationControl execControl = CustomAnimationControl.STOP;
  final _tween = TimelineTween<String>()
    ..addScene(begin: 0.milliseconds, end: 300.milliseconds).animate(
      'width',
      tween: Dimens.setWidth(300).tweenTo(Dimens.setWidth(36)),
    )
    ..addScene(begin: 0.milliseconds, end: 300.milliseconds).animate(
      'radius',
      tween: Dimens.setWidth(8).tweenTo(Dimens.setWidth(18)),
    )
    ..addScene(begin: 0.milliseconds, end: 300.milliseconds).animate(
      'fontsize',
      tween: Dimens.font_sp14.tweenTo(Dimens.setWidth(0)),
    )
    ..addScene(begin: 300.milliseconds, end: 600.milliseconds).animate(
      'opacity',
      tween: 0.0.tweenTo(1.0),
    );
  // ..addScene(begin: 0.milliseconds, end: 3000.milliseconds).animate(
  //   "width",
  //   tween: 300.0.tweenTo(36.0),
  // );
  @override
  Widget build(BuildContext context) {
    return CustomAnimation<double>(
      control: tapControl,
      tween: 0.0.tweenTo(1.0), // Pass in tween
      duration: const Duration(milliseconds: 200), // Obtain duration
      builder: (context, child, tapValue) {
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () async {
            tapControl = CustomAnimationControl.PLAY_REVERSE;
            execControl = CustomAnimationControl.PLAY;
            setState(() {});
            successExec = await widget.onTap();
            successExec = true;
            // if (!successExec) {
            execControl = CustomAnimationControl.PLAY_REVERSE;
            // }
            setState(() {});
            Feedback.forLongPress(context);
          },
          onTapDown: (_) {
            tapControl = CustomAnimationControl.PLAY;
            Feedback.forLongPress(context);
            setState(() {});
          },
          onTapCancel: () {
            tapControl = CustomAnimationControl.PLAY_REVERSE;
            Feedback.forLongPress(context);
            setState(() {});
          },
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()..scale(1.0 - tapValue * 0.05),
            child: CustomAnimation<TimelineValue<String>>(
              control: execControl,
              tween: _tween, // Pass in tween
              duration: _tween.duration, // Obtain duration
              builder: (context, child, value) {
                return Container(
                  margin: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: widget.backgroundColor,
                    borderRadius: BorderRadius.all(
                      Radius.circular(value.get('radius')),
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.black.withOpacity(
                          0.04 - tapValue * 0.04,
                        ),
                        offset: const Offset(0.0, 0.0), //阴影xy轴偏移量
                        blurRadius: 0, //阴影模糊程度
                        spreadRadius: 0.0, //阴影扩散程度
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(
                      Radius.circular(value.get('radius')),
                    ),
                    child: SizedBox(
                      width: Dimens.setWidth(value.get('width')),
                      height: Dimens.setWidth(40),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Center(
                            child: Text(
                              widget.title,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: value.get('fontsize'),
                              ),
                            ),
                          ),
                          CustomAnimation<double>(
                            control: CustomAnimationControl.LOOP,
                            tween: 0.0.tweenTo(2 * pi), // Pass in tween
                            duration: const Duration(
                              milliseconds: 300,
                            ), // Obtain duration
                            builder: (context, child, rvalue) {
                              return Opacity(
                                opacity: value.get('opacity'),
                                child: Transform.rotate(
                                  angle: rvalue,
                                  child: Icon(
                                    Icons.refresh,
                                    size: Dimens.gap_dp30,
                                    color: Colors.white,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
