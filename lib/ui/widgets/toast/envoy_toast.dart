import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/widgets/toast/toast_route.dart';
import 'package:flutter/material.dart';

typedef OnTap = void Function(EnvoyToast toast);

class EnvoyToast<T> extends StatefulWidget {
  late final EnvoyToastRoute<T?> envoyToastRoute;
  final OnTap? onTap;
  final GestureTapCallback? onActionTap;
  final Color backgroundColor;
  final Widget? icon;
  final String? message;
  final String? actionButtonText;
  final WidgetBuilder? builder;
  final ToastStatusCallback? onStatusChanged;
  final Offset? endOffset;
  final EdgeInsets margin;
  final EdgeInsets padding;
  final Duration animationDuration;
  final Curve forwardAnimationCurve;
  final Curve reverseAnimationCurve;
  final Duration? duration;

  final bool isDismissible;

  EnvoyToast({
    this.onTap,
    this.onActionTap,
    this.builder,
    this.onStatusChanged,
    this.endOffset,
    this.duration,
    this.margin = const EdgeInsets.all(0.0),
    this.padding = const EdgeInsets.all(16),
    this.icon,
    this.actionButtonText,
    this.message,
    this.animationDuration = const Duration(milliseconds: 430),
    this.forwardAnimationCurve = Curves.easeOutCirc,
    this.reverseAnimationCurve = Curves.easeOutCirc,
    this.isDismissible = true,
    required this.backgroundColor,
  });

  Future<T?> show(BuildContext context) async {
    envoyToastRoute = showToast<T>(
      context: context,
      toast: this,
    ) as EnvoyToastRoute<T?>;
    return await Navigator.of(context, rootNavigator: false)
        .push(envoyToastRoute as Route<T>);
  }

  @override
  State<StatefulWidget> createState() => EnvoyToastState();
}

class EnvoyToastState extends State<EnvoyToast> {
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: Platform.isIOS ? 100 : 90),
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [
            .2,
            1,
            1
          ],
              colors: [
            Color(0xFF000000),
            Color(0xff2f3334),
            Color(0xFF000000),
          ])),
      child: Stack(
        children: [
          Align(
            heightFactor: 1.0,
            alignment: Alignment.bottomCenter,
            child: Material(
              color: Colors.transparent,
              child: SafeArea(
                bottom: false,
                top: true,
                left: false,
                right: false,
                child: createGenericToast(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget createGenericToast(context) {
    return this.widget.builder != null
        ? this.widget.builder!(context)
        : Container(
            constraints:
                BoxConstraints(minWidth: MediaQuery.of(context).size.width),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Expanded(
                      child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      widget.icon ?? SizedBox.shrink(),
                      Padding(padding: EdgeInsets.all(4)),
                      Flexible(
                        child: Text(
                          widget.message ?? "",
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.white),
                        ),
                      ),
                      Padding(padding: EdgeInsets.all(4)),
                      InkWell(
                        onTap: widget.onActionTap,
                        child: Text(widget.actionButtonText ?? "",
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: EnvoyColors.darkTeal)),
                      ),
                    ],
                  )),
                  Container(
                    height: 24,
                    child: VerticalDivider(
                      thickness: 1,
                      color: Colors.white24,
                    ),
                  ),
                  IconButton(
                      onPressed: () {
                        if (widget.envoyToastRoute.currentStatus ==
                            EnvoyToastRouteStatus.SHOWING) {
                          Navigator.pop(context);
                        }
                      },
                      icon: Icon(
                        Icons.close,
                        color: Colors.white,
                      ))
                ],
              ),
            ),
          );
  }
}
