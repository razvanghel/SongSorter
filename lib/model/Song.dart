
class Song {
  final String fileName;
  final String artist;
  final String title;
  final String path;

  const Song({
    required this.fileName,
    required this.artist,
    required this.title,
    required this.path,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Song &&
              runtimeType == other.runtimeType &&
              fileName == other.fileName &&
              artist == other.artist &&
              title == other.title;

  @override
  int get hashCode => fileName.hashCode ^ artist.hashCode ^ title.hashCode;
}