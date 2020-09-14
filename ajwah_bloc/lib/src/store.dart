import 'dart:async';
import 'effectBase.dart';
import 'effectSubscription.dart';
import 'package:rxdart/rxdart.dart';
import 'action.dart';
import 'stateBase.dart';
import 'actions.dart';

typedef EffectCallback = Stream<Action> Function(Actions action$, Store store$);

///A comfortable way to develop reactive widgets. You can dynamically add or remove effects and states and many more.
class Store {
  BehaviorSubject<Action> _dispatcher;
  BehaviorSubject<Map<String, dynamic>> _store;
  Actions _actions;
  Map<String, StreamSubscription<Action>> _subs;
  EffectSubscription _effSub;
  List<StateBase> _states;
  Action _action = Action(type: '@@INIT');
  StreamSubscription _dispatcherSubscription;

  Store(List<StateBase> states) {
    _dispatcher = BehaviorSubject<Action>.seeded(_action);
    _states = states;
    _store = BehaviorSubject<Map<String, dynamic>>.seeded(_initialState());
    _actions = Actions(_dispatcher);
    _subs = Map<String, StreamSubscription<Action>>();
    _effSub = EffectSubscription(_dispatcher);
    _dispatcherSubscription = _dispatcher.listen((action) {
      _combineStates(_store.value, action);
    });
  }
  Map<String, dynamic> _initialState() {
    Map<String, dynamic> state = Map<String, dynamic>();
    for (var item in _states) {
      state[item.name] = item.initialState;
    }
    return state;
  }

  void _combineStates(Map<String, dynamic> state, Action action) {
    _states.forEach((stateObj) {
      stateObj
          .mapActionToState(
              state[stateObj.name] ?? stateObj.initialState, action, this)
          .listen((newSubState) {
        if (newSubState != state[stateObj.name]) {
          state[stateObj.name] = newSubState;
          _action = action;
          _store.add(state);
        }
      });
    });
  }

  get value => _store.value;

  void dispatch(Action action) {
    _dispatcher.add(action);
  }

  void dispatcH(String actionType, [dynamic payload]) {
    _dispatcher.add(Action(type: actionType, payload: payload));
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
  Stream<T> selectMany<T>(T callback(Map<String, dynamic> state)) {
    return _store.map<T>(callback).distinct();
  }

  ///This method takes a single param **String stateName** and return Stream/Stream
  ///
  ///**Example**
  ///```daty
  ///store.select('counter')
  ///```
  Stream<T> select<T>(String stateName) {
    return _store.map<T>((dic) => dic[stateName]).distinct();
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
    removeEffectsByKey(effectKey);
    _subs[effectKey] = callback(_actions, this).listen(dispatch);
  }

  ///This method is usefull to remove effects passing **effectKey** on demand.
  void removeEffectsByKey(String effectKey) {
    if (_subs.containsKey(effectKey)) {
      _subs[effectKey].cancel();
      _subs.remove(effectKey);
    }
  }

  ///This method is usefull to add a state passing **stateInstance** on demand.
  void addState(StateBase stateInstance) {
    removeStateByStateName(stateInstance.name, false);
    _states.add(stateInstance);
    dispatch(Action(type: 'add_state(${stateInstance.name})'));
  }

  ///This method is usefull to remove a state passing **stateName** on demand.
  void removeStateByStateName(String stateName, [bool shouldDispatch = true]) {
    var index = _states.indexWhere((bs) => bs.name == stateName);
    if (index != -1) {
      _states.removeAt(index);
      if (shouldDispatch) {
        //dispatch(Action(type: 'remove_state(${stateName})'));
        _action = Action(type: 'remove_state(${stateName})');
        var state = value;
        state.remove(stateName);
        _store.add(state);
      }
    }
  }

  ///This method is usefull to add effects passing **effectInstance** on demand.
  void addEffects(EffectBase effectInstance) {
    var effect = MergeStream(effectInstance.registerEffects(_actions, this))
        .asBroadcastStream();
    if (effectInstance.effectKey == null) {
      _effSub.addEffects(effect);
    } else {
      removeEffectsByKey(effectInstance.effectKey);
      _subs[effectInstance.effectKey] = effect.listen(dispatch);
    }
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
    return _store.map((state) => [_action, state]);
  }

  ///state object should be a **Map<String, dynamic> state**
  ///
  /// **Example**
  /// ```dart
  /// var state={'counter':CounterModel(count:5, isLoading:false)};
  /// store.importState(state);
  /// ```
  void importState(Map<String, dynamic> state) {
    _states.forEach((s) {
      if (!state.containsKey(s.name)) {
        state[s.name] = s.initialState;
      }
    });
    _action = Action(type: '@importState');
    _store.add(state);
  }

  ///It's a clean up function.
  void dispose() {
    _subs.forEach((key, value) {
      value.cancel();
    });
    _effSub.dispose();
    _dispatcherSubscription.cancel();
    _dispatcher.close();
    _store.close();
  }
}
