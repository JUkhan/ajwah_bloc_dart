import 'package:ajwah_bloc_test/ajwah_bloc_test.dart';
import 'package:test/test.dart';
import 'package:ajwah_bloc/ajwah_bloc.dart';
import 'counterState.dart';
import 'actionTypes.dart';

void main() {
  createStore_fn_test();
  register_and_unregister_state_fn_test();
  effect_register_unregister();
  import_export_test();
  dispatcher_actions_getState_fn();
  withTypes_selectMany_fn_test();
}

void createStore_fn_test() {
  AjwahStore store;
  setUp(() {
    store = createStore();
  });
  tearDown(() {
    store.dispose();
  });
  test('createStore() function return instance of the AjwahStore', () {
    expect(store, isA<AjwahStore>());
  });
}

void register_and_unregister_state_fn_test() {
  group('register and unregister counter state', () {
    AjwahStore store;
    setUpAll(() {
      store = createStore();
      registerCounterState(store);
    });
    tearDownAll(() {
      store.dispose();
    });

    ajwahTest(
        'after register counter state - initial store should be:{count:0, isLoading:false}',
        build: () => store.select<CounterModel>('counter'),
        log: (models) {
          print(models);
        },
        expect: [CounterModel.init()]);

    ajwahTest(
        'after dispatch(actionType: ActionTypes.Inc) state should be:{count:1, isLoading:false}',
        build: () => store.select('counter'),
        act: () => store.dispatch(Action(type: ActionTypes.Inc)),
        skip: 1,
        expect: [CounterModel(count: 1, isLoading: false)]);

    ajwahTest(
      'after dispatch(actionType: ActionTypes.Dec) state should be:{count:0, isLoading:false}',
      act: () => store.dispatch(Action(type: ActionTypes.Dec)),
      build: () => store.select<CounterModel>('counter'),
      skip: 1,
      expect: [CounterModel.init()],
    );

    ajwahTest(
      'after unregistering counter model we will have null state value',
      build: () {
        store.unregisterState(stateName: 'counter');
        return store.select<CounterModel>('counter');
      },
      expect: [null],
    );
  });
}

void effect_register_unregister() {
  AjwahStore store;
  setUpAll(() {
    store = createStore();
    registerCounterState(store);
  });
  tearDownAll(() {
    store.dispose();
  });
  group('register effect for AsyncInc action and unregister', () {
    ajwahTest<CounterModel>(
      'after registering effect - we will get 2 models',
      build: () {
        store.registerEffect(
            (action$, store) => action$
                .whereType('AsyncInc')
                .map((event) => Action(type: ActionTypes.Inc)),
            effectKey: 'test');
        return store.select<CounterModel>('counter');
      },
      skip: 1,
      act: () => store.dispatch(Action(type: ActionTypes.AsyncInc)),
      expect: [isA<CounterModel>(), isA<CounterModel>()],
      verify: (models) {
        expect(models[0].isLoading, true);
        expect(models[1].isLoading, false);
        expect(models[1].count, 1);
      },
    );
    ajwahTest(
      'after unregistering effect we will have single model with loading true value only',
      build: () {
        store.unregisterEffect(effectKey: 'test');
        return store.select<CounterModel>('counter');
      },
      skip: 1,
      act: () => store.dispatch(Action(type: ActionTypes.AsyncInc)),
      expect: [isA<CounterModel>()],
      verify: (models) {
        expect(models[0].isLoading, true);
        expect(models[0].count, 1);
      },
    );
  });
}

void import_export_test() {
  AjwahStore store;
  setUpAll(() {
    store = createStore();
    registerCounterState(store);
  });
  tearDownAll(() {
    store.dispose();
  });
  group('import and export test', () {
    ajwahTest<List<dynamic>>(
      'exporting state',
      build: () => store.exportState().take(2),
      act: () {
        store.dispatch(Action(type: ActionTypes.Inc));
      },
      expect: [isA<List>(), isA<List>()],
      verify: (models) {
        expect(
            'registerState(counter)inc', models.map((e) => e[0].type).join(''));
      },
    );
    ajwahTest<CounterModel>(
      'importing state',
      build: () => store.select('counter'),
      act: () {
        store.importState({'counter': CounterModel.loading(2)});
      },
      skip: 1,
      expect: [isA<CounterModel>()],
      verify: (models) {
        expect(models[0].isLoading, true);
      },
    );
  });
}

void dispatcher_actions_getState_fn() {
  AjwahStore store;
  setUpAll(() {
    store = createStore();
    registerCounterState(store);
  });
  tearDownAll(() {
    store.dispose();
  });
  test('dispatcher actions getState fn', () {
    expect(store.dispatcher, isA<Stream>());
    expect(store.actions, isA<Actions>());

    expect(store.getState<CounterModel>(stateName: 'counter'),
        isA<CounterModel>());
  });
}

void withTypes_selectMany_fn_test() {
  AjwahStore store;
  setUpAll(() {
    store = createStore();
    registerCounterState(store);
  });
  tearDownAll(() {
    store.dispose();
  });
  group('withTypes', () {
    ajwahTest<Action>('withTypes',
        build: () => store.actions.whereTypes([ActionTypes.Inc]),
        act: () {
          store.dispatch(Action(type: ActionTypes.Dec));
          store.dispatch(Action(type: ActionTypes.AsyncInc));
        },
        log: (models) {
          prints(models);
        },
        expect: []);
    ajwahTest<CounterModel>('selectMany',
        build: () => store.selectMany((state) => state['counter']),
        log: (models) {
          prints(models);
        },
        expect: [isA<CounterModel>()]);
  });
}
