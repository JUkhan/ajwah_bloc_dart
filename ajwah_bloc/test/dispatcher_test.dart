import 'package:ajwah_bloc/ajwah_bloc.dart';
import 'package:ajwah_bloc/src/createStore.dart';

import "package:test/test.dart";

import 'actionTypes.dart';
import 'counterState.dart';

//pub run test test/ajwah_test.dart

dynamic storeFactoty() {
  return createStore(states: [CounterState()], block: true);
}

void main() {
  Store store = storeFactoty();
  tearDownAll(() {
    store.dispose();
  });
  //delay(1000);
  test("initial store should be:{count:0, isLoading:false}", () {
    store.select<CounterModel>('counter').take(1).listen((counterModel) {
      expect(counterModel.count, equals(0));
      expect(counterModel.isLoading, equals(false));
    });
  });

  test(
      "after dispatch(actionType: ActionTypes.Inc) state should be:{count:1, isLoading:false}",
      () {
    store.dispatch(Action(type: ActionTypes.Inc));
    store
        .select<CounterModel>('counter')
        .skip(1)
        .take(1)
        .listen((counterModel) {
      expect(counterModel.count, equals(1));
      expect(counterModel.isLoading, equals(false));
    });
  });
  test(
      "after dispatch(actionType: ActionTypes.Dec) state should be:{count:0, isLoading:false}",
      () {
    store.dispatch(Action(type: ActionTypes.Dec));
    store
        .select<CounterModel>('counter')
        .skip(1)
        .take(1)
        .listen((counterModel) {
      expect(counterModel.count, equals(0));
      expect(counterModel.isLoading, equals(false));
    });
  });
}
