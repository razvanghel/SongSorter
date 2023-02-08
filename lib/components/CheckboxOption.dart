import 'package:flutter/material.dart';

class CheckboxOption extends StatefulWidget{

  bool value = true;
  @override
  State<CheckboxOption> createState() => CheckboxOptionState();

}

class CheckboxOptionState extends State<CheckboxOption>{

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: widget.value,
          onChanged: (bool? v) {
            setState(() {
              widget.value = v!;
            });
          },
        ),
        Container(height: 27, child: Text("Add selected songs to artist")),
      ],

    );
  }


}