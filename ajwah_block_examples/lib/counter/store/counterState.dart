import 'package:ajwah_bloc/ajwah_bloc.dart';
import 'package:ajwah_block_examples/actionTypes.dart';

class CounterModel {
  final int count;
  final bool isLoading;
  CounterModel({this.count, this.isLoading});
}

class CounterState extends BaseState<CounterModel> {
  CounterState()
      : super(
            name: 'counter',
            initialState: CounterModel(count: 0, isLoading: false));

  CounterModel increment(CounterModel state, Action action) {
    return CounterModel(count: state.count + 1, isLoading: false);
  }

  CounterModel decrement(CounterModel state, Action action) {
    return CounterModel(count: state.count - 1, isLoading: false);
  }

  CounterModel asyncInc(CounterModel state, Action action) {
    return CounterModel(count: state.count, isLoading: true);
  }

  CounterModel reduce(CounterModel state, Action action) {
    switch (action.type) {
      case ActionTypes.Inc:
        return increment(state, action);
      case ActionTypes.Dec:
        return decrement(state, action);
      case ActionTypes.AsyncInc:
        return asyncInc(state, action);

      default:
        return state;
    }
  }
}
