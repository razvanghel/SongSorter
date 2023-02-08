import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:song_sorter/components/CheckboxOption.dart';
import '../../model/Artist.dart';

class AddArtistDialog extends AlertDialog{

  TextEditingController nameController = TextEditingController();
  TextEditingController genreController = TextEditingController();
  TextEditingController subgenreController = TextEditingController();
  CheckboxOption checkbox = CheckboxOption();
  BuildContext context;
  AddArtistDialog({required this.context, name}){
    nameController.text = name;
  }

  @override
  AlertDialog build(BuildContext context) => AlertDialog(
    title: Text('Add new artist'),
    content: Container(
      height: 170,
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
            TextField(
              controller: subgenreController,
              decoration: InputDecoration(hintText: 'Artist subgenre (optional)'),
            ),
            checkbox
          ],
        ),
      ),
    ),
    actions: [
      Row(
        children: [
          TextButton(onPressed: () {Navigator.of(context).pop();}, child: Text('Cancel')),
          Expanded(child: SizedBox(),),
          TextButton( onPressed: () {if(nameController.text != "" && genreController.text != "") submit();}, child: Text('Submit')),
        ],
      )
    ],
  );

  void submit(){
    Navigator.of(context).pop({
      "name": nameController.text,
      "genre": genreController.text,
      "subgenres": subgenreController.text,
      "add_selected_songs": checkbox.value,
    });
  }

}