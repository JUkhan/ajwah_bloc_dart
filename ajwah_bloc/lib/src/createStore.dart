import 'store.dart';
import 'baseEffect.dart';
import 'baseState.dart';
import 'action.dart';

Store _store;

///This is the entry point of the ajwah store.
///You may pass necessay states and effects is optional.
///Also you can dynamically **add** or **remove** state and effect
///using **addState(BaseState stateInstance)** ,**removeStateByStateName(String stateName)**,
///**addEffects(BaseEffect effectInstance)**, **addEffect(EffectCallback callback, {@required String key})**, **removeEffectsByKey(String key)**
createStore(
    {List<BaseState> states,
    List<BaseEffect> effects = const [],
    bool block = false}) {
  var fx = () {
    _store = Store(states);
    Future.delayed(Duration(seconds: 5));
    effects.forEach((effect) {
      _store.addEffects(effect);
    });
    return _store;
  };
  return block ? fx() : Future.microtask(fx);
}

///return **Store** instance.
Store getStore() {
  return _store;
}

///This is a helper function of **store().dispatch(Action action).**
void dispatch(String actionType, [dynamic payload]) {
  _store.dispatch(Action(type: actionType, payload: payload));
}

///This is a helper function of **store().select(String stateName).**
///
///**Example**
///```daty
///final _counter$ =select('counter')
///```
Stream<T> select<T>(String stateName) {
  return _store.select<T>(stateName);
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
Stream<T> select2<T>(T callback(Map<String, dynamic> state)) {
  return _store.select2(callback);
}

///This method is usefull to remove effects passing **effectKey** on demand.
void removeEffectsByKey(String effectKey) {
  _store.removeEffectsByKey(effectKey);
}

///This method is usefull to add a state passing **stateInstance** on demand.
void addState(BaseState stateInstance) {
  _store.addState(stateInstance);
}

///This method is usefull to remove a state passing **stateName** on demand.
void removeStateByStateName(String stateName) {
  _store.removeStateByStateName(stateName);
}

///This method is usefull to add effects passing **effectInstance** on demand.
void addEffects(BaseEffect effectInstance) {
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
