import 'package:rxdart/subjects.dart';
import 'action.dart';

typedef ActionsFilterCallback = bool Function(Action action);

class Actions {
  final BehaviorSubject<Action> _dispatcher;
  Actions(this._dispatcher);

  Stream<Action> whereType(String actionType) =>
      _dispatcher.where((action) => action.type == actionType);

  Stream<Action> whereTypes(List<String> actionTypes) =>
      _dispatcher.where((action) => actionTypes.contains(action.type));

  Stream<Action> where(ActionsFilterCallback callback) =>
      _dispatcher.where(callback);
}
