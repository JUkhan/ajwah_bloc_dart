import 'package:ajwah_bloc/ajwah_bloc.dart';
import 'package:ajwah_bloc/src/createStore.dart';
import 'package:ajwah_bloc_test/ajwah_bloc_test.dart';

import "package:test/test.dart";

import 'actionTypes.dart';
import 'counterState.dart';

//pub run test test/ajwah_test.dart

void main() {
  Store store;

  setUpAll(() {
    store = createStore(states: [CounterState()]);
  });

  tearDownAll(() {
    store.dispose();
  });

  ajwahTest("initial store should be:{count:0, isLoading:false}",
      build: () => store.select<CounterModel>('counter'),
      expect: [CounterModel.init()]);

  ajwahTest(
      "after dispatch(actionType: ActionTypes.Inc) state should be:{count:1, isLoading:false}",
      build: () => store.select('counter'),
      act: () => store.dispatch(Action(type: ActionTypes.Inc)),
      skip: 1,
      expect: [CounterModel(count: 1, isLoading: false)]);

  ajwahTest(
    "after dispatch(actionType: ActionTypes.Dec) state should be:{count:0, isLoading:false}",
    act: () => store.dispatch(Action(type: ActionTypes.Dec)),
    build: () => store.select<CounterModel>('counter'),
    skip: 1,
    expect: [CounterModel.init()],
  );
}
