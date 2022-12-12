// main.dart
import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:song_sorter/Settings.dart';
import 'package:song_sorter/model/Song.dart';

import '../model/Artist.dart';

class SearchArtist extends StatefulWidget {

  List<Song> songs = [];
  List<Song> selectedSongs = [];
  List<XFile> droppedFiles = [];
  double height;
  late Function addArtist;
  late Function sendSongsToArtist;

  bool refresh = true;
  List<Map<String, dynamic>> allArtists = [
  ];
  SearchArtist({required this.height});

  @override
  _SearchArtistState createState() => _SearchArtistState();
}

class _SearchArtistState extends State<SearchArtist> {
  final int _cardsPerScreen = 10;
  String _currentValue = '';
  List<Map<String, dynamic>> _foundUsers = [];

  @override
  initState() {
    _readArtists();
    _foundUsers = widget.allArtists;
    super.initState();
  }

  /// Returns all artists from the artist directory
  void _readArtists() {
    widget.allArtists = [];
    var myDir = Directory(ARTISTS_PATH);
    List<Directory> directories = [];
    myDir.listSync(recursive: true).forEach((element) {

      if(element is Directory){
        if(element.listSync(recursive: false).where((o) => o is Directory).toList().length == 0)
            directories.add(element);
      };
    });
    List<Artist> artists = directories.map((Directory e) => _getArtist(e))
        .toList();
    artists.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    artists.forEach((element) {
      widget.allArtists.add({"id": artists.indexOf(element), "artist": element});
    });
  }

  /// Returns the artist from the given directory
  Artist _getArtist(Directory dir){
    String path = dir.path;
    var split = dir.path.split('\\');
    String name = dir.path.split('\\')[split.length-1];
    String genre = dir.path.replaceAll(ARTISTS_PATH, '').split('\\')[0];
    List<String> subgenres = split.where((element) => split.indexOf(element) > split.indexOf(genre) && split.indexOf(element) < split.length-1 ).toList();
    return Artist(name, genre, subgenres, path);
  }

  // This function is called whenever the text field changes
  void _runFilter(String enteredKeyword) {
    _currentValue = enteredKeyword;
    List<Map<String, dynamic>> results = [];
    setState(() {
      if (enteredKeyword.isEmpty) {
        // if the search field is empty or only contains white-space, we'll display all users
        _foundUsers = widget.allArtists;
      } else {
        _foundUsers = widget.allArtists
            .where((user) => user["artist"].name
            .toLowerCase()
            .contains(enteredKeyword.toLowerCase()))
            .toList();
        // we use the toLowerCase() method to make it case-insensitive
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double buttonH = 50.0;
    double height =
        widget.height - buttonH - 75;//75 is text field height + sized boxes
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 3),
          //extra space to align the search bottom bar with the data table line
          TextField(
            onChanged: (value) => _runFilter(value),
            decoration: const InputDecoration(
                labelText: 'Search', suffixIcon: Icon(Icons.search)),
          ),
          SizedBox(height: 2),
          Row(children: [
            Expanded(
              child: Container(
                height: buttonH,
                decoration: BoxDecoration(
                  color: const Color(0xff00bfff ),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: TextButton(
                    // onChanged: (value) => _runFilter(value),
                    onPressed: () async {await widget.addArtist(_currentValue); setState(() {
                      print('done');
                    });},
                    child: Text("Add artist", style: TextStyle(color: Colors.white),)),
              ),
            ),
          ]),

          Container(
            height: height,
            child: _foundUsers.isNotEmpty && widget.refresh == true
                ? _getList(height)
                : const Text(
                    'No results found',
                    style: TextStyle(fontSize: 24),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _getList(height){
    setState(() {
      _readArtists();
      _foundUsers = widget.allArtists;

    });
    return ListView.builder(
      itemCount: _foundUsers.length,
      itemBuilder: (context, index) => Card(
          key: ValueKey(_foundUsers[index]["id"]),
          color: Colors.blue,
          // elevation: 1,
          margin: const EdgeInsets.symmetric(vertical: 5.0),
          child: Container(
            height: _computeHeight(height),
            child: _foundUsers.isNotEmpty
                ? Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment:
                  CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => widget.sendSongsToArtist(_foundUsers[index]['artist']),
                      child: ListTile(
                        leading: Text(
                          (_foundUsers[index]["id"] + 1).toString(),
                          style: const TextStyle(
                              fontSize: 24,
                              color: Colors.white),
                        ),
                        title: Text(
                            _foundUsers[index]['artist'].name,
                            style:
                            TextStyle(color: Colors.white)),
                        // subtitle: Text(
                        //     '${_foundUsers[index]["artist"].subgenres.toString()}',
                        //     style:
                        //         TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            )
                : Container(),
          )),
    );
  }

  /// Determines the number of cards that can be shown on the screen.
  /// If the computed height is less that minCardHeight, then cards number decreases
  double _computeHeight(double height) {
    int cards = _cardsPerScreen;
    double minCardHeight = 50;
    while(height / cards - 10 < minCardHeight && cards > 0)
      cards --;
    return height / cards - 10;
  }
}
