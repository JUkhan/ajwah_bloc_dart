import 'package:ajwah_bloc/ajwah_bloc.dart';
import 'package:ajwah_bloc/src/createStore.dart';

import "package:test/test.dart";

import 'actionTypes.dart';
import 'counterEffect.dart';
import 'counterState.dart';
//pub run test test/ajwah_test.dart

storeFactoty() {
  return createStore(
      states: [CounterState()], effects: [CounterEffect()], block: true);
}

void main() {
  Store store = storeFactoty();
  var isFirst = true;
  setUp(() {
    isFirst = true;
  });

  tearDownAll(() {
    store.dispose();
  });

  test("initial should be:{count:0, isLoading:false}", () {
    store.select<CounterModel>('counter').take(1).listen((counterModel) {
      expect(counterModel.count, equals(0));
      expect(counterModel.isLoading, equals(false));
    });
  });

  test(
      "after dispatch(actionType: ActionTypes.AsyncInc) state should be mutated two times: first time:{count:0, isLoading:true} isLoading:true and second time:{count:1, isLoading:false}",
      () {
    store.dispatch(Action(type: ActionTypes.AsyncInc));

    store
        .select<CounterModel>('counter')
        .skip(1)
        .take(2)
        .listen((counterModel) {
      if (isFirst) {
        expect(counterModel.isLoading, equals(true));
      } else {
        expect(counterModel.count, equals(1));
      }
      isFirst = false;
    });
  });
}
