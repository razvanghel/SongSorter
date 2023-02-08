import 'package:cross_file/cross_file.dart';

import '../widgets/SearchArtist.dart';
import 'Artist.dart';
import 'package:song_sorter/model/Song.dart';
import 'FileMoveRecord.dart';

///AppState memorizes the state of the app
class AppState {
  /// The files that are loaded in the data table
  final List<XFile> droppedFiles;
  /// The songs that are loaded in the data table
  final List<Song> songs;
  /// The artists that was added in the given state. It can be null.
  final List<FileMoveRecord> filesMoved;

  AppState(
      {required this.droppedFiles,
      required this.songs,
      required this.filesMoved,
      });
}
