import 'package:flutter/material.dart';
import 'package:mighty_delivery/extensions/extension_util/context_extensions.dart';
import 'package:mighty_delivery/extensions/extension_util/widget_extensions.dart';
import '../../main.dart';
import '../../main/utils/Colors.dart';

class BodyCornerWidget extends StatelessWidget {
  final Widget child;
  final Color? color;

  BodyCornerWidget({required this.child, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: appStore.isDarkMode ? scaffoldSecondaryDark : colorPrimary,
      child: Container(
        color: colorPrimaryLight,
        height: context.height(),
        width: context.width(),
        child: child,
      ).cornerRadiusWithClipRRectOnly(topRight: 24, topLeft: 24),
    );
  }
}
