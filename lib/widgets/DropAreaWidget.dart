import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';

/// Widget that determines the area where songs can be dropped
class DropAreaWidget extends StatefulWidget {
  /// The dropped files that will be read
  final void Function(List<XFile> files) onFiles;
  final Widget child;
  const DropAreaWidget({Key? key, required this.child, required this.onFiles}) : super(key: key);

  @override
  State<DropAreaWidget> createState() => _DropAreaWidgetState();
}

class _DropAreaWidgetState extends State<DropAreaWidget> {
  bool dragging = false;
  Offset localPosition = Offset.zero;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: DropTarget(
            onDragEntered: (details) {
              print('enter');
              dragging = true;
              localPosition = details.localPosition;
              setState(() {});
            },
            onDragUpdated: (details) {

              localPosition = details.localPosition;
              setState(() {});
            },
            onDragExited: (details) {
              print('exit');
              dragging = false;
              localPosition = details.localPosition;

              setState(() {});
            },
            onDragDone: (details) {
              final files = details.files;
              widget.onFiles(files.toList());
              setState(() {});
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.maxFinite,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: dragging ? Colors.white24 : Colors.white12,
                border: Border.all(
                  color: Colors.white54,
                  width: dragging ? 4 : 2,
                ),
              ),
              child: widget.child
            ),
          ),
        ),
      ],
    );
  }


}
