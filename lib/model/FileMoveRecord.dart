
/// Stores the old path and the new path of a file that was moved.
class FileMoveRecord{

  final String oldPath;
  final String newPath;

  FileMoveRecord({required this.oldPath, required this.newPath});
}