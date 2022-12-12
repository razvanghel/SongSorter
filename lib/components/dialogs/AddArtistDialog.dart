import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../model/Artist.dart';

class AddArtistDialog extends AlertDialog{

  TextEditingController nameController = TextEditingController();
  TextEditingController genreController = TextEditingController();
  BuildContext context;
  AddArtistDialog({required this.context, name}){
    nameController.text = name;
  }

  @override
  AlertDialog build(BuildContext context) => AlertDialog(
    title: Text('Add new artist'),
    content: Container(
      height: 100,
      child: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(hintText: 'Artist name'),
            ),
            TextField(
              controller: genreController,
              decoration: InputDecoration(hintText: 'Artist genre'),
            ),
          ],
        ),
      ),
    ),
    actions: [
      Row(
        children: [
          TextButton(onPressed: () {Navigator.of(context).pop();}, child: Text('Cancel')),
          Expanded(child: SizedBox(),),
          TextButton(onPressed: () {submit();}, child: Text('Submit')),
        ],
      )
    ],
  );

  void submit(){
    Navigator.of(context).pop(Artist(nameController.text, genreController.text, [], ''));
    // Navigator.of(context).pop(nameController.text);
    // Navigator.of(context).pop(genreController.text);
  }

}