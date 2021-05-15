import 'package:rxdart/subjects.dart';
import 'action.dart';

typedef ActionsFilterCallback = bool Function(Action action);

///[Actions] used to filter the action.
///
///It has four different filter methods -isA(), whereType(), whereTypes(), and where()
class Actions {
  final BehaviorSubject<Action> _dispatcher;
  Actions(this._dispatcher);

  ///```dart
  ///action$.isA<SearchInputAcction>()
  ///```
  Stream<T> isA<T>() => _dispatcher
      .where((action) => action is T)
      .map<T>((action) => action as T);

  ///```dart
  ///action$.whereType('foo')
  ///```
  Stream<Action> whereType(String actionType) =>
      _dispatcher.where((action) => action.type == actionType);

  ///```dart
  ///action$.whereTypes(['foo', 'bar'])
  ///```
  Stream<Action> whereTypes(List<String> actionTypes) =>
      _dispatcher.where((action) => actionTypes.contains(action.type));

  ///```dart
  ///action$.where((action)=>action.type=='foo')
  ///```
  Stream<Action> where(ActionsFilterCallback callback) =>
      _dispatcher.where(callback);
}
