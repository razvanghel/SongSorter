import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_desktop_folder_picker/flutter_desktop_folder_picker.dart';
import 'package:song_sorter/components/general/ButtonIconWidget.dart';
import '../../helper/Helper.dart';
import 'package:song_sorter/helper/SettingsReader.dart';
import 'package:path_provider/path_provider.dart';

class SettingsOptions extends StatefulWidget {

  String musicPath;

  String downloadsPath;

  SettingsOptions({required this.musicPath, required this.downloadsPath});

  @override
  State<StatefulWidget> createState() => SettingsOptionsState();
}

class SettingsOptionsState extends State<SettingsOptions> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
            alignment: Alignment.centerLeft, child: Text("Music library path")),
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(width: 2, color: Colors.black),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(widget.musicPath)),
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 5.0),
              child: ButtonIconWidget(
                  icon: Icon(Icons.edit),
                  onPressed: () async {
                    String? path = (await _openFolders())!;
                    setState(() {
                      widget.musicPath = path;
                    });
                  }),
            )
          ],
        ),
        SizedBox(height: 15),
        Align(
            alignment: Alignment.centerLeft, child: Text("Telegram downloads folder path")),
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(width: 2, color: Colors.black),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(widget.downloadsPath)),
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 5.0),
              child: ButtonIconWidget(
                onPressed: () async {
                  String? path = (await _openFolders());
                  setState(() {
                    widget.downloadsPath = path ?? widget.downloadsPath;
                  });
                },
                icon: Icon(Icons.edit),
              ),
            )
          ],
        ),
      ],
    );
  }

  Future<String?> _openFolders() async {
    String? path = await FlutterDesktopFolderPicker.openFolderPickerDialog();
    return path;
  }
}

class SettingsDialog extends AlertDialog {

  final BuildContext context;
  final Function onSubmit;
  final SettingsOptions child;
  bool cancelAvailable;
  SettingsDialog({required this.context, required this.onSubmit, required this.child, this.cancelAvailable = true});

  @override
  AlertDialog build(BuildContext context) {
    return AlertDialog(
      title: Text('Settings'),
      content: Container(
        height: 150,
        width: 300,
        child: SingleChildScrollView(
          child: Column(
            children: [
              child,

            ],
          ),
        ),
      ),
      actions: [
        Row(
          children: [
            cancelAvailable ? TextButton(
                onPressed: () {
                    Navigator.of(context).pop();
                },
                child: Text('Cancel')): Container(),
            Expanded(
              child: SizedBox(),
            ),
            TextButton(
                onPressed: () {
                  if(canProceed())
                    onSubmit();
                },
                child: Text('Save')),
          ],
        )
      ],
    );
  }

  bool canProceed(){
    return child.musicPath != "" && child.downloadsPath != "";
  }

}
