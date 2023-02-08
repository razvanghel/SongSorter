class Artist{

  final String name;
  final String genre;
  final String subgenres;
  String root = "";
  String path = "";

  Artist({required this.root, required this.name, required this.genre, required this.subgenres}){
    if(this.root != "") {
      this.root = root.replaceAll('/', '\\');
      path = subgenres != ""
          ? '${root}\\${genre}\\${subgenres}\\${name}'
          : '${root}\\${genre}\\${name}';
      print("path ${path}");
    }
  }

}