import 'package:ajwah_bloc/src/createStore.dart';
import 'package:ajwah_bloc/src/store.dart';
import "package:test/test.dart";

import 'actionTypes.dart';
import 'counterState.dart';
//pub run test test/ajwah_test.dart

Store storeFactoty() {
  return createStore(states: [CounterState()]);
}

void main() {
  final store = storeFactoty();

  test("initial store should be:{count:0, isLoading:false}", () {
    store
        .select<CounterModel>(stateName: 'counter')
        .take(1)
        .listen((counterModel) {
      expect(counterModel.count, equals(0));
      expect(counterModel.isLoading, equals(false));
    });
  });

  test(
      "after dispatch(actionType: ActionTypes.Inc) state should be:{count:1, isLoading:false}",
      () {
    dispatch(actionType: ActionTypes.Inc);
    store
        .select<CounterModel>(stateName: 'counter')
        .take(1)
        .listen((counterModel) {
      expect(counterModel.count, equals(1));
      expect(counterModel.isLoading, equals(false));
    });
  });
  test(
      "after dispatch(actionType: ActionTypes.Dec) state should be:{count:0, isLoading:false}",
      () {
    dispatch(actionType: ActionTypes.Dec);
    store
        .select<CounterModel>(stateName: 'counter')
        .take(1)
        .listen((counterModel) {
      expect(counterModel.count, equals(0));
      expect(counterModel.isLoading, equals(false));
    });
  });
}
