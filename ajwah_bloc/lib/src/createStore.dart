import 'package:meta/meta.dart';
import 'storeContext.dart';
import 'baseEffect.dart';
import 'baseState.dart';
import 'action.dart';

StoreContext _store;
void createStore(
    {@required List<BaseState> states, List<BaseEffect> effects = const []}) {
  _store = StoreContext(states);
  effects.forEach((effect) {
    _store.addEffects(effect);
  });
}

StoreContext store() {
  return _store;
}

StoreContext dispatch({@required String actionType, dynamic payload}) {
  return _store.dispatch(Action(type: actionType, payload: payload));
}
