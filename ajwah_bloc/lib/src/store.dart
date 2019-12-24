import 'dart:async';
import 'baseEffect.dart';
import 'effectSubscription.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'storeHelper.dart';
import 'action.dart';
import 'baseState.dart';
import 'dispatcher.dart';
import 'actions.dart';

typedef EffectCallback = Stream<Action> Function(Actions action$, Store store$);

///A comfortable way to develop reactive widgets. You can dynamically add or remove effects and states and many more.
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

  ///This method takes a callback which has a single **Map<String, dynamic>** type arg.
  ///If you pass Map key as a state name then you will get corresponding model instance
  /// as value.
  ///
  /// **Example**
  /// ```dart
  /// final _message$ = store
  ///    .select2<TodoModel>((states) => states['todo'])
  ///    .map((tm) => tm.message)
  ///    .distinct();
  /// ```
  /// Note: You can take any combination from the overall application's state.
  Stream<T> select2<T>(T callback(Map<String, dynamic> state)) {
    return _storeHelper.select2(callback);
  }

  ///This method takes a single param **String stateName** and return Stream/Stream
  ///
  ///**Example**
  ///```daty
  ///store.select('counter')
  ///```
  Stream<T> select<T>(String stateName) {
    return _storeHelper.select<T>(stateName);
  }

  ///This method is usefull to add a single effect passing a callback **(
  ///Actions action$, Store store$)=>Stream** and **effectKey** on demand.
  ///
  ///**Example**
  ///```dart
  ///store.addEffect((action$, store$)=>action$
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
    var effect = MergeStream(effectInstance.registerEffects(_actions, this))
        .asBroadcastStream();
    if (effectInstance.effectKey == null) {
      _effSub.addEffects(effect);
    } else {
      removeEffectsByKey(effectInstance.effectKey);
      _subs[effectInstance.effectKey] = effect.listen(_dispatcher.dispatch);
    }
    return this;
  }

  ///return latest stream of [action, state] array.
  ///
  /// **Example**
  /// ```dart
  ///store.exportState().listen((arr) {
  ///    print((arr[0] as Action).type);
  ///    print(arr[1]);
  ///  });
  /// ```
  Stream<List<dynamic>> exportState() {
    return _storeHelper.exportState();
  }

  ///state object should be a **Map<String, dynamic> state**
  ///
  /// **Example**
  /// ```dart
  /// var state={'counter':CounterModel(count:5, isLoading:false)};
  /// store.importState(state);
  /// ```
  void importState(Map<String, dynamic> state) {
    _storeHelper.importState(state);
  }

  ///It's a clean up function.
  dispose() {
    _storeHelper.dispose();
    _effSub.dispose();
  }
}
