import 'dart:async';

import 'package:async/async.dart';
import 'baseEffect.dart';

import 'effectSubscription.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

import 'storeHelper.dart';
import 'action.dart';
import 'baseState.dart';
import 'dispatcher.dart';
import 'actions.dart';

typedef EffectCallback = Observable<Action> Function(
    Actions action$, Store store$);

class Store {
  Dispatcher _dispatcher;
  Actions _actions;
  StoreHelper _storeHelper;
  Map<String, StreamSubscription<Action>> _subs;
  EffectSubscription _effSub;

  Store(List<BaseState> states) {
    _dispatcher = Dispatcher();
    _actions = Actions(_dispatcher);
    _storeHelper = StoreHelper(_dispatcher, states);
    _subs = Map<String, StreamSubscription<Action>>();
    _effSub = EffectSubscription(_dispatcher);
  }

  Store dispatch(Action action) {
    _storeHelper.dispatch(action);
    return this;
  }

  ///This method takes a single param **String stateName** and return Observable/Stream
  Observable<T> select<T>({@required String stateName}) {
    return _storeHelper.select(stateName);
  }

  ///This method is usefull to add a single effect passing a callback **(
  ///Actions action$, Store store$)=>Observable** and **effectKey** on demand.
  ///
  ///**Example**
  ///```dart
  ///store().addEffect((action$, store$)=>action$
  ///           .ofType(ActionTypes.AsyncInc)
  ///           .debounceTime(Duration(milliseconds: 1000))
  ///           .mapTo(Action(type: ActionTypes.Inc)), 'any-effectKey');
  ///```
  Store addEffect(EffectCallback callback, {@required String effectKey}) {
    removeEffectsByKey(effectKey);
    _subs[effectKey] = callback(_actions, this).listen(_dispatcher.dispatch);
    return this;
  }

  ///This method is usefull to remove effects passing **effectKey** on demand.
  Store removeEffectsByKey(String effectKey) {
    if (_subs.containsKey(effectKey)) {
      _subs[effectKey].cancel();
      _subs.remove(effectKey);
    }
    return this;
  }

  ///This method is usefull to add a state passing **stateInstance** on demand.
  Store addState(BaseState stateInstance) {
    _storeHelper.addState(stateInstance);
    return this;
  }

  ///This method is usefull to remove a state passing **stateName** on demand.
  Store removeStateByStateName(String stateName) {
    _storeHelper.removeStateByStateName(stateName);
    return this;
  }

  ///This method is usefull to add effects passing **effectInstance** on demand.
  Store addEffects(BaseEffect effectInstance) {
    var effect =
        StreamGroup.merge(effectInstance.registerEffects(_actions, this))
            .asBroadcastStream();
    if (effectInstance.effectKey == null) {
      _effSub.addEffects(effect);
    } else {
      removeEffectsByKey(effectInstance.effectKey);
      _subs[effectInstance.effectKey] = effect.listen(_dispatcher.dispatch);
    }
    return this;
  }

  ///It's a clean up function.
  dispose() {
    _storeHelper.dispose();
    _effSub.dispose();
  }
}
