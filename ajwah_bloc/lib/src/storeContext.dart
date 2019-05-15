import 'dart:async';

import 'package:async/async.dart';
import 'baseEffect.dart';

import 'effectSubscription.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

import 'store.dart';
import 'action.dart';
import 'baseState.dart';
import 'dispatcher.dart';
import 'actions.dart';

typedef EffectCallback = Observable<Action> Function(
    Actions action$, StoreContext store$);

class StoreContext {
  Dispatcher _dispatcher;
  Actions _actions;
  Store _store;
  Map<String, StreamSubscription<Action>> _subs;
  EffectSubscription _effSub;

  StoreContext(List<BaseState> states) {
    _dispatcher = Dispatcher();
    _actions = Actions(_dispatcher);
    _store = Store(_dispatcher, states);
    _subs = Map<String, StreamSubscription<Action>>();
    _effSub = EffectSubscription(_dispatcher);
  }

  StoreContext dispatch(Action action) {
    _store.dispatch(action);
    return this;
  }

  Observable<T> select<T>({@required String stateName}) {
    assert(stateName != null && stateName.isNotEmpty
        ? true
        : throw 'stateName should not be empty or null.');
    return _store.select(stateName);
  }

  StoreContext addEffect(EffectCallback callback, {@required String key}) {
    removeEffectsByKey(key);
    _subs[key] = callback(_actions, this).listen(_dispatcher.dispatch);
    return this;
  }

  StoreContext removeEffectsByKey(String key) {
    if (_subs.containsKey(key)) {
      _subs[key].cancel();
      _subs.remove(key);
    }
    return this;
  }

  StoreContext addState(BaseState stateInstance) {
    _store.addState(stateInstance);
    return this;
  }

  StoreContext removeStateByStateName(String stateName) {
    _store.removeStateByStateName(stateName);
    return this;
  }

  StoreContext addEffects(BaseEffect effectInstance) {
    var effect = StreamGroup.merge(effectInstance.allEffects(_actions, this))
        .asBroadcastStream();
    if (effectInstance.effectKey == null) {
      _effSub.addEffects(effect);
    } else {
      removeEffectsByKey(effectInstance.effectKey);
      _subs[effectInstance.effectKey] = effect.listen(_dispatcher.dispatch);
    }
    return this;
  }

  dispose() {
    _store.dispose();
    _effSub.dispose();
  }
}
