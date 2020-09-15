import 'package:ajwah_bloc/ajwah_bloc.dart';
import 'package:rxdart/rxdart.dart';

///[SkinnyStore] is used for constructing an individual state that is totally seperate from
///main `store`. Nither it's action nor effect should propagte to the main stream.
///
///  **Examle**
/// ```dart
///class CounterBloc extends SkinnyStore<CounterModel> {
///  CounterBloc() : super(CounterModel.init());
///
///  @override
///  Stream<CounterModel> mapActionToState(
///    CounterModel state,
///    Action action,
///    Store store,
///  ) async* {
///    switch (action.type) {
///      case ActionTypes.Inc:
///        yield CounterModel.countData(state.count + 1);
///        break;
///      case ActionTypes.Dec:
///        yield CounterModel.countData(state.count - 1);
///        break;
///      case ActionTypes.AsyncInc:
///        yield CounterModel.loading(state.count);
///        break;
///
///      default:
///        yield getState(store);
///    }
///  }
///}
///
///var counterBloc = CounterBloc();
///counterBloc.dispatch(Action(type:ActionType.Inc));
///counterBloc.dispatcH(ActionType.Dec);
///counterBloc.store.listen(print);
///```
class SkinnyStore<T> extends StateBase<T> implements AjwahStore {
  Store _store;
  SkinnyStore(T initialState)
      : super(name: 'singleState', initialState: initialState) {
    _store = createStore(states: [this]);
  }
  @override
  Stream<T> mapActionToState(T state, Action action, Store store) async* {
    yield getState(store);
  }

  Stream<T> get stream => _store.select<T>('singleState');
  T get state => getState(_store);

  void dispatch(Action action) {
    _store.dispatch(action);
  }

  void dispatcH(String actionType, [dynamic payload]) {
    _store.dispatcH(actionType, payload);
  }

  BehaviorSubject<Action> get dispatcher => _store.dispatcher;

  void dispose() {
    _store.dispose();
  }

  ///used to merge two Blocs or Bloc with main store.
  ///
  ///if onActions() method is omitted, merging applied on evey acctions.
  ///
  ///call delay(miliseconds). If you want to wait a while to merge.
  ///
  ///merge a bloc with main store
  ///
  ///```dart
  ///StreamConsumer<String>(
  ///          initialData: "",
  ///          stream: context
  ///              .bloc<CounterBloc>()
  ///              .mergeWith(store.storeInstance())
  ///              .onState(store.select('counter'))
  ///              .onActions(['AsyncInc'])
  ///              .mapEmit((action, state1, state2) =>
  ///                  'sum: ${state1.count + state2.count}'),
  ///          builder: (context, state) => Text(state),
  ///        )
  ///```
  ///
  ///merge a bloc with another bloc (you don't need to call onState when you merging two blocs)
  ///
  ///```dart
  ///
  ///StreamConsumer<String>(
  ///          initialData: "",
  ///          stream: context
  ///              .bloc<BlocA>()
  ///              .mergeWith(context.bloc<Bloc2>())
  ///              .onActions(['AsyncInc'])
  ///              .mapEmit((action, state1, state2) =>
  ///                  'sum: ${state1.count + state2.count}'),
  ///          builder: (context, state) => Text(state),
  ///        )
  ///```
  MergeHelper mergeWith<M2, K extends AjwahStore>(K store) =>
      MergeHelper(this, store);
}

typedef MapCallback<M1, M2, R> = R Function(
    Action action, M1 state1, M2 state2);

class MergeHelper {
  final SkinnyStore store1;
  final dynamic store2;
  MergeHelper(this.store1, this.store2) {
    if (store2 is SkinnyStore) {
      _stream2 = store2.stream;
    }
  }
  List<String> _types;
  Stream _stream2;
  int _milliseconds;
  MergeHelper onActions(List<String> types) {
    _types = types;
    return this;
  }

  ///This function is optional when you merging with another [SkinnyStore].
  ///
  ///Only use this function whenever you going to merge with main store.
  MergeHelper onState(Stream stream) {
    _stream2 = stream;
    return this;
  }

  MergeHelper delay(int milliseconds) {
    _milliseconds = milliseconds;
    return this;
  }

  Stream<R> mapEmit<A, B, R>(MapCallback<A, B, R> callback) {
    if (_stream2 == null) {
      throw 'You missed to call onState(stream) method over mergeWith() function.';
    }
    return store1.dispatcher
        .mergeWith([store2.dispatcher])
        .where((action) => _types == null
            ? true
            : _types.indexWhere((type) => type == action.type) != -1)
        .delay(Duration(milliseconds: _milliseconds ?? 0))
        .withLatestFrom2<A, B, R>(store1.stream, _stream2, callback);
  }
}
