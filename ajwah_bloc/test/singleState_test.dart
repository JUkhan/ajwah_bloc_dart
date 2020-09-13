import 'package:ajwah_bloc/ajwah_bloc.dart';

import 'package:ajwah_bloc_test/ajwah_bloc_test.dart';
import 'package:test/test.dart';

import 'actionTypes.dart';
import 'counterState.dart';

class CounterBloc extends SkinnyStore<CounterModel> {
  CounterBloc() : super(CounterModel.init());

  @override
  Stream<CounterModel> mapActionToState(
    CounterModel state,
    Action action,
    Store store,
  ) async* {
    switch (action.type) {
      case ActionTypes.Inc:
        yield CounterModel.countData(state.count + 1);
        break;
      case ActionTypes.Dec:
        yield CounterModel.countData(state.count - 1);
        break;
      case ActionTypes.AsyncInc:
        yield CounterModel.loading(state.count);
        break;

      default:
        yield getState(store);
    }
  }
}

void main() {
  CounterBloc store;

  setUpAll(() {
    store = CounterBloc();
  });

  tearDownAll(() {
    store.dispose();
  });

  ajwahTest("initial store should be:{count:0, isLoading:false}",
      build: () => store.stream, expect: [CounterModel.init()]);

  ajwahTest(
      "after dispatch(actionType: ActionTypes.Inc) state should be:{count:1, isLoading:false}",
      build: () => store.stream,
      act: () => store.dispatcH(ActionTypes.Inc),
      skip: 1,
      expect: [CounterModel(count: 1, isLoading: false)]);

  ajwahTest(
    "after dispatch(actionType: ActionTypes.Dec) state should be:{count:0, isLoading:false}",
    act: () => store.dispatcH(ActionTypes.Dec),
    build: () => store.stream,
    skip: 1,
    expect: [CounterModel.init()],
  );
}
