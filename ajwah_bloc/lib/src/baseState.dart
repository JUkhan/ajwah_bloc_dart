import 'package:meta/meta.dart';

import 'action.dart';

abstract class BaseState<T> {
  final String name;
  final T initialState;
  BaseState({@required this.name, @required this.initialState})
      : assert(name != null && name.isNotEmpty
            ? true
            : throw 'state name should not be empty or null.'),
        assert(initialState != null);
  T reduce(T state, Action action);
}
