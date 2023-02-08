import 'AppState.dart';


/// Keeps track of the states of the app.
class StateHistory {
  /// The list of states that can be undone
  List<AppState> undoList = [];

  /// The list of states that can be redone
  List<AppState> redoList = [];

  /// Removes last object from undoList and adds it into redoList.
  /// Returns the next last object from undoList.
  AppState? undo() {
    try {
      var r = undoList.removeLast();
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
      redoList.remove(toremove);
      return toremove;
    } catch (e) {
      return null;
    }
  }

  void resetRedo(){
    redoList = [];
  }

  /// Adds a new state into the undoList and restarts the redoList
  void addState(AppState appState, {resetRedo = false}) {
    undoList.add(appState);
    if(resetRedo)
      redoList = [];
  }

}
