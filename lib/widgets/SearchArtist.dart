// main.dart
import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:song_sorter/model/Song.dart';

import '../model/Artist.dart';

class SearchArtist extends StatefulWidget {
  List<Song> songs = [];
  List<Song> selectedSongs = [];
  List<XFile> droppedFiles = [];
  final Function addArtistMethod;
  final Function sendSongsToArtistMethod;
  String currentValue = '';
  double height = -1;
  String root;
  bool refresh;
  List<Map<String, dynamic>> allArtists;

  SearchArtist(
      {required this.root,
      required this.addArtistMethod,
      required this.sendSongsToArtistMethod,
      this.allArtists = const [],
      required this.refresh});

  @override
  _SearchArtistState createState() => _SearchArtistState();
}

class _SearchArtistState extends State<SearchArtist> {

  List<Map<String, dynamic>> _foundArtists = [];
  final textController = TextEditingController();

  @override
  initState() {
    widget.allArtists = _readArtists();
    _foundArtists = widget.allArtists;
    super.initState();
  }
  /// Returns all artists from the artist directory
  List<Map<String, dynamic>> _readArtists() {
    var myDir = Directory(widget.root);
    List<Map<String, dynamic>> list = [];
    List<Directory> directories = [];
    myDir.listSync(recursive: true).forEach((element) {
      if (element is Directory) {
        if (element
                .listSync(recursive: false)
                .where((o) => o is Directory)
                .toList()
                .length ==
            0) directories.add(element);
      }
      ;
    });
    List<Artist> artists =
        directories.map((Directory e) => _getArtist(e)).toList();
    artists
        .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    artists.forEach((element) {
      list.add({"id": artists.indexOf(element), "artist": element});
    });
    return list;
  }

  /// Returns the artist from the given directory
  Artist _getArtist(Directory dir) {
    var path = dir.path.replaceAll("${widget.root}\\", "");
    var split = path.split('\\');
    String name = split[split.length - 1];
    String genre = split[0];
    return Artist(
        root: widget.root,
        name: name,
        genre: genre,
        subgenres: split.length == 3 ? split[1] : "" );
  }

  // This function is called whenever the text field changes
  void _runFilter(String enteredKeyword) {
    setState(() {
      if (enteredKeyword.isEmpty) {
        // if the search field is empty or only contains white-space, we'll display all users
        _foundArtists = widget.allArtists;
      } else {
        _foundArtists = widget.allArtists
            .where((user) => user["artist"]
                .name
                .toLowerCase()
                .contains(enteredKeyword.toLowerCase()))
            .toList();
        // we use the toLowerCase() method to make it case-insensitive
      }
    });
  }

  void _clearText() {
    textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    double buttonH = 50.0;
    if (textController.value.text.isEmpty || widget.refresh) {
      widget.allArtists = _readArtists();
      _foundArtists = widget.allArtists;
      widget.refresh = false;
    }
    return Container(
        child: Column(
      children: [
        SizedBox(height: 3),
        //extra space to align the search bottom bar with the data table line
        TextField(
          onChanged: (value) => _runFilter(value),
          controller: textController,
          decoration: const InputDecoration(
              labelText: 'Search', suffixIcon: Icon(Icons.search)),
        ),
        SizedBox(height: 2),
        Row(children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 4, bottom: 2),
              child: Container(
                height: buttonH,
                decoration: BoxDecoration(
                  color: const Color(0xff00bfff),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: TextButton(
                    // onChanged: (value) => _runFilter(value),
                    onPressed: () async {
                      await widget.addArtistMethod(textController.value.text);
                      setState(() {
                        _clearText();
                      });
                    },
                    child: Text(
                      "Add artist",
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    )),
              ),
            ),
          ),
        ]),
        Expanded(child: _getList()),
      ],
    ));
  }

  Widget _getList() {
    return ListView.builder(
      itemCount: _foundArtists.length,
      itemBuilder: (context, index) => LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        return Card(
            key: ValueKey(_foundArtists[index]["id"]),
            color: Colors.blue,
            // elevation: 1,
            margin: const EdgeInsets.symmetric(vertical: 5.0),
            child: Container(
              // height: widget.cardHeight,
              height: 50,
              // height: constraints.maxHeight * .1,
              child: _foundArtists.isNotEmpty
                  ? Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(textDirection: TextDirection.ltr, children: [
                              Text(
                                (_foundArtists[index]["id"] + 1).toString(),
                                style: const TextStyle(
                                    fontSize: 24, color: Colors.white),
                              ),
                              Expanded(
                                child: TextButton(
                                    onPressed: () {
                                      if (widget.selectedSongs.isNotEmpty)
                                        widget.sendSongsToArtistMethod(
                                            _foundArtists[index]['artist']);
                                    },
                                    child: Row(children: [
                                      Text(
                                        _foundArtists[index]['artist'].path != "" ? _foundArtists[index]['artist'].name : "",
                                        style: TextStyle(color: Colors.white),
                                        textAlign: TextAlign.left,
                                        maxLines: 1,
                                      ),
                                    ])),
                              )
                            ])
                          ],
                        ),
                      ),
                    )
                  : Container(),
            ));
      }),
    );
  }

}
