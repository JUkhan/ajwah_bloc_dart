import 'store.dart';
import 'effectBase.dart';
import 'stateBase.dart';
import 'action.dart';

Store _store;

///This is the entry point of the ajwah store.
///
///[states] is a mandatory param. And it should not be null or empty.
///
///[effects] is an optional param.
///
///[exposeApiGlobally] by default it is `false`. If you pass `true` then global
///functions like dispatch(), select() etc should be exposed.
///
///Also you can dynamically **add** or **remove** state and effect
///using **addState(BaseState stateInstance)** ,**removeStateByStateName(String stateName)**,
///**addEffects(BaseEffect effectInstance)**, **addEffect(EffectCallback callback, {@required String key})**, **removeEffectsByKey(String key)**
Store createStore(
    {List<StateBase> states,
    List<EffectBase> effects = const [],
    bool exposeApiGlobally = false}) {
  assert(states != null && states.length > 0
      ? true
      : throw 'states should not be null or empty.');

  var store = Store(states);

  effects.forEach((effect) {
    store.addEffects(effect);
  });
  if (exposeApiGlobally) {
    _store = store;
  }
  return store;
}

Store storeInstance() => _store;

///This is a helper function of **store.dispatch(Action action).**
void dispatch(Action action) {
  _store.dispatch(action);
}

///This is a helper function of **store.dispatcH(String actionType, [dynamic payload]).**
void dispatcH(String actionType, [dynamic payload]) {
  _store.dispatcH(actionType, payload);
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
    throw "select() function should not work until you exposeApiGlobally:true inside createStore() function.";
  }
}

///This method takes a callback which has a single **Map<String, dynamic>** type arg.
///If you pass Map key as a state name then you will get corresponding model instance
/// as value.
///
/// **Example**
/// ```dart
/// final _message$ = select2<TodoModel>((states) => states['todo'])
///    .map((tm) => tm.message)
///    .distinct();
/// ```
/// Note: You can take any combination from the overall application's state.
Stream<T> selectMany<T>(T callback(Map<String, dynamic> state)) {
  return _store.selectMany(callback);
}

///This method is usefull to remove effects passing **effectKey** on demand.
void removeEffectsByKey(String effectKey) {
  _store.removeEffectsByKey(effectKey);
}

///This method is usefull to add a state passing **stateInstance** on demand.
void addState(StateBase stateInstance) {
  _store.addState(stateInstance);
}

///This method is usefull to remove a state passing **stateName** on demand.
void removeStateByStateName(String stateName) {
  _store.removeStateByStateName(stateName);
}

///This method is usefull to add effects passing **effectInstance** on demand.
void addEffects(EffectBase effectInstance) {
  _store.addEffects(effectInstance);
}

///return latest stream of [action, state] array.
///
/// **Example**
/// ```dart
///exportState().listen((arr) {
///    print((arr[0] as Action).type);
///    print(arr[1]);
///  });
/// ```
Stream<List<dynamic>> exportState() {
  return _store.exportState();
}

///state object should be a **Map<String, dynamic> state**
///
/// **Example**
/// ```dart
/// var state={'counter':CounterModel(count:5, isLoading:false)};
/// importState(state);
/// ```
void importState(Map<String, dynamic> state) {
  _store.importState(state);
}

///This method is usefull to add a single effect passing a callback **(
///Actions action$, Store store$)=>Stream** and **effectKey** on demand.
///
///**Example**
///```dart
///addEffect((action$, store$)=>action$
///           .whereType(ActionTypes.AsyncInc)
///           .debounceTime(Duration(milliseconds: 1000))
///           .mapTo(Action(type: ActionTypes.Inc)), 'any-effectKey');
///```
void addEffect(EffectCallback callback, {String effectKey}) {
  _store.addEffect(callback, effectKey: effectKey);
}
