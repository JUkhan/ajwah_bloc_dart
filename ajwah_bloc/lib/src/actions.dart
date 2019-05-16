import 'dispatcher.dart';
import 'action.dart';
import 'package:rxdart/rxdart.dart';

///used for making effects applying filters on action type(s).
///
///**Example**
///```dart
///Observable<Action> effectForAsyncInc(Actions action$, Store store$) {
///    return action$
///        .ofType(ActionTypes.AsyncInc)
///        .debounceTime(Duration(milliseconds: 550))
///        .mapTo(Action(type: ActionTypes.Inc));
///  }
///```
class Actions {
  final Dispatcher _dispatcher;
  Actions(this._dispatcher);

  ///This function takes **String actionType** param
  ///and apply filter on actionType and return Observable<Action>
  Observable<Action> ofType(String actionType) {
    return _dispatcher.streamController
        .where((action) => action.type == actionType);
  }

  ///This function takes **List<String> actionTypes** param
  ///and apply filter on actionTypes and return Observable<Action>
  Observable<Action> ofTypes(List<String> actionTypes) {
    return _dispatcher.streamController.where((action) =>
        actionTypes.indexWhere((type) => type == action.type) != -1);
  }
}
