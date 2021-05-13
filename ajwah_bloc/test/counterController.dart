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
  }

  @override
  void onInit() {
    registerEffects([
      action$.whereType('testing').mapTo(Action(type: 'done'))
    ]);
  }
}

class RemoteController extends StateController<String> {
  RemoteController() : super('REMOTE STATE');
}
