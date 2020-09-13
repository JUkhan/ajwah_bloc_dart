import 'package:ajwah_bloc/ajwah_bloc.dart';
import 'package:ajwah_bloc/src/createStore.dart';
import 'package:ajwah_bloc_test/ajwah_bloc_test.dart';

import "package:test/test.dart";
import "package:ajwah_bloc/src/action.dart";
import 'package:rxdart/rxdart.dart';
import 'actionTypes.dart';
import 'counterEffect.dart';
import 'counterState.dart';

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

  ajwahTest("adding dynamic effect with keyName 'myEffect' removing also",
      build: () {
        store
            .importState({'counter': CounterModel(count: 0, isLoading: false)});
        store.addEffect(
            (action$, store$) => action$
                .whereTypes([ActionTypes.AsyncInc, ActionTypes.Dec])
                .debounceTime(Duration(milliseconds: 2))
                .mapTo(Action(type: ActionTypes.Inc)),
            effectKey: 'myEffect');
        return store.select('counter');
      },
      act: () {
        store.dispatcH(ActionTypes.AsyncInc);
      },
      skip: 1,
      wait: const Duration(milliseconds: 5),
      expect: [
        CounterModel(count: 0, isLoading: true),
        CounterModel(count: 1, isLoading: false),
      ],
      tearDown: () {
        store.removeEffectsByKey('myEffect');
      });

  ajwahTest(
    "Async inc should not working now",
    build: () {
      return store.select<CounterModel>('counter');
    },
    act: () {
      store.dispatcH(ActionTypes.AsyncInc);
    },
    skip: 1,
    expect: [
      CounterModel(count: 1, isLoading: true),
    ],
  );

  ajwahTest("adding CounterEffect() and removed also",
      build: () {
        store
            .importState({'counter': CounterModel(count: 0, isLoading: false)});
        store.addEffects(CounterEffect());
        return store.select<CounterModel>('counter');
      },
      act: () {
        store.dispatcH(ActionTypes.AsyncInc);
      },
      wait: const Duration(milliseconds: 10),
      skip: 1,
      expect: [
        CounterModel(count: 0, isLoading: true),
        CounterModel(count: 1, isLoading: false),
      ],
      tearDown: () {
        store.removeEffectsByKey('counterEffect');
      });

  ajwahTest(
    "last Async inc should not working now",
    build: () {
      store.importState({'counter': CounterModel(count: 1, isLoading: false)});
      return store.select<CounterModel>('counter');
    },
    act: () {
      store.dispatcH(ActionTypes.AsyncInc);
    },
    skip: 1,
    expect: [
      CounterModel(count: 1, isLoading: true),
    ],
  );
}
