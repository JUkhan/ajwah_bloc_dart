import 'package:meta/meta.dart';
import '../ajwah_bloc.dart';

AjwahStore _store;

///This is the entry point of the ajwah store.
///```dart
///final store = createStore();
///```
///[exposeApiGlobally] by default it is `false`. If you pass `true` then global
///functions like storeInstance(), dispatch(), select(), registerState(), etc should be exposed.
///```dart
///createStore(exposeApiGlobally:true);
///```
AjwahStore createStore({bool exposeApiGlobally = false}) {
  var store = AjwahStore();
  if (exposeApiGlobally) {
    _store = store;
  }
  return store;
}

AjwahStore storeInstance() => _store;

///This is a helper function of **store.dispatch(Action action).**
void dispatch(Action action) {
  _store.dispatch(action);
}

///This is a helper function of **store.select(String stateName).**
///
///**Example**
///```daty
///final _counter$ =select('counter')
///```
Stream<T> select<T>(String stateName) {
  try {
    return _store.select<T>(stateName);
  } catch (_) {
    throw 'select() function should not work until you exposeApiGlobally:true inside createStore() function.';
  }
}

///This method is usefull to add a state passing **stateInstance** on demand.
void registerState<S>(
    {@required String stateName,
    @required S initialState,
    @required MapActionToStateCallback<S> mapActionToState}) {
  try {
    _store.registerState(
        stateName: stateName,
        initialState: initialState,
        mapActionToState: mapActionToState);
  } catch (_) {
    throw 'registerState() function should not work until you exposeApiGlobally:true inside createStore() function.';
  }
}
