import 'dart:async';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'action.dart';
import 'actions.dart';

typedef FilterActionCallback = bool Function(Action state);
typedef EmitStateCallback<S> = void Function(S state);
typedef MapActionToStateCallback<S> = void Function(
  S state,
  Action action,
  EmitStateCallback<S> emit,
);
typedef EffectCallback = Stream<Action> Function(
    Actions action$, AjwahStore store);

class AjwahStore {
  BehaviorSubject<Action> _dispatcher;
  BehaviorSubject<Map<String, dynamic>> _store;
  Map<String, StreamSubscription<Action>> _stateSubscriptions;
  Map<String, StreamSubscription<Action>> _effectSubscriptions;
  Actions _actions;
  AjwahStore() {
    _dispatcher = BehaviorSubject<Action>.seeded(Action(type: '@@INIT'));
    _store = BehaviorSubject<Map<String, dynamic>>.seeded({});
    _actions = Actions(_dispatcher);
    _stateSubscriptions = <String, StreamSubscription<Action>>{};
    _effectSubscriptions = <String, StreamSubscription<Action>>{};
  }
  void registerState<S>(
      {@required String stateName,
      @required S initialState,
      FilterActionCallback filterActions,
      @required MapActionToStateCallback<S> mapActionToState}) {
    if (_store.value.containsKey(stateName)) {
      return;
    }
    _store.value[stateName] = initialState;
    _store.add(_store.value);
    dispatch(Action(type: 'registerState($stateName)'));
    void emitState(S state) {
      if (_store.value[stateName] != state) {
        _store.value[stateName] = state;
        _store.add(_store.value);
      }
    }

    if (filterActions is FilterActionCallback) {
      _stateSubscriptions[stateName] =
          _dispatcher.where(filterActions).listen((action) {
        mapActionToState(_store.value[stateName], action, emitState);
      });
    } else {
      _stateSubscriptions[stateName] = _dispatcher.listen((action) {
        mapActionToState(_store.value[stateName], action, emitState);
      });
    }
  }

  Stream<T> select<T>(String stateName) {
    return _store.map<T>((dic) => dic[stateName]).distinct();
  }

  Stream<T> selectMany<T>(T Function(Map<String, dynamic> state) callback) {
    return _store.map<T>(callback).distinct();
  }

  void dispatch(Action action) {
    _dispatcher.add(action);
  }

  ///This method is usefull to add a single effect passing a callback **(
  ///Actions action$, Store store$)=>Stream** and **effectKey** on demand.
  ///
  ///**Example**
  ///```dart
  ///registerEffect((action$, store$)=>action$
  ///           .whereType(ActionTypes.AsyncInc)
  ///           .debounceTime(Duration(milliseconds: 1000))
  ///           .mapTo(Action(type: ActionTypes.Inc)), effectKey:'any-effectKey');
  ///```
  void registerEffect(EffectCallback callback, {@required String effectKey}) {
    unregisterEffect(effectKey: effectKey);
    _effectSubscriptions[effectKey] = callback(_actions, this).listen(dispatch);
    dispatch(Action(type: 'registerEffect($effectKey)'));
  }

  ///This method is usefull to remove effects passing **effectKey** on demand.
  void unregisterEffect({@required String effectKey}) {
    if (_effectSubscriptions.containsKey(effectKey)) {
      _effectSubscriptions[effectKey].cancel();
      _effectSubscriptions.remove(effectKey);
      dispatch(Action(type: 'unregisterEffect($effectKey)'));
    }
  }

  void unregisterState({@required String stateName}) {
    if (_stateSubscriptions.containsKey(stateName)) {
      _stateSubscriptions[stateName].cancel();
      _stateSubscriptions.remove(stateName);
      _store.value.remove(stateName);
      _store.add(_store.value);
      dispatch(Action(type: 'unregisterState($stateName)'));
    } else if (_store.value.containsKey(stateName)) {
      _store.value.remove(stateName);
      _store.add(_store.value);
      dispatch(Action(type: 'unregisterState($stateName)'));
    }
  }

  BehaviorSubject<Action> get dispatcher => _dispatcher;
  Actions get actions => _actions;
  T getState<T>({@required String stateName}) => _store.value[stateName];

  ///return latest stream of [action, state] array.
  ///
  /// **Example**
  /// ```dart
  ///store.exportState().listen((arr) {
  ///    print((arr[0] as Action).type);
  ///    print(arr[1]);
  ///  });
  /// ```
  Stream<List<dynamic>> exportState() =>
      _dispatcher.withLatestFrom(_store, (t, s) => [t, s]);

  ///state object should be a **Map<String, dynamic> state**
  ///
  /// **Example**
  /// ```dart
  /// var state={'counter':CounterModel(count:5, isLoading:false)};
  /// store.importState(state);
  /// ```
  void importState(Map<String, dynamic> state) {
    _store.add(state);
    dispatch(Action(type: '@importState'));
  }

  ///It's a clean up function.
  void dispose() {
    _stateSubscriptions.forEach((key, value) {
      value.cancel();
    });
    _effectSubscriptions.forEach((key, value) {
      value.cancel();
    });
    _stateSubscriptions.clear();
    _effectSubscriptions.clear();

    _dispatcher.close();
    _store.close();
  }
}
