import 'package:rxdart/rxdart.dart';
import 'dart:async';
import 'actions.dart';
import 'action.dart';

var _dispatcher = BehaviorSubject<Action>.seeded(Action(type: '@Init'));

var _action$ = Actions(_dispatcher);

typedef RemoteStateCallback<S> = void Function(S state);

class RemoteStateAction<S> extends Action {
  final RemoteStateCallback<S> callback;
  final Type controller;
  RemoteStateAction(this.controller, this.callback);
}

abstract class StateController<S> {
  final S initialState;
  BehaviorSubject<S>? __store;
  StreamSubscription<Action>? _subscription;
  StreamSubscription<Action>? _effectSubscription;

  StateController(this.initialState) {
    __store = BehaviorSubject.seeded(initialState);
    dispatch(Action(type: '@@NewState($runtimeType)'));
    _subscription = _dispatcher.distinct().listen((action) {
      onAction(action);
      if (action is RemoteStateAction && action.controller == runtimeType) {
        action.callback(state);
      }
    });

    Future.delayed(Duration(milliseconds: 0)).then((_) => onInit());
  }

  void onAction(Action action) {}
  void onInit() {}

  void dispatch(Action action) {
    _dispatcher.add(action);
  }

  Actions get action$ => _action$;

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

  void importState(S state) {
    _store.add(state);
  }

  Future<State> remoteState<Controller, State>() {
    final completer = Completer<State>();
    dispatch(RemoteStateAction(Controller, completer.complete));
    return completer.future;
  }

  void dispose() {
    _subscription?.cancel();
    _effectSubscription?.cancel();
    _subscription = null;
    _effectSubscription = null;
  }
}
