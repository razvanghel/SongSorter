import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_desktop_folder_picker/flutter_desktop_folder_picker.dart';
import 'package:song_sorter/components/general/ButtonIconWidget.dart';
import 'package:path_provider/path_provider.dart';

class SettingsReader{
  String musicPath = '';
  String downloadsPath = '';
  String tempFile = '';
  String assetsFile = 'assets/settings.json';

  SettingsReader(){
    readJson();
  }

  Future<void> readJson() async {
    var dir = await getTemporaryDirectory();

    tempFile = '${dir.path}/songSorter.json';
    try {
      final String response = await File(tempFile).readAsString();
      continueReading(response);
    } catch (e) {
      final String response = await rootBundle.loadString(assetsFile);
      continueReading(response);
    }
  }

  Future<void> continueReading(String response) async {
    final data = await json.decode(response);
    musicPath = data["musicPath"];
    downloadsPath = data["downloadsPath"];
    print('jsonread');
  }
}
