import 'package:ajwah_bloc/ajwah_bloc.dart';

class Counter {
  final int count;
  final bool loading;

  Counter(this.count, this.loading);

  Counter copyWith({int? count, bool loading = false}) =>
      Counter(count ?? this.count, loading);

  @override
  String toString() {
    return 'count: $count, loading: $loading';
  }
}

class CounterState extends StateController<Counter> {
  CounterState() : super(Counter(0, false));
  inc() {
    emit(state.copyWith(count: state.count + 1));
  }

  dec() {
    emit(state.copyWith(count: state.count - 1));
  }

  asyncInc() async {
    emit(state.copyWith(loading: true));
    await Future.delayed(const Duration(seconds: 1));
    inc();
  }
}
