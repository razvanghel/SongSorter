
import 'package:flutter/cupertino.dart';
import 'package:song_sorter/components/general/UrlOrAssetImage.dart';

class IconWidget extends StatefulWidget{

  final double width;
  final double height;
  final String path;
  final Color color;

  IconWidget({ required this.path, required this.width, required this.height, this.color = const Color(0xff000000)});

  @override
  State<IconWidget> createState() => _IconWidgetState();

}

class _IconWidgetState extends State<IconWidget>{

  @override
  Widget build(BuildContext context) {
    return Container(width: widget.width,
    margin: EdgeInsets.all(5),
    height: widget.height, child:UrlOrAssetImage(path: widget.path, color: widget.color,));
  }

}