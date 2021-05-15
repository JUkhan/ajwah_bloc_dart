import 'package:rxdart/rxdart.dart';
import 'dart:async';
import 'actions.dart';
import 'action.dart';

var _dispatcher = BehaviorSubject<Action>.seeded(Action(type: '@Init'));

var _action$ = Actions(_dispatcher);

// typedef RemoteStateCallback<S> = void Function(S state);

// class RemoteStateAction<S> extends Action {
//   final RemoteStateCallback<S> callback;
//   final Type controller;
//   RemoteStateAction(this.controller, this.callback);
// }

///[StateController] abstract class
///
///That is used to develop a powerful concrete state controller class.
///
///So that you can manage your application's state easy and comportable way.
///Spliting chunk of them as the controllers and having communication among them.
///
///```dart
///class CounterState extends StateController<int>{
///
///    CounterState():super(0);
///
///     increment(){
///       emit(state + 1);
///     }
///
///     decrement(){
///       emit(state - 1);
///     }
///
///}
///
///```
abstract class StateController<S> {
  BehaviorSubject<S>? __store;
  StreamSubscription<Action>? _subscription;
  StreamSubscription<Action>? _effectSubscription;

  StateController(S initialState) {
    __store = BehaviorSubject.seeded(initialState);
    dispatch(Action(type: '@@NewState($runtimeType)'));
    _subscription = _dispatcher.distinct().listen((action) {
      onAction(action);
      // if (action is RemoteStateAction && action.controller == runtimeType) {
      //   action.callback(state);
      // }
    });

    Future.delayed(Duration(milliseconds: 0)).then((_) => onInit());
  }

  ///This function is fired whenever action dispatched from the controllers.
  void onAction(Action action) {}

  ///This function is fired after instantiating the controller.
  void onInit() {}

  ///Dispatching an action is just like firing an event.
  ///
  ///Whenever the acction is dispatched it notifies all the controllers
  ///those who override the [onAction(action Action)] method and also
  ///notifes all the effects - registered throughout the controllers.
  ///
  ///A powerful way to communicate among the controllers.
  void dispatch(Action action) {
    _dispatcher.add(action);
  }

  ///Return a [Acctions] instance.
  ///
  ///So that you can filter the actions those are dispatches throughout
  ///the application. And also making effect/s on it.
  ///
  Actions get action$ => _action$;

  //Return the current state of the controller.
  S get state => _store.value;

  ///Return the current state of the controller as a Stream<S>.
  Stream<S> get stream$ => _store.distinct();

  ///Return the part of the current state of the controller as a Stream<S>, based on your projection.
  Stream<T> select<T>(T Function(S state) mapCallback) {
    return _store.map<T>(mapCallback).distinct();
  }

  BehaviorSubject<S> get _store => __store ??= BehaviorSubject.seeded(state);

  /// Sends a data [newState].
  ///
  /// Listeners receive this newState in a later microtask.
  void emit(S newState) {
    _store.add(newState);
  }

  /// [streams] pass one or more effects.
  ///
  ///This function registers the effect/s and also
  ///un-registers previous effeccts (if found any).
  ///
  /// Here is an example of a search effect:
  ///
  /// This effect start working when SearchInputAction is dispatched
  /// then wait 320 mills to receive subsequent actions(SearchInputAction) -
  /// when reach out time limit it sends a request to server and then dispatches
  /// [SearchResultAction] when server response come back. Now any controller can
  /// receive SearchResultAction who override [onAction] method.
  ///
  /// ```dart
  /// registerEffects([
  ///   action$.isA<SearchInputAction>()
  ///   .debounceTime(const Duration(milliseconds: 320))
  ///   .switchMap((action) => pullData(action.searchText))
  ///   .map((res) => SearchResultAction(res)),
  /// ]);
  /// ```
  void registerEffects(Iterable<Stream<Action>> streams) {
    _effectSubscription?.cancel();
    _effectSubscription = Rx.merge(streams).listen(dispatch);
  }

  ///Sends a data [newState].
  ///
  /// Listeners receive this newState in a later microtask.
  void importState(S newState) {
    _store.add(newState);
  }

  // Future<State> remoteState<Controller, State>() {
  //   final completer = Completer<State>();
  //   dispatch(RemoteStateAction(Controller, completer.complete));
  //   return completer.future;
  // }

  ///This is a clean up funcction.
  ///
  void dispose() {
    _subscription?.cancel();
    _effectSubscription?.cancel();
    _subscription = null;
    _effectSubscription = null;
  }
}
