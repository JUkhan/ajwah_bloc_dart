```dart
import 'package:ajwah_bloc/ajwah_bloc.dart';

import 'package:ajwah_bloc_test/ajwah_bloc_test.dart';

import "package:test/test.dart";

import 'actionTypes.dart';
import 'counterStateController.dart';

void main() {
  CounterStateController controller = CounterStateController();

  setUpAll(() {});

  tearDownAll(() {
    controller.dispose();
  });

  ajwahTest("initial store should be:{count:0, isLoading:false}",
      build: () => controller.stream$, expect: [CounterModel.init()]);

  ajwahTest<CounterModel>(
      "after dispatch(actionType: ActionTypes.Inc) state should be:{count:1, isLoading:false}",
      build: () => controller.stream$,
      act: () => dispatch(Action(type: ActionTypes.Inc)),
      skip: 1,
      verify: (models) {
        expect(models[0].count, 1);
      },
      expect: [CounterModel(count: 1, isLoading: false)]);

  ajwahTest(
    "after dispatch(actionType: ActionTypes.Dec) state should be:{count:0, isLoading:false}",
    act: () => dispatch(Action(type: ActionTypes.Dec)),
    build: () => controller.stream$,
    skip: 1,
    expect: [CounterModel.init()],
  );
}



```
