import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class WebScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch, // スマホ
    PointerDeviceKind.mouse, // マウスドラッグでもスクロール
    PointerDeviceKind.trackpad, // トラックパッド
  };
}
