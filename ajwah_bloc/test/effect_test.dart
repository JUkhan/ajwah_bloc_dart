import 'package:ajwah_bloc/ajwah_bloc.dart';
import 'package:ajwah_bloc/src/createStore.dart';
import 'package:ajwah_bloc_test/ajwah_bloc_test.dart';

import "package:test/test.dart";

import 'actionTypes.dart';
import 'counterEffect.dart';
import 'counterState.dart';
//pub run test test/ajwah_test.dart

void main() {
  Store store;

  setUpAll(() {
    store = createStore(states: [CounterState()], effects: [CounterEffect()]);
  });

  tearDownAll(() {
    store.dispose();
  });

  ajwahTest("initial should be:{count:0, isLoading:false}",
      build: () => store.select<CounterModel>('counter'),
      expect: [CounterModel.init()]);

  ajwahTest(
      "after dispatch(actionType: ActionTypes.AsyncInc) state should be mutated two times: first time:{count:0, isLoading:true} isLoading:true and second time:{count:1, isLoading:false}",
      build: () => store.select('counter'),
      act: () => store.dispatcH(ActionTypes.AsyncInc),
      skip: 1,
      wait: const Duration(milliseconds: 2),
      expect: [
        CounterModel(count: 0, isLoading: true),
        CounterModel(count: 1, isLoading: false),
      ]);
}
