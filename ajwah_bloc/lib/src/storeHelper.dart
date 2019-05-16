import 'dart:async';

import 'action.dart';
import 'baseState.dart';
import 'dispatcher.dart';
import 'package:rxdart/rxdart.dart';

class StoreHelper {
  Dispatcher _dispatcher;
  BehaviorSubject<Map<String, dynamic>> _state;
  StreamSubscription _subscriptiom;
  List<BaseState> _states;

  StoreHelper(Dispatcher dispatcher, List<BaseState> states) {
    _dispatcher = dispatcher;
    _state = BehaviorSubject<Map<String, dynamic>>();
    _states = states;
    _subscriptiom = _dispatcher.streamController
        .scan((state, action, index) => _combineStates(state, action),
            Map<String, dynamic>())
        .listen((nextState) {
      print(nextState);
      _state.add(nextState);
    });
  }

  void dispatch(Action action) {
    _dispatcher.streamController.add(action);
  }

  Observable<T> select<T>(String stateName) {
    return _state.map<T>((dic) => dic[stateName]).distinct();
  }

  Map<String, dynamic> _combineStates(
      Map<String, dynamic> state, Action action) {
    _states.forEach((stateObj) {
      state[stateObj.name] = stateObj.reduce(
          state[stateObj.name] == null
              ? stateObj.initialState
              : state[stateObj.name],
          action);
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
    _state.close();
    _dispatcher.dispose();
  }
}
