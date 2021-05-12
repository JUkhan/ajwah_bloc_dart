import 'package:ajwah_bloc/ajwah_bloc.dart';

class CounterStateController extends StateController<int> {
  CounterStateController() : super(0);

  void increment() {
    emit(state + 1);
  }

  void decrement() {
    emit(state - 1);
  }
}
