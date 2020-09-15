import 'package:ajwah_bloc/ajwah_bloc.dart';
import 'actionTypes.dart';

class CounterModel {
  final int count;
  final bool isLoading;
  CounterModel({this.count, this.isLoading});
  CounterModel.init() : this(count: 0, isLoading: false);
  CounterModel.countData(int count) : this(count: count, isLoading: false);
  CounterModel.loading(int count) : this(count: count, isLoading: true);
  @override
  String toString() {
    return '{count:$count, isLoading:$isLoading}';
  }

  @override
  bool operator ==(other) =>
      other is CounterModel &&
      other.isLoading == isLoading &&
      other.count == count;

  @override
  int get hashCode => count.hashCode;
}

class CounterState extends StateBase<CounterModel> {
  CounterState() : super(name: 'counter', initialState: CounterModel.init());

  Stream<CounterModel> mapActionToState(
    CounterModel state,
    Action action,
    Store store,
  ) async* {
    switch (action.type) {
      case ActionTypes.Inc:
        yield CounterModel.countData(state.count + 1);
        break;
      case ActionTypes.Dec:
        yield CounterModel.countData(state.count - 1);
        break;
      case ActionTypes.AsyncInc:
        yield CounterModel.loading(state.count);
        break;

      default:
        yield getState(store);
    }
  }
}
