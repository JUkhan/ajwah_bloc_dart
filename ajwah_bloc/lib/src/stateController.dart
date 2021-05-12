import 'package:rxdart/rxdart.dart';
import 'dart:async';
import 'actions.dart';
import 'action.dart';

var _dispatcher = BehaviorSubject<Action>.seeded(Action(type: '@Init'));

void dispatch(Action action) {
  _dispatcher.add(action);
}

var action$ = Actions(_dispatcher);

typedef RemoteStateCallback<S> = void Function(S state);

class RemoteStateAction<S> extends Action {
  final RemoteStateCallback<S> callback;
  final Type controller;
  RemoteStateAction(this.controller, this.callback);
}

abstract class StateController<S> {
  //final String stateName;
  final S initialState;
  BehaviorSubject<S>? __store;
  StreamSubscription<Action>? _subscription;
  StreamSubscription<Action>? _effectSubscription;

  StateController(this.initialState) {
    __store = BehaviorSubject.seeded(initialState);
    _subscription = _dispatcher.listen((action) {
      onAction(_store.value ?? initialState, action);
      if (action is RemoteStateAction && action.controller == runtimeType) {
        action.callback(state);
      }
    });
    //dispatch(Action(type: '@newBornState($stateName)'));

    Future.delayed(Duration(milliseconds: 0)).then((_) => onInit());
  }

  void onAction(S state, Action action) {}
  void onInit() {}

  S get state => _store.value ?? initialState;

  Stream<S> get stream$ => _store.distinct();

  Stream<T> select<T>(T Function(S state) mapCallback) {
    return _store.map<T>(mapCallback).distinct();
  }

  BehaviorSubject<S> get _store =>
      __store ??= BehaviorSubject.seeded(initialState);

  void emit(S newState) {
    _store.add(newState);
  }

  void registerEffects(Iterable<Stream<Action>> callbackList) {
    _effectSubscription?.cancel();
    _effectSubscription = Rx.merge(callbackList).listen(dispatch);
  }

  Stream<List<dynamic>> exportState() =>
      _dispatcher.withLatestFrom(_store, (t, s) => [t, s]);

  void importState(S state) {
    _store.add(state);
    //dispatch(Action(type: '@importState($stateName)'));
  }

  Future<Model> remoteState<ControllerType, Model>() {
    final completer = Completer<Model>();
    dispatch(RemoteStateAction(ControllerType, completer.complete));
    return completer.future;
  }

  void dispose() {
    _subscription?.cancel();
    _effectSubscription?.cancel();
    //_store.close();
  }
}
