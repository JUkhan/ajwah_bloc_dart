import 'package:ajwah_bloc/ajwah_bloc.dart';
import 'package:ajwah_block_examples/actionTypes.dart';

class CounterModel {
  int count;
  bool isLoading;

  CounterModel({this.count, this.isLoading});

  static clone(CounterModel obj) {
    return CounterModel(count: obj.count, isLoading: obj.isLoading);
  }

  CounterModel.init() : this(count: 10, isLoading: false);
}

class CounterState extends BaseState<CounterModel> {
  CounterState() : super(name: 'counter', initialState: CounterModel.init());

  CounterModel reduce(CounterModel state, Action action) {
    switch (action.type) {
      case ActionTypes.Inc:
        state.count++;
        state.isLoading = false;
        return CounterModel.clone(state);
      case ActionTypes.Dec:
        state.count--;
        state.isLoading = false;
        return CounterModel.clone(state);
      case ActionTypes.AsyncInc:
        state.isLoading = true;
        return CounterModel.clone(state);

      default:
        return state;
    }
  }
}
