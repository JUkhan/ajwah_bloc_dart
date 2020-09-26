import 'package:rxdart/subjects.dart';
import 'action.dart';

typedef ActionsFilterCallback = bool Function(Action action);

///used for making effects applying filters on action type(s).
///
///**Example**
///```dart
///Stream<Action> effectForAsyncInc(Actions action$, Store store$) {
///    return action$
///        .whereType(ActionTypes.AsyncInc)
///        .debounceTime(Duration(milliseconds: 550))
///        .mapTo(Action(type: ActionTypes.Inc));
///  }
///```
class Actions {
  final BehaviorSubject<Action> _dispatcher;
  Actions(this._dispatcher);

  ///This function takes **String actionType** param
  ///and apply filter on actionType and return Stream<Action>
  Stream<Action> whereType(String actionType) =>
      _dispatcher.where((action) => action.type == actionType);

  ///This function takes **List<String> actionTypes** param
  ///and apply filter on actionTypes and return Stream<Action>
  Stream<Action> whereTypes(List<String> actionTypes) =>
      _dispatcher.where((action) => actionTypes.contains(action.type));

  Stream<Action> where(ActionsFilterCallback callback) =>
      _dispatcher.where(callback);
}
