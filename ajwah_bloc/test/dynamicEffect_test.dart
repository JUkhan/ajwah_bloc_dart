import 'package:ajwah_bloc/src/createStore.dart';
import 'package:ajwah_bloc/src/store.dart';
import "package:test/test.dart";
import "package:ajwah_bloc/src/action.dart";
import 'actionTypes.dart';
import 'counterEffect.dart';
import 'counterState.dart';
import 'util.dart';

//pub run test test/ajwah_test.dart
//pub run test_coverage
//dart --pause-isolates-on-exit --enable_asserts --enable-vm-service \
//  test/.test_coverage.dart

Store storeFactoty() {
  return createStore(states: [CounterState()]);
}

void main() {
  final store = storeFactoty();
  var isFirst = true;
  setUp(() {
    isFirst = true;
  });

  test("initial store should be:{count:0, isLoading:false}", () {
    store
        .select<CounterModel>(stateName: 'counter')
        .take(1)
        .listen((counterModel) {
      expect(counterModel.count, equals(0));
      expect(counterModel.isLoading, equals(false));
    });
  });
  test("adding dynamic effect with keyName 'myEffect' removing also", () async {
    store.addEffect(
        (action$, store$) => action$
            .ofTypes([ActionTypes.AsyncInc, ActionTypes.Dec])
            .debounceTime(Duration(milliseconds: 2))
            .mapTo(Action(type: ActionTypes.Inc)),
        effectKey: 'myEffect');
    await delay(100);
    dispatch(actionType: ActionTypes.AsyncInc);
    store
        .select<CounterModel>(stateName: 'counter')
        .take(2)
        .listen((counterModel) {
      if (isFirst) {
        expect(counterModel.isLoading, equals(true));
      } else {
        expect(counterModel.count, equals(1));
      }
      isFirst = false;
    });

    await delay(5);

    isFirst = true;
    dispatch(actionType: ActionTypes.Dec);
    store
        .select<CounterModel>(stateName: 'counter')
        .take(2)
        .listen((counterModel) {
      if (isFirst) {
        expect(counterModel.count, equals(0));
      } else {
        expect(counterModel.count, equals(1));
      }
      isFirst = false;
    });
    await delay(5);
    store.removeEffectsByKey('myEffect');
    dispatch(actionType: ActionTypes.AsyncInc);
    await delay(5);
    store
        .select<CounterModel>(stateName: 'counter')
        .take(1)
        .listen((counterModel) {
      expect(counterModel.count, equals(1));
    });
  });

  test("adding CounterEffect", () async {
    store.importState({'counter': CounterModel(count: 0, isLoading: false)});
    store.addEffects(CounterEffect());

    await delay(5);
    dispatch(actionType: ActionTypes.AsyncInc);
    store
        .select<CounterModel>(stateName: 'counter')
        .take(2)
        .listen((counterModel) {
      if (isFirst) {
        expect(counterModel.isLoading, equals(true));
      } else {
        expect(counterModel.count, equals(1));
      }
      isFirst = false;
    });

    await delay(5);
    store.removeEffectsByKey('counterEffect');
    dispatch(actionType: ActionTypes.AsyncInc);
    await delay(5);
    store
        .select<CounterModel>(stateName: 'counter')
        .take(1)
        .listen((counterModel) {
      expect(counterModel.count, equals(1));
    });
  });
}