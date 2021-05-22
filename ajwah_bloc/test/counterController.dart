import 'package:ajwah_bloc/ajwah_bloc.dart';
import 'package:rxdart/rxdart.dart';

class IncrementByAction extends Action {
  final int num;
  IncrementByAction(this.num);
}

class CounterState {
  int count;
  bool loading;
  CounterState(this.count, this.loading);
  CounterState copyWith({int? count, bool? loading}) =>
      CounterState(count ?? this.count, loading ?? this.loading);
}

class CounterStateController extends StateController<CounterState> {
  CounterStateController() : super(CounterState(0, false));

  void increment() {
    emit(state.copyWith(count: state.count + 1));
  }

  void decrement() {
    emit(state.copyWith(count: state.count - 1));
  }

  void asyncInc() async {
    emit(state.copyWith(loading: true));
    await Future.delayed(const Duration(milliseconds: 10));
    emit(state.copyWith(count: state.count + 1, loading: false));
  }

  @override
  void onAction(Action action) {
    if (action is IncrementByAction) {
      emit(state.copyWith(count: state.count + action.num));
    }
    super.onAction(action);
  }

  @override
  void onInit() {
    registerEffects([action$.whereType('testing').mapTo(Action(type: 'done'))]);
  }
}

class RemoteController extends StateController<String> {
  RemoteController() : super('REMOTE STATE');
}

class Counter2State extends StateController<int> {
  Counter2State() : super(0);
  inc() {
    emit(state + 1);
  }

  dec() {
    emit(state - 1);
  }

  asyncInc() async {
    dispatch(Action(type: 'start'));
    await Future.delayed(const Duration(milliseconds: 10));
    inc();
  }

  Stream<String> get count$ => Rx.merge([
        action$.whereType('start').mapTo('loading...'),
        stream$.map((count) => '$count'),
      ]).asBroadcastStream();
}

//pub run test_coverage
//pub run build_runner test
//pub run build_runner build
//pub publish
