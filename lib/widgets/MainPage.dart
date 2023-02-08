import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:song_sorter/components/dialogs/ConfirmationDialog.dart';
import 'package:song_sorter/components/dialogs/SettingsDialog.dart';
import 'package:song_sorter/model/Artist.dart';
import 'package:song_sorter/model/Song.dart';
import 'package:song_sorter/widgets/MusicPlayer.dart';
import 'package:song_sorter/components/general/ButtonIconWidget.dart';
import 'DropAreaWidget.dart';
import 'SearchArtist.dart';
import '../helper/SizeHandler.dart';
import '../components/dialogs/AddArtistDialog.dart';
import '../components/my_dart_library/MyDataTable.dart';
import '../model/AppState.dart';
import '../model/FileMoveRecord.dart';
import '../model/StateHistory.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';

double topRowHeight = 92;
double ARTISTS_WIDTH = 200;
Color DISABLED_COLOR = Color(0xffA9A9A9);
Color ENABLED_COLOR = Color(0xff22bcca);

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String tempFile = '';

  String assetsFile = 'assets/settings.json';

  /// The audio player
  final audio = AudioPlayer();

  /// Determines whether the audio is playing
  bool isPlaying = false;

  ///The duration of the song
  Duration duration = Duration.zero;

  /// The position of the song
  Duration position = Duration.zero;

  /// The container for the music player widget
  late MusicPlayer player;

  late Directory pickedDirectory;

  int currentSong = -1;

  /// The state history of the app
  late StateHistory history;

  /// The search artist widget
  late SearchArtist artistsWidget;

  bool reloadArtists = true;

  SettingsOptions? settingsOptions;

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      readJson();
    });
    super.initState();
    artistsWidget = SearchArtist(
      root: "",
      addArtistMethod: addArtist,
      sendSongsToArtistMethod: sendSongsToArtist,
      refresh: reloadArtists,
    );
    history = StateHistory();
  }

  /// Reads the from the settings file stored in the temp directory. If not found, reads from assets/settings.json
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

  /// Sets the paths for reading music library and downloads folder.
  Future<void> continueReading(String response) async {
    final data = await json.decode(response);
    setState(() {
      settingsOptions = SettingsOptions(
        musicPath: data["musicPath"],
        downloadsPath: data["downloadsPath"],
      );
    });
  }

  /// Saves the paths in assets/settings.json and also in temp directory
  void _saveSettings() {
    File j = File(tempFile);
    j.create();
    j.writeAsStringSync(json.encode({
      "musicPath": settingsOptions!.musicPath,
      "downloadsPath": settingsOptions!.downloadsPath
    }));
    File jsonf = File(assetsFile);
    jsonf.writeAsStringSync(json.encode({
      "musicPath": settingsOptions!.musicPath,
      "downloadsPath": settingsOptions!.downloadsPath
    }));
  }

  /// Creates a path for the given artist
  Future addArtist(String name) async {
    var map = await _buildArtist(name);
    if (map != null) {
      final Artist artist = Artist(
          root: settingsOptions!.musicPath,
          name: map["name"].toString(),
          genre: map["genre"].toString(),
          subgenres: map["subgenres"].toString());
      setState(() {
        artistsWidget.allArtists.add({"index": -1, "artist": artist});
      });
      new Directory(artist.path).create(recursive: true);
      if (map["add_selected_songs"] == true &&
          artistsWidget.selectedSongs.length > 0) {
        sendSongsToArtist(artist, addedArtist: true);
      }
    }
  }

  /// Pops up a dialog where an artist can be added
  Future<Map<String, Object>?> _buildArtist(String name) {
    return showDialog<Map<String, Object>>(
        context: context,
        builder: (context) => AddArtistDialog(context: context, name: name));
  }

  @override
  Widget build(BuildContext context) {
    player = MusicPlayer(
      songs: artistsWidget.songs,
      current: currentSong,
    );
    if (settingsOptions != null) {
      setState(() {
        artistsWidget.root = settingsOptions!.musicPath;
      });
      if (settingsOptions!.downloadsPath == "" &&
          settingsOptions!.musicPath == "")
        Future.delayed(Duration.zero, () async {
          _openSettings(context, cancelAvailable: false);
        });
    }
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
                onPressed: () => _deleteSelected(),
                icon: Icon(Icons.delete),
              ),

              ButtonIconWidget(
                enabled: history.undoList.length > 0,
                color: history.undoList.length > 0
                    ? ENABLED_COLOR
                    : DISABLED_COLOR,
                icon: Icon(Icons.undo),
                iconSize: 25,
                splashRadius: 20,
                onPressed: () => _undo(),
              ),
              ButtonIconWidget(
                enabled: history.redoList.length > 0,
                icon: Icon(Icons.redo),
                color: history.redoList.length > 0
                    ? ENABLED_COLOR
                    : DISABLED_COLOR,
                onPressed: () => _redo(),
              ),
              player,
              //for now this feature is on hold
              ButtonIconWidget(
                enabled: true,
                icon: Icon(Icons.settings),
                color: ENABLED_COLOR,
                onPressed: () => _openSettings(context),
              ),
              SizedBox(width: 15),
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
                  child: artistsWidget),
              // - topRowHeight - bottom margin
            ],
          ),
        ),
      ],
    );
  }

  /// Moves a file from originalFile's path to targetPath
  Future<void> moveFile(File originalFile, String targetPath) async {
    String path = targetPath;

    try {
      // This will try first to just rename the file if they are on the same directory,

      await originalFile.rename(path);
    } on FileSystemException catch (e) {
      print(e.message);
      // if the rename method fails, it will copy the original file to the new directory and then delete the original file
      // return await originalFile.rename(targetPath);
      final newFileInTargetPath = await originalFile.copy(path);
      newFileInTargetPath.create();
      await originalFile.delete();
      // return newFileInTargetPath;
    }
  }

  /// Moves the songs from their original paths towards the given artist's directory
  void sendSongsToArtist(Artist artist, {bool addedArtist = false}) async {
    List<Song> songs = [];
    List<FileMoveRecord> moveHistory = [];
    artistsWidget.selectedSongs.forEach((song) async {
      var newPath = '${artist.path}\\${song.fileName}';
      moveFile(File(song.path), newPath);
      songs.add(song);
      moveHistory.add(FileMoveRecord(oldPath: song.path, newPath: newPath));
    });

    _saveState(addedArtist == true ? artist : null, moveHistory);

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

    _confirm(artist.path, songs.length);
  }

  Future _confirm(String path, int count) async {
    return await showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
        path: path,
        songsCount: count,
        onConfirm: () {
          Navigator.of(context).pop();
        },
      ),
    );
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
  void _saveState(Artist? artist, List<FileMoveRecord> filesMoved,
      {addToRedo = false, resetRedo = true}) {
    setState(() {
      AppState state = AppState(
        droppedFiles: artistsWidget.droppedFiles.toList(),
        songs: artistsWidget.songs.toList(),
        filesMoved: filesMoved,
      );
      addToRedo == true
          ? history.redoList.add(state)
          : history.addState(state, resetRedo: resetRedo);
    });
  }

  /// Returns the data table
  Widget _getTable() {
    return DropAreaWidget(
      child: artistsWidget.droppedFiles.isNotEmpty
          ? ScrollableWidget(child: _buildDataTable())
          : _defaultDropScreen(),
      onFiles: (files) {
        bool saved = false;
        for (var file in files) {
          if (!artistsWidget.droppedFiles
              .any((element) => element.path == file.path)) {
            if (saved == false) {
              //if there are files that are not duplicates => save the state once
              print('saving state');
              saved = true;
              _saveState(null, []);
            }
            artistsWidget.droppedFiles.add(file);
            artistsWidget.droppedFiles.sort(
                (a, b) => a.path.toLowerCase().compareTo(b.path.toLowerCase()));
            _readAudio(file, false);
          }
        }
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
      _saveState(null, []);
      for (var song in artistsWidget.selectedSongs.toList()) {
        artistsWidget.droppedFiles.remove(artistsWidget.droppedFiles
            .where((element) => element.path == song.path)
            .toList()[0]);
        artistsWidget.songs.remove(song);
        artistsWidget.selectedSongs.remove(song);
      }
    });
  }

  /// Go back to the last state
  _undo() {
    setState(() {
      // _saveState(null, filesMoved)
      List<FileMoveRecord> moveHistory = [];
      AppState? state = history.undo();
      if (state != null) {
        for (var record in state.filesMoved) {
          moveFile(File(record.newPath),
              record.oldPath); //target path is the old path
          moveHistory.add(FileMoveRecord(
              oldPath: record.newPath,
              newPath: record.oldPath)); // thus why here is reversed
        }
        _saveState(null, moveHistory, addToRedo: true, resetRedo: false);
        artistsWidget.droppedFiles = state.droppedFiles;
        artistsWidget.songs = state.songs;
        artistsWidget.selectedSongs = [];
      }
    });
    print(history.undoList.length);
  }

  /// Return to the last redone state
  _redo() {
    setState(() {
      AppState? state = history.redo();
      if (state != null) {
        List<FileMoveRecord> moveHistory = [];
        if (state.filesMoved != null) {
          for (var record in state.filesMoved) {
            moveFile(File(record.newPath), record.oldPath);
            moveHistory.add(FileMoveRecord(
                oldPath: record.oldPath, newPath: record.newPath));
          }
        }
        _saveState(null, moveHistory, resetRedo: false);
        artistsWidget.droppedFiles = state.droppedFiles;
        artistsWidget.songs = state.songs;
        artistsWidget.selectedSongs = [];
      }
    });
  }

  /// Plays the given song
  Future _playSong(Song song) async {
    setState(() {
      currentSong = artistsWidget.songs.indexOf(song);
    });
  }

  /// Opens the settings dialog
  Future _openSettings(BuildContext context, {cancelAvailable = true}) async {
    return await showDialog(
        context: context,
        builder: (context) => SettingsDialog(
            cancelAvailable: cancelAvailable,
            child: settingsOptions!,
            context: context,
            onSubmit: () {
              _saveSettings();
              Navigator.of(context).pop();
            }));
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
