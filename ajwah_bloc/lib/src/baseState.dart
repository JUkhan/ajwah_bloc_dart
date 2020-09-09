import 'action.dart';
import 'store.dart';

///Every state class must derived from `BaseState<T>` class. And it is mandatory to pass the
///state `name` and `initialState`.
///
/// **Example:**
///```dart
///class CounterModel {
///  int count;
///  bool isLoading;
///
///  CounterModel({this.count, this.isLoading});
///
///  copyWith({int count, bool isLoading}) {
///    return CounterModel(
///        count: count ?? this.count, isLoading: isLoading ?? this.isLoading);
///  }
///
///  CounterModel.init() : this(count: 10, isLoading: false);
///}
///
///class CounterState extends BaseState<CounterModel> {
///  CounterState() : super(name: 'counter', initialState: CounterModel.init());
///
///  Stream<CounterModel> mapActionToState(
///      CounterModel state, Action action, Store store) async* {
///    switch (action.type) {
///      case ActionTypes.Inc:
///        state.count++;
///        yield state.copyWith(isLoading: false);
///        break;
///      case ActionTypes.Dec:
///        state.count--;
///        yield state.copyWith(isLoading: false);
///        break;
///      case ActionTypes.AsyncInc:
///        yield state.copyWith(isLoading: true);
///        yield await getCount(state.count);
///        break;
///      default:
///        yield getState(store);
///    }
///  }
///
///  Future<CounterModel> getCount(int count) {
///    return Future.delayed(Duration(milliseconds: 500),
///        () => CounterModel(count: count + 1, isLoading: false));
///  }
///}
///
///```
abstract class BaseState<T> {
  final String name;
  final T initialState;

  BaseState({this.name, this.initialState})
      : assert(name != null && name.isNotEmpty
            ? true
            : throw 'state name should not be empty or null.'),
        assert(initialState != null);

  T getState(Store store) {
    return store.value[name] ?? initialState;
  }

  ///This method should be invoked by sysytem passing current state and action.
  ///You should mutate the state based on action
  ///
  ///**Example**
  ///```dart
  ///   Stream<CounterModel> mapActionToState(
  ///     CounterModel state, Action action ) async* {
  ///     switch (action.type) {
  ///       case ActionTypes.Inc:
  ///         yield increment(state, action);
  ///         break;
  ///       default: yield state;
  ///     }
  ///   }
  /// ```

  Stream<T> mapActionToState(T state, Action action, Store store);
  //T reduce(T state, Action action);
}
