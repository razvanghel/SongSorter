import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:song_sorter/Settings.dart';
import 'package:song_sorter/model/Song.dart';
import 'package:song_sorter/widgets/MusicPlayer.dart';
import 'package:song_sorter/components/general/ButtonIconWidget.dart';
import '../model/Artist.dart';
import 'DropAreaWidget.dart';
import 'SearchArtist.dart';
import '../helper/SizeHandler.dart';
import '../components/dialogs/AddArtistDialog.dart';
import '../components/general/IconWidget.dart';
import '../components/my_dart_library/MyDataTable.dart';
import '../model/AppState.dart';
import '../model/FileMoveRecord.dart';
import '../model/StateHistory.dart';

double topRowHeight = 78;
double ARTISTS_WIDTH = 200;
Color DISABLED_COLOR = Color(0xffA9A9A9);
Color ENABLED_COLOR = Color(0xff22bcca);


class SelectablePage extends StatefulWidget {
  @override
  _SelectablePageState createState() => _SelectablePageState();
}

class _SelectablePageState extends State<SelectablePage> {

  /// The audio player
  final audio = AudioPlayer();

  /// Determines whether the audio is playing
  bool isPlaying = false;

  ///The duration of the song
  Duration duration = Duration.zero;

  /// The position of the song
  Duration position = Duration.zero;

  /// The container for the music player widget
  Widget player = Container();
  //todo maybe remove change
  bool change = false;

  /// The state history of the app
  StateHistory history = StateHistory();

  /// The search artist widget
  SearchArtist artistsWidget = SearchArtist(height: 100);

  @override
  void initState() {
    super.initState();
    audio.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying = state == PlayerState.playing;
      });
    });
    audio.onDurationChanged.listen((state) {
      setState(() {
        duration = state;
      });
    });
    audio.onPositionChanged.listen((state) {
      setState(() {
        position = state;
      });
    });
  }

  /// Creates a path for the given artist
  Future addArtist(String name) async {
    final Artist? artist = await _buildArtist(name);
    artist!;
    //todo add subgenres
    artist.path =
        '${ARTISTS_PATH.replaceAll('/', '\\')}\\${artist.genre}\\${artist.name}';

    new Directory(artist.path).create();
    _saveState(artist, []);
  }

  /// Pops up a dialog where an artist can be added
  Future<Artist?> _buildArtist(String name) {
    return showDialog<Artist?>(
        context: context,
        builder: (context) => AddArtistDialog(context: context, name: name));
  }

  @override
  Widget build(BuildContext context) {
    artistsWidget =
        _getArtist(SizeHandler.getHeight(context) - topRowHeight - 0);
    return Column(
      children: [
        Container(
          height: topRowHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(width: 25),
              ButtonIconWidget(
                enabled: artistsWidget.selectedSongs.isNotEmpty,
                color: artistsWidget.selectedSongs.isNotEmpty
                    ? ENABLED_COLOR
                    : DISABLED_COLOR,
                width: 30,
                height: 30,
                path: "assets/icons/trash-icon.svg",
                onPressed: () => _deleteSelected(),
              ),
              ButtonIconWidget(
                enabled: history.undoList.length > 1,
                color: history.undoList.length > 1
                    ? ENABLED_COLOR
                    : DISABLED_COLOR,
                width: 30,
                height: 30,
                path: "assets/icons/undo-icon.svg",
                onPressed: () => _undo(),
              ),
              ButtonIconWidget(
                enabled: history.redoList.length > 0,
                color: history.redoList.length > 0
                    ? ENABLED_COLOR
                    : DISABLED_COLOR,
                width: 30,
                height: 30,
                path: "assets/icons/redo-icon.svg",
                onPressed: () => _redo(),
              ),
              player,
            ],
          ),
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: SizeHandler.getWidth(context) - ARTISTS_WIDTH,
                padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                child: Container(
                  child: _getTable(),
                ),
              ),
              Container(
                  padding: EdgeInsets.only(bottom: 10, right: 10, top: 3.4),
                  width: ARTISTS_WIDTH,
                  child: change
                      ? _getSearchArtist(
                          SizeHandler.getHeight(context) - topRowHeight - 0)
                      : artistsWidget),
              // - topRowHeight - bottom margin
            ],
          ),
        ),
      ],
    );
  }


  /// Moves a file from originalFile's path to targetPath
  void moveFile(File originalFile, String targetPath) async {
    String path = targetPath;
    int index = 1;
    String extension = '.' + targetPath.split('.').last;
    while (await (File(path).exists())) {
      path = targetPath.replaceAll(extension, ' (${index})${extension}');
      index++;
    }

    try {
      // This will try first to just rename the file if they are on the same directory,

      await originalFile.rename(path);
    } on FileSystemException catch (e) {
      print(e.message);
      // if the rename method fails, it will copy the original file to the new directory and then delete the original file
      // return await originalFile.rename(targetPath);
      final newFileInTargetPath = await originalFile.copy(path);
      await originalFile.delete();
      // return newFileInTargetPath;
    }
  }

  /// Moves the songs from their original paths towards the given artist's directory
  void sendSongsToArtist(Artist artist) {
    List<Song> songs = [];
    List<FileMoveRecord> moveHistory = [];
    artistsWidget.selectedSongs.forEach((song) {
      var newPath = '${artist.path}\\${song.fileName}';
      moveFile(File(song.path), newPath);
      songs.add(song);
      moveHistory.add(FileMoveRecord(oldPath: song.path, newPath: newPath));
    });
    _saveState(null, moveHistory);
    var paths = songs.map((Song song) => song.path).toList();
    var allFiles = artistsWidget.droppedFiles
        .where((file) => paths.contains(file.path))
        .toList();
    for (var fileToRemove in allFiles) {
      setState(() {
        artistsWidget.droppedFiles.remove(fileToRemove);
      });
    }
    songs.forEach((element) {
      setState(() {
        artistsWidget.selectedSongs.remove(element);
        artistsWidget.songs.remove(element);
      });
    });
  }

  /// Initializes the artistsWidget
  SearchArtist _getArtist(double height) {
    setState(() {
      artistsWidget.height = height;
      artistsWidget.sendSongsToArtist = sendSongsToArtist;
      artistsWidget.addArtist = addArtist;
    });
    return artistsWidget;
  }

  /// Initializes the artistsWidget
  SearchArtist _getSearchArtist(double height) {
    var res = SearchArtist(
      height: height,
    );
    res.sendSongsToArtist = sendSongsToArtist;
    res.addArtist = addArtist;
    return res;
  }

  /// Default screen when no songs are added
  Widget _defaultDropScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.file_copy_sharp, size: 96),
        const SizedBox(height: 8),
        Text('Drag and drop here',
            style: Theme.of(context).textTheme.titleLarge),
      ],
    );
  }

  /// Places the current state into history
  void _saveState(Artist? artist, List<FileMoveRecord> filesMoved) {
    setState(() {
      history.addState(AppState(
        droppedFiles: artistsWidget.droppedFiles.toList(),
        songs: artistsWidget.songs.toList(),
        artistAdded: artist,
        filesMoved: filesMoved,
      ));
    });
  }

  /// Returns the data table
  Widget _getTable() {
    return DropAreaWidget(
      child: artistsWidget.droppedFiles.isNotEmpty
          ? ScrollableWidget(child: _buildDataTable())
          : _defaultDropScreen(),
      onFiles: (files) {
        for (var file in files) {
          if (!artistsWidget.droppedFiles
              .any((element) => element.path == file.path)) {
            artistsWidget.droppedFiles.add(file);
            artistsWidget.droppedFiles.sort(
                (a, b) => a.path.toLowerCase().compareTo(b.path.toLowerCase()));
            _readAudio(file, file == files.last);
          }
        }
        setState(() {});
      },
    );
  }

  /// Builds the data table
  Widget _buildDataTable() {
    final columns = ['', 'File', 'Artist', 'Title'];

    return MyDataTable(
      onSelectAll: (isSelectedAll) {
        setState(() => artistsWidget.selectedSongs =
            isSelectedAll! ? artistsWidget.songs : []);
      },
      columns: _getColumns(columns),
      rows: _getRows(artistsWidget.songs),
    );
  }

  /// Builds the data table's columns
  List<MyDataColumn> _getColumns(List<String> columns) => columns
      .map((String column) => MyDataColumn(
            label: Text(column),
          ))
      .toList();

  /// Builds the data table's rows
  List<MyDataRow> _getRows(List<Song> songs) => songs
      .map((Song song) => MyDataRow(
            selected: artistsWidget.selectedSongs.contains(song),
            onSelectChanged: (isSelected) => setState(() {
              final isAdding = isSelected != null && isSelected;
              isAdding
                  ? artistsWidget.selectedSongs.add(song)
                  : artistsWidget.selectedSongs.remove(song);
            }),
            cells: [
              MyDataCell(IconButton(
                icon: Icon(
                  Icons.play_arrow,
                ),
                iconSize: 25,
                onPressed: () async {
                  setState(() {
                    _playSong(song);
                  });
                },
              )),
              MyDataCell(Container(
                  // width: 100,
                  child: Text(song.fileName))),
              MyDataCell(
                Text(song.artist),
              ),
              MyDataCell(Container(
                child: Text(song.title),
              )),
            ],
          ))
      .toList();

  /// Reads the metadata of an audio file
  Future _readAudio(XFile file, bool save) async {
    var result = await MetadataRetriever.fromFile(File(file.path));
    setState(() {
      artistsWidget.songs.add(Song(
          fileName: result.filePath!.split('\\').last,
          artist: result.albumArtistName!,
          title: result.trackName!,
          path: result.filePath!));
      artistsWidget.songs.sort((a, b) =>
          a.fileName.toLowerCase().compareTo(b.fileName.toLowerCase()));
      if (save) {
        _saveState(null, []);
      }
    });
  }

  /// Removes the selected songs from the data table
  _deleteSelected() {
    setState(() {
      for (var song in artistsWidget.selectedSongs.toList()) {
        artistsWidget.droppedFiles.remove(artistsWidget.droppedFiles
            .where((element) => element.path == song.path)
            .toList()[0]);
        artistsWidget.songs.remove(song);
        artistsWidget.selectedSongs.remove(song);
      }
      _saveState(null, []);
    });
  }

  /// Go back to the last state
  _undo() {
    setState(() {
      if (history.undoList.length >= 2) {
        AppState state = history.undo()!;
        for (var record in state.filesMoved) {
          moveFile(File(record.newPath), record.oldPath);
        }

        if (state.artistAdded != null) {
          final dir = Directory(state.artistAdded!.path);
          dir.deleteSync(recursive: true);
          change = true;
        }
        state = history.undoList.last;
        artistsWidget.droppedFiles = state.droppedFiles;
        artistsWidget.songs = state.songs;
        artistsWidget.selectedSongs = [];
      }
    });
  }

  /// Return to the last redone state
  _redo() {
    setState(() {
      AppState? state = history.redo();
      if (state != null) {
        artistsWidget.droppedFiles = state.droppedFiles;
        artistsWidget.songs = state.songs;
        artistsWidget.selectedSongs = [];
        if (state.artistAdded != null) {
          new Directory(state.artistAdded!.path).create();
        }
        if (state.filesMoved != null) {
          for (var record in state.filesMoved!) {
            moveFile(File(record.oldPath), record.newPath);
          }
        }
      }
    });
  }

  /// Builds the music player
  Widget _buildMusicPlayer(Song song) {
    setState(() {
      isPlaying = true;
    });
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.keyboard_double_arrow_left),
              iconSize: 25,
              onPressed: () async {},
            ),
            IconButton(
              // icon: Icon(
              //   isPlaying ? Icons.pause : Icons.play_arrow,
              // ),
              icon: isPlaying ? Icon(Icons.pause): Icon(Icons.play_arrow),
              iconSize: 25,
              onPressed: () async {
                if (isPlaying) {
                  await audio.pause();
                  setState(() {
                    isPlaying = false;
                  });
                } else {
                  await audio.resume();
                  setState(() {
                    isPlaying = true;
                  });
                }
              },
            ),
            IconButton(
              icon: Icon(Icons.keyboard_double_arrow_right),
              iconSize: 25,
              onPressed: () async {},
            ),
            Text(song.fileName),
          ],
        ),
        Container(
          height: 30,
          // width: 300,
          child: Row(
            children: [
              Slider(
                min: 0,
                max: duration.inSeconds.toDouble(),
                value: position.inSeconds.toDouble(),
                onChanged: (value) async {
                  final position = Duration(seconds: value.toInt());
                  await audio.seek(position);
                  await audio.resume();
                },
              ),
            ],
          ),
        )
      ],
    );
  }

  /// Plays the given song
  Future _playSong(Song song) async {
    if(player != null){
      audio.stop();
      audio.setReleaseMode(ReleaseMode.stop);
    }
    audio.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying = state == PlayerState.playing;
      });
    });
    audio.onDurationChanged.listen((state) {
      setState(() {
        duration = state;
      });
    });
    audio.onPositionChanged.listen((state) {
      setState(() {
        position = state;
      });
    });
    await audio.play(DeviceFileSource(song.path));
    setState(() {
      player = _buildMusicPlayer(song);
    });

  }
}

class ScrollableWidget extends StatelessWidget {
  final Widget child;

  const ScrollableWidget({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        scrollDirection: Axis.vertical,
        child: child,
      );
}
