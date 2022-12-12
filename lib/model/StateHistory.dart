import 'AppState.dart';


/// Keeps track of the states of the app.
class StateHistory {

  /// The list of states that can be undone
  List<AppState> undoList = [
    AppState(droppedFiles: [], songs: [], artistAdded: null, filesMoved: [])
  ];

  /// The list of states that can be redone
  List<AppState> redoList = [];

  /// Removes last object from undoList and adds it into redoList.
  /// Returns the next last object from undoList.
  AppState? undo() {
    try {
      redoList.add(undoList.last);
      var r = undoList.last;
      undoList.remove(undoList.last);
      return r;
    } catch (e) {
      print(e);
    }
  }

  /// Removes last object from redoList and adds it into undoList
  /// Returns last object from redoList
  AppState? redo() {
    try {
      var toremove = redoList.last;
      undoList.add(toremove);
      redoList.remove(toremove);
      return toremove;
    } catch (e) {
      return null;
    }
  }

  /// Adds a new state into the undoList and restarts the redoList
  void addState(AppState appState) {
    undoList.add(appState);
    redoList = [];
  }

}
