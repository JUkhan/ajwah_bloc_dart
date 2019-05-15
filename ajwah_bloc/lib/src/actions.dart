import 'dispatcher.dart';
import 'action.dart';
import 'package:rxdart/rxdart.dart';

class Actions {
  final Dispatcher _dispatcher;
  Actions(this._dispatcher);
  Observable<Action> ofType(String actionType) {
    return _dispatcher.streamController
        .where((action) => action.type == actionType);
  }

  Observable<Action> ofTypes(List<String> actionTypes) {
    return _dispatcher.streamController.where((action) =>
        actionTypes.indexWhere((type) => type == action.type) != -1);
  }
}
