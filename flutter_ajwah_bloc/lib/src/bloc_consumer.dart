import 'dart:async';

import 'skinnyStore.dart';
import 'package:flutter/widgets.dart';

import '../flutter_ajwah_bloc.dart';

/// {@template bloc_consumer}
/// [BlocConsumer] exposes a [builder] and [listener] in order react to new
/// states.
///
/// [BlocConsumer] should be used for both rebuild UI
/// and execute other reactions to state changes in the [skinny].
///
/// If the [skinny] parameter is omitted, [BlocConsumer] will automatically
/// perform a lookup using `BlocProvider` and the current `BuildContext`.
///
/// ```dart
/// BlocConsumer<BlocA, BlocAState>(
///   listener: (context, state) {
///     // do stuff here based on BlocA's state
///   },
///   builder: (context, state) {
///     // return widget here based on BlocA's state
///   }
/// )
/// ```
///
/// An optional [listenWhen] and [buildWhen] can be implemented for more
/// granular control over when [listener] and [builder] are called.
/// The [listenWhen] and [buildWhen] will be invoked on each [skinny] `state`
/// change.
/// They each take the previous `state` and current `state` and must return
/// a [bool] which determines whether or not the [builder] and/or [listener]
/// function will be invoked.
/// The previous `state` will be initialized to the `state` of the [skinny] when
/// the [BlocConsumer] is initialized.
/// [listenWhen] and [buildWhen] are optional and if they aren't implemented,
/// they will default to `true`.
///
/// ```dart
/// BlocConsumer<BlocA, BlocAState>(
///   listenWhen: (previous, current) {
///     // return true/false to determine whether or not
///     // to invoke listener with state
///   },
///   listener: (context, state) {
///     // do stuff here based on BlocA's state
///   },
///   buildWhen: (previous, current) {
///     // return true/false to determine whether or not
///     // to rebuild the widget with state
///   },
///   builder: (context, state) {
///     // return widget here based on BlocA's state
///   }
/// )
/// ```
/// {@endtemplate}
class BlocConsumer<SK extends SkinnyStore<S>, S> extends StatefulWidget {
  /// {@macro bloc_consumer}
  const BlocConsumer({
    Key key,
    @required this.builder,
    this.listener,
    this.skinny,
    this.buildWhen,
    this.listenWhen,
  })  : assert(builder != null),
        super(key: key);

  /// The [skinny] that the [BlocConsumer] will interact with.
  /// If omitted, [BlocConsumer] will automatically perform a lookup using
  /// `BlocProvider` and the current `BuildContext`.
  final SK skinny;

  /// The [builder] function which will be invoked on each widget build.
  /// The [builder] takes the `BuildContext` and current `state` and
  /// must return a widget.
  /// This is analogous to the [builder] function in [StreamBuilder].
  final BlocWidgetBuilder<S> builder;

  /// Takes the `BuildContext` along with the [skinny] `state`
  /// and is responsible for executing in response to `state` changes.
  final BlocWidgetListener<S> listener;

  /// Takes the previous `state` and the current `state` and is responsible for
  /// returning a [bool] which determines whether or not to trigger
  /// [builder] with the current `state`.
  final BlocBuilderCondition<S> buildWhen;

  /// Takes the previous `state` and the current `state` and is responsible for
  /// returning a [bool] which determines whether or not to call [listener] of
  /// [BlocConsumer] with the current `state`.
  final BlocListenerCondition<S> listenWhen;

  @override
  _BlocConsumerState<SK, S> createState() => _BlocConsumerState<SK, S>();
}

class _BlocConsumerState<SK extends SkinnyStore<S>, S>
    extends State<BlocConsumer<SK, S>> {
  S _previousState;
  SK _skinny;
  StreamSubscription _subscription;
  @override
  void initState() {
    _skinny = widget.skinny ?? context.bloc<SK>();
    if (_skinny != null) {
      _previousState = _skinny.state;
      _subscription = _skinny.stream.listen((state) {
        if (widget.listenWhen?.call(_previousState, state) ?? true) {
          widget.listener?.call(context, state);
        }
        if (widget.buildWhen?.call(_previousState, state) ?? true) {
          setState(() {});
        }
        _previousState = state;
      });
    }

    super.initState();
  }

  @override
  void dispose() {
    if (_subscription != null) {
      _subscription.cancel();
      _subscription = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _previousState);
}
