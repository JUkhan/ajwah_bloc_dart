## CounterModel and CounterState

```dart

class CounterModel {
  final int count;
  final bool isLoading;
  CounterModel({this.count, this.isLoading});
  CounterModel.init() : this(count: 0, isLoading: false);
  CounterModel copyWith({int count, bool isLoading}) => CounterModel(
      count: count ?? this.count, isLoading: isLoading ?? this.isLoading);
  @override
  String toString() {
    return '{coun:$count, isLoading:$isLoading}';
  }
  @override
  bool operator ==(other) =>
      other is CounterModel &&
      other.isLoading == isLoading &&
      other.count == count;

  @override
  int get hashCode => count.hashCode;
}

class CounterState extends BaseState<CounterModel> {
  CounterState() : super(name: 'counter', initialState: CounterModel.init());

  Stream<CounterModel> mapActionToState(
      CounterModel state, store.Action action) async* {
    switch (action.type) {
      case 'Inc':
        yield state.copyWith(count: state.count + 1, isLoading: false);
        break;
      case 'Dec':
        yield state.copyWith(count: state.count - 1, isLoading: false);
        break;
      case 'AsyncInc':
        yield state.copyWith(isLoading: true);
        await Future.delayed(Duration(seconds: 1));
        dispatch('Inc');
        break;
      default:
        yield latestState(this);
    }
  }
}

class CounterEffect extends BaseEffect {
  CounterEffect() : super(effectKey: 'counterEffect');
  Stream<Action> effectForAsyncInc(Actions action$, Store store$) {
    return action$
        .whereType(ActionTypes.AsyncInc)
        .debounceTime(Duration(milliseconds: 2))
        .mapTo(Action(type: ActionTypes.Inc));
  }

  List<Stream<Action>> registerEffects(Actions action$, Store store$) {
    return [effectForAsyncInc(action$, store$)];
  }
}

```

## testing

```dart
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
    store = createStore(states: [CounterState()], block: true);
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
        store.dispatch(Action(type: ActionTypes.AsyncInc));
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
      store.dispatch(Action(type: ActionTypes.AsyncInc));
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
        store.dispatch(Action(type: ActionTypes.AsyncInc));
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
      store.dispatch(Action(type: ActionTypes.AsyncInc));
    },
    skip: 1,
    expect: [
      CounterModel(count: 1, isLoading: true),
    ],
  );
}



```
