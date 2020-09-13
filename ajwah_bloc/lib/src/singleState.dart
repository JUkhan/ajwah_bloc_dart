import 'package:ajwah_bloc/ajwah_bloc.dart';

import 'baseState.dart';
import 'store.dart';
import 'createStore.dart';

///[SingleState] is used for constructing an individual state that is totally seperate from
///main `store`. Nither it's action nor effect should propagte to the main stream.
///
///  **Examle**
/// ```dart
///class CounterBloc extends SingleState<CounterModel> {
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
class SingleState<T> extends BaseState<T> {
  Store _store;
  SingleState(T initialState)
      : super(name: 'singleState', initialState: initialState) {
    _store = createStore(states: [this]);
  }
  @override
  Stream<T> mapActionToState(T state, Action action, Store store) async* {
    yield getState(store);
  }

  Stream<T> get stream => _store.select<T>('singleState');

  void dispatch(Action action) {
    _store.dispatch(action);
  }

  void dispatcH(String actionType, [dynamic payload]) {
    _store.dispatcH(actionType, payload);
  }

  void dispose() {
    _store.dispose();
  }
}
