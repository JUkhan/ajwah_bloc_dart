import 'package:ajwah_bloc/ajwah_bloc.dart';
import 'package:ajwah_block_examples/actionTypes.dart';

class CounterModel {
  int count;
  bool isLoading;

  CounterModel({this.count, this.isLoading});

  copyWith({int count, bool isLoading}) {
    return CounterModel(
        count: count ?? this.count, isLoading: isLoading ?? this.isLoading);
  }

  CounterModel.init() : this(count: 10, isLoading: false);
}

class CounterState extends BaseState<CounterModel> {
  CounterState() : super(name: 'counter', initialState: CounterModel.init());

  Stream<CounterModel> mapActionToState(
      CounterModel state, Action action) async* {
    switch (action.type) {
      case ActionTypes.Inc:
        state.count++;
        yield state.copyWith(isLoading: false);
        break;
      case ActionTypes.Dec:
        state.count--;
        yield state.copyWith(isLoading: false);
        break;
      case ActionTypes.AsyncInc:
        yield state.copyWith(isLoading: true);
        yield await getCount(state.count);
        break;
      default:
        yield state;
    }
  }

  Future<CounterModel> getCount(int count) {
    return Future.delayed(Duration(milliseconds: 500),
        () => CounterModel(count: count + 1, isLoading: false));
  }
}
