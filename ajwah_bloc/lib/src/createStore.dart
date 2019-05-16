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
void createStore(
    {@required List<BaseState> states, List<BaseEffect> effects = const []}) {
  _store = Store(states);
  effects.forEach((effect) {
    _store.addEffects(effect);
  });
}

///return **Store** instance.
Store store() {
  return _store;
}

///This is a helper function of **store().dispatch(Action action).**
Store dispatch({@required String actionType, dynamic payload}) {
  return _store.dispatch(Action(type: actionType, payload: payload));
}
