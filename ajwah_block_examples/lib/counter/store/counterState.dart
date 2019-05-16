import 'package:ajwah_bloc/ajwah_bloc.dart';
import 'package:ajwah_block_examples/actionTypes.dart';

class CounterModel {
  final int count;
  final bool isLoading;
  CounterModel({this.count, this.isLoading});
  CounterModel.init() : this(count: 0, isLoading: false);
  CounterModel.countData(int count) : this(count: count, isLoading: false);
  CounterModel.loading(int count) : this(count: count, isLoading: true);
}

class CounterState extends BaseState<CounterModel> {
  CounterState() : super(name: 'counter', initialState: CounterModel.init());

  CounterModel reduce(CounterModel state, Action action) {
    switch (action.type) {
      case ActionTypes.Inc:
        return CounterModel.countData(state.count + 1);
      case ActionTypes.Dec:
        return CounterModel.countData(state.count - 1);
      case ActionTypes.AsyncInc:
        return CounterModel.loading(state.count);

      default:
        return state;
    }
  }
}
