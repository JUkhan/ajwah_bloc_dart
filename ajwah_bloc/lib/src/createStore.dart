import 'package:meta/meta.dart';
import 'store.dart';
import 'baseEffect.dart';
import 'baseState.dart';
import 'action.dart';

Store _store;

///This is the entry point of the ajwah store.
///You may pass necessay states and effects through this method.
///Also you can dynamically **add** or **remove** state and effect
///using **addState(BaseState stateInstance)** ,**removeStateByStateName(String stateName)**,
///**addEffects(BaseEffect effectInstance)**, **addEffect(EffectCallback callback, {@required String key})**, **removeEffectsByKey(String key)**
Store createStore(
    {@required List<BaseState> states, List<BaseEffect> effects = const []}) {
  _store = Store(states);
  effects.forEach((effect) {
    _store.addEffects(effect);
  });
  return _store;
}

///return **Store** instance.
Store store() {
  return _store;
}

///This is a helper function of **store().dispatch(Action action).**
Store dispatch(String actionType, [dynamic payload]) {
  return _store.dispatch(Action(type: actionType, payload: payload));
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
