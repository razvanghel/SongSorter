import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'IconWidget.dart';

class ButtonIconWidget extends StatefulWidget {
  final double width;
  final double height;
  bool enabled = true;
  final Function onPressed;
  final Color color;

  final Icon icon;
  final double iconSize;
  final double splashRadius;

  ButtonIconWidget(
      {
      required this.onPressed,
      required this.icon,
      this.enabled = true,
      this.iconSize = 25.0,
      this.splashRadius = 20,
      this.color = const Color(0xff000000),
      this.width = 50,
      this.height = 50});

  @override
  State<ButtonIconWidget> createState() => _ButtonIconWidgetState();
}

class _ButtonIconWidgetState extends State<ButtonIconWidget> {
  @override
  Widget build(BuildContext context) => IconButton(
              icon: widget.icon,
              iconSize: widget.iconSize,
              color: widget.color,
              splashRadius: widget.enabled ? widget.splashRadius: 0.01,
              onPressed: () => {
                print('widget ${widget.enabled}'),
                if(widget.enabled)
                  widget.onPressed()
              },
              );
}
