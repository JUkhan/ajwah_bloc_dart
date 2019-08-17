import 'dart:async';
import 'action.dart';
import 'baseState.dart';
import 'dispatcher.dart';
import 'package:rxdart/rxdart.dart';

class StoreHelper {
  Dispatcher _dispatcher$;
  BehaviorSubject<Map<String, dynamic>> _state$;
  StreamSubscription _subscriptiom;
  List<BaseState> _states;

  StoreHelper(Dispatcher dispatcher, List<BaseState> states) {
    _dispatcher$ = dispatcher;
    _state$ = BehaviorSubject<Map<String, dynamic>>();
    _states = states;
    _subscriptiom = _dispatcher$.streamController
        .scan(
            (state, action, index) => action.type == '@importState'
                ? action.payload
                : _combineStates(state, action),
            Map<String, dynamic>())
        .listen(_state$.add);
  }
  Observable<List<dynamic>> exportState() {
    return _dispatcher$.streamController
        .withLatestFrom(_state$, (a, b) => [a, b]);
  }

  void importState(Map<String, dynamic> state) {
    _states.forEach((s) {
      if (!state.containsKey(s.name)) {
        state[s.name] = s.initialState;
      }
    });
    dispatch(Action(type: '@importState', payload: state));
  }

  void dispatch(Action action) {
    _dispatcher$.streamController.add(action);
  }

  Observable<T> select<T>(String stateName) {
    return _state$.map<T>((dic) => dic[stateName]).distinct();
  }

  Observable<T> select2<T>(T callback(Map<String, dynamic> state)) {
    return _state$.map<T>(callback).distinct();
  }

  /*Map<String, dynamic> _OldcombineStates(
      Map<String, dynamic> state, Action action) {
    _states.forEach((stateObj) {
      state[stateObj.name] = stateObj.reduce(
          state[stateObj.name] == null
              ? stateObj.initialState
              : state[stateObj.name],
          action);
    });
    return state;
  }*/

  Map<String, dynamic> _combineStates(
      Map<String, dynamic> state, Action action) {
    _states.forEach((stateObj) {
      stateObj
          .mapActionToState(
              state[stateObj.name] == null
                  ? stateObj.initialState
                  : state[stateObj.name],
              action)
          .listen((newSubState) {
        if (newSubState != state[stateObj.name]) {
          state[stateObj.name] = newSubState;
          _state$.add(state);
        }
      });
    });
    return state;
  }

  void addState(BaseState state) {
    removeStateByStateName(state.name, false);
    _states.add(state);
    dispatch(Action(type: 'add_state(${state.name})'));
  }

  void removeStateByStateName(String stateName, [bool shouldDispatch = true]) {
    int index = _states.indexWhere((bs) => bs.name == stateName);
    if (index != -1) {
      _states.removeAt(index);
      if (shouldDispatch) {
        dispatch(Action(type: 'remove_state(${stateName})'));
      }
    }
  }

  void dispose() {
    _subscriptiom.cancel();
    _state$.close();
    _dispatcher$.dispose();
  }
}
