import 'package:ajwah_bloc/ajwah_bloc.dart';
import 'package:ajwah_bloc/src/createStore.dart';

import "package:test/test.dart";
import "package:ajwah_bloc/src/action.dart";
import 'package:rxdart/rxdart.dart';
import 'actionTypes.dart';
import 'counterEffect.dart';
import 'counterState.dart';
import 'util.dart';

//pub run test test/ajwah_test.dart
//pub run test_coverage
//dart --pause-isolates-on-exit --enable_asserts --enable-vm-service \
//  test/.test_coverage.dart

storeFactoty() {
  return createStore(states: [CounterState()], block: true);
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
  test("initial store should be:{count:0, isLoading:false}", () {
    store.select<CounterModel>('counter').take(1).listen((counterModel) {
      expect(counterModel.count, equals(0));
      expect(counterModel.isLoading, equals(false));
    });
  });
  test("adding dynamic effect with keyName 'myEffect' removing also", () async {
    store.addEffect(
        (action$, store$) => action$
            .whereTypes([ActionTypes.AsyncInc, ActionTypes.Dec])
            .debounceTime(Duration(milliseconds: 2))
            .mapTo(Action(type: ActionTypes.Inc)),
        effectKey: 'myEffect');
    await delay(100);
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

    await delay(50);

    isFirst = true;
    store.dispatch(Action(type: ActionTypes.Dec));
    store
        .select<CounterModel>('counter')
        .skip(1)
        .take(2)
        .listen((counterModel) {
      if (isFirst) {
        expect(counterModel.count, equals(0));
      } else {
        expect(counterModel.count, equals(1));
      }
      isFirst = false;
    });
    await delay(50);
    store.removeEffectsByKey('myEffect');
    store.dispatch(Action(type: ActionTypes.AsyncInc));
    await delay(50);
    store.select<CounterModel>('counter').take(1).listen((counterModel) {
      expect(counterModel.count, equals(1));
    });
  });

  test("adding CounterEffect", () async {
    store.importState({'counter': CounterModel(count: -1, isLoading: false)});
    store.addEffects(CounterEffect());

    await delay(100);
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

    await delay(5);
    store.removeEffectsByKey('counterEffect');
    store.dispatch(Action(type: ActionTypes.AsyncInc));
    await delay(5);
    store
        .select<CounterModel>('counter')
        .skip(1)
        .take(1)
        .listen((counterModel) {
      expect(counterModel.count, equals(1));
    });
  });
}
