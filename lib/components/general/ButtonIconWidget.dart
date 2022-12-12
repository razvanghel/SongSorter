import 'package:flutter/cupertino.dart';

import 'IconWidget.dart';

class ButtonIconWidget extends StatefulWidget {
  final double width;
  final double height;
  final String path;
  bool enabled = true;
  final Function onPressed;
  final Color color;

  ButtonIconWidget(
      {required this.path,
      required this.onPressed,
      this.enabled = true,
      this.color = const Color(0xff000000),
      this.width = 50,
      this.height = 50});

  @override
  State<ButtonIconWidget> createState() => _ButtonIconWidgetState();
}

class _ButtonIconWidgetState extends State<ButtonIconWidget> {
  @override
  Widget build(BuildContext context) => GestureDetector(
      onTap: () => {if (widget.enabled) widget.onPressed()},
      child: IconWidget(
        width: widget.width,
        height: widget.height,
        color: widget.color,
        path: widget.path,
      ));
}
