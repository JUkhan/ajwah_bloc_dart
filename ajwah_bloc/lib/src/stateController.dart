import 'package:rxdart/rxdart.dart';
import 'package:meta/meta.dart';
import 'dart:async';
import 'actions.dart';
import 'action.dart';

var _dispatcher = BehaviorSubject<Action>.seeded(Action(type: '@Init'));

var _action$ = Actions(_dispatcher);

typedef RemoteStateCallback<S> = void Function(S state);

class _RemoteStateAction<S> extends Action {
  final Completer<S> completer;
  final Type controller;
  _RemoteStateAction(this.controller, this.completer);
}

class _RemoteControllerAction<S> extends Action {
  final Completer<S> completer;
  final Type controller;
  _RemoteControllerAction(this.controller, this.completer);
}

///Every [StateController] has the following features:
///- Dispatching actions
///- Filtering actions
///- Can make mulltiple effeccts
///- Communication to other controllers
///- RxDart full features
///
///Every [StateController] requires an initial state which will be the state of the [StateController] before [emit] has been called.
///
///The current state of a [StateController] can be accessed via the [state] getter.
///```dart
///class CounterState extends StateController<int>{
///
///    CounterState():super(0);
///
///     void increment() => emit(state + 1);
///
///     void decrement() => emit(state - 1);
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
    });

    Future.delayed(Duration(milliseconds: 0)).then((_) => onInit());
  }

  ///This function fired when action dispatches from the `controllers`.
  @protected
  @mustCallSuper
  void onAction(Action action) {
    if (action is _RemoteStateAction &&
        action.controller == runtimeType &&
        !action.completer.isCompleted) {
      action.completer.complete(state);
    } else if (action is _RemoteControllerAction &&
        action.controller == runtimeType &&
        !action.completer.isCompleted) {
      action.completer.complete(this);
    }
  }

  ///This function is fired after instantiating the controller.
  @protected
  void onInit() {}

  ///Dispatching an action is just like firing an event.
  ///
  ///When the action dispatches, it notifies all the `Controllers`
  ///those who override the `onAction(action Action)` method and also
  ///notifes all the effects - registered throughout the `Controllers`.
  ///
  void dispatch(Action action) {
    _dispatcher.add(action);
  }

  ///Return a `Acctions` instance.
  ///
  ///You can filter the actions those are dispatches throughout
  ///the application. And also making effect/s on it.
  ///
  Actions get action$ => _action$;

  ///Return the current state of the controller.
  S get state => _store.value;

  ///Return the current state of the controller as a Stream\<S\>.
  Stream<S> get stream$ => _store.distinct();

  ///Return the part of the current state of the controller as a Stream\<S\>.
  Stream<T> select<T>(T Function(S state) mapCallback) {
    return _store.map<T>(mapCallback).distinct();
  }

  BehaviorSubject<S> get _store => __store ??= BehaviorSubject.seeded(state);

  /// Sends a data [newState].
  ///
  /// Listeners receive this newState in a later microtask.
  @protected
  void emit(S newState) {
    _store.add(newState);
  }

  ///This function registers the effect/s and also
  ///un-registers previous effeccts (if found any).
  ///
  /// [streams] param for one or more effects.
  ///
  /// `Example of todos search effect:`
  ///
  /// This effect start working when `SearchInputAction` is dispatched
  /// then wait 320 mills to receive subsequent actions(`SearchInputAction`) -
  /// when reach out time limit it sends a request to server and then dispatches
  ///`SearchResultAction` when server response come back. Now any `Controller` can
  /// receive `SearchResultAction` who override `onAction` method / you can use
  /// action$.isA\<SearchResultAction\>().
  ///
  /// ```dart
  /// registerEffects([
  ///   action$.isA<SearchInputAction>()
  ///   .debounceTime(const Duration(milliseconds: 320))
  ///   .switchMap((action) => pullData(action.searchText))
  ///   .map((res) => SearchResultAction(res)),
  /// ]);
  /// ```
  @protected
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

  ///This function returns the current state of a cubit as a `Future` value
  ///
  ///`Example`
  ///
  ///```dart
  ///final category = await remoteState<SearchCategoryCubit, SearchCategory>();
  ///```
  ///
  @protected
  Future<State> remoteState<Controller, State>() {
    final completer = Completer<State>();
    dispatch(_RemoteStateAction(Controller, completer));

    return completer.future;
  }

  ///This function returns `Controller` instance as a Steam based on the type
  ///you attached with the function.
  ///
  ///`Example`
  ///
  ///This example returns todo list filtered by searchCategory.
  ///We need `SearchCategoryController` stream combining with `TodoContrroller's` stream:
  ///```dart
  ///Stream<List<Todo>> get todo$ =>
  ///    Rx.combineLates2<List<Todo>, SearchCategory, List<Todo>>(
  ///        stream$, remoteCubit<SearchCategoryController>()
  ///         .flatMap((event) => event.stream$),(todos, category) {
  ///      switch (category) {
  ///        case SearchCategory.Active:
  ///          return todos.where((todo) => !todo.completed).toList();
  ///        case SearchCategory.Completed:
  ///          return todos.where((todo) => todo.completed).toList();
  ///        default:
  ///          return todos;
  ///     }
  ///    });
  ///```
  ///
  @protected
  Stream<Controller> remoteController<Controller>() {
    final completer = Completer<Controller>();
    dispatch(_RemoteControllerAction(Controller, completer));
    return Stream.fromFuture(completer.future);
  }

  ///This is a clean up funcction.
  ///
  void dispose() {
    _subscription?.cancel();
    _effectSubscription?.cancel();
    _subscription = null;
    _effectSubscription = null;
  }
}
