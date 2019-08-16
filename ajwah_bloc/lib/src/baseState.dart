import 'package:meta/meta.dart';

import 'action.dart';

///Every state class must derived from `BaseState<T>` class. And it is mandatory to pass the
///state `name` and `initialState`.
///
/// **Example:**
///```dart
///class CounterModel {
///   final int count;
///   final bool isLoading;
///   CounterModel({this.count, this.isLoading});
///   CounterModel.init():this(count:0, isLoading:false);
///   CounterModel.countData(int count) : this(count: count, isLoading: false);
/// }
///
///class CounterState extends BaseState<CounterModel> {
///
///   CounterState(): super(name: 'counter', initialState: CounterModel.init());
///
///
///   CounterModel reduce(CounterModel state, Action action) {
///     switch (action.type) {
///       case ActionTypes.Inc: return CounterModel.countData(state.count+1);
///       default: return state;
///     }
///   }
/// }
///```
abstract class BaseState<T> {
  final String name;
  final T initialState;
  BaseState({@required this.name, @required this.initialState})
      : assert(name != null && name.isNotEmpty
            ? true
            : throw 'state name should not be empty or null.'),
        assert(initialState != null);

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

  Stream<T> mapActionToState(T state, Action action);
  //T reduce(T state, Action action);
}
