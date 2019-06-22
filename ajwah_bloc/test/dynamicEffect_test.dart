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
    store.select<CounterModel>('counter').take(1).listen((counterModel) {
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
    dispatch(ActionTypes.AsyncInc);
    store.select<CounterModel>('counter').take(2).listen((counterModel) {
      if (isFirst) {
        expect(counterModel.isLoading, equals(true));
      } else {
        expect(counterModel.count, equals(1));
      }
      isFirst = false;
    });

    await delay(5);

    isFirst = true;
    dispatch(ActionTypes.Dec);
    store.select<CounterModel>('counter').take(2).listen((counterModel) {
      if (isFirst) {
        expect(counterModel.count, equals(0));
      } else {
        expect(counterModel.count, equals(1));
      }
      isFirst = false;
    });
    await delay(5);
    store.removeEffectsByKey('myEffect');
    dispatch(ActionTypes.AsyncInc);
    await delay(5);
    store.select<CounterModel>('counter').take(1).listen((counterModel) {
      expect(counterModel.count, equals(1));
    });
  });

  test("adding CounterEffect", () async {
    store.importState({'counter': CounterModel(count: 0, isLoading: false)});
    store.addEffects(CounterEffect());

    await delay(5);
    dispatch(ActionTypes.AsyncInc);
    store.select<CounterModel>('counter').take(2).listen((counterModel) {
      if (isFirst) {
        expect(counterModel.isLoading, equals(true));
      } else {
        expect(counterModel.count, equals(1));
      }
      isFirst = false;
    });

    await delay(5);
    store.removeEffectsByKey('counterEffect');
    dispatch(ActionTypes.AsyncInc);
    await delay(5);
    store.select<CounterModel>('counter').take(1).listen((counterModel) {
      expect(counterModel.count, equals(1));
    });
  });
}
