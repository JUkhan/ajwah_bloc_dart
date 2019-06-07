import 'package:ajwah_bloc/src/createStore.dart';
import 'package:ajwah_bloc/src/store.dart';
import "package:test/test.dart";

import 'actionTypes.dart';
import 'counterEffect.dart';
import 'counterState.dart';
//pub run test test/ajwah_test.dart

Store storeFactoty() {
  return createStore(states: [CounterState()], effects: [CounterEffect()]);
}

void main() {
  final store = storeFactoty();
  var isFirst = true;
  setUp(() {
    isFirst = true;
  });

  test("initial store should be:{count:0, isLoading:false}", () {
    store.select<CounterModel>('counter').take(1).listen((counterModel) {
      expect(counterModel.count, equals(0));
      expect(counterModel.isLoading, equals(false));
    });
  });

  test(
      "after dispatch(actionType: ActionTypes.AsyncInc) state should be mutated two times: first time:{count:0, isLoading:true} isLoading:true and second time:{count:1, isLoading:false}",
      () {
    dispatch(actionType: ActionTypes.AsyncInc);

    store.select<CounterModel>('counter').take(2).listen((counterModel) {
      if (isFirst) {
        expect(counterModel.isLoading, equals(true));
      } else {
        expect(counterModel.count, equals(1));
      }
      isFirst = false;
    });
  });
}
