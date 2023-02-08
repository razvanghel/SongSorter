import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class UrlOrAssetImage extends StatefulWidget {

  const UrlOrAssetImage({
    Key? key,
    required this.path,
    this.fit = BoxFit.fill,
    this.isFile = false,
    this.color = const Color(0xff000000),
  }) : super(key: key);
  final String path;
  final BoxFit fit;
  final bool isFile;
  final Color color;


  @override
  State<UrlOrAssetImage> createState() => _UrlOrAssetImageState();
}
class _UrlOrAssetImageState extends State<UrlOrAssetImage> {

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    if (widget.path.startsWith('asset')) {
      // print("[UrlOrAssetImage] Asset");
      if (widget.path.endsWith('svg')) {
        return SvgPicture.asset(widget.path,
            color: widget.color,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height);
      }
      return Image(
        image: AssetImage(widget.path),
        color: widget.color,
        fit: widget.fit,
      );
    } else if (widget.isFile) {
      return Image.file(
        File(widget.path),
      );
    }
    return Container();
  }
}