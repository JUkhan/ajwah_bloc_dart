import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

typedef StreamConsumerBuilder<S> = Widget Function(
    BuildContext context, S state);

typedef StreamConsumerListener<S> = void Function(
    BuildContext context, S state);

typedef StreamConsumerFilter<S> = bool Function(BuildContext context, S state);
typedef StreamConsumerErrorHandler = Widget Function(dynamic error);

abstract class _StreamConsumerResponse {}

class _StreamConsumerLoading extends _StreamConsumerResponse {}

class _StreamConsumerError extends _StreamConsumerResponse {
  final dynamic error;
  _StreamConsumerError(this.error);
}

class _StreamConsumerData<S> extends _StreamConsumerResponse {
  final data;
  _StreamConsumerData(this.data);
}

/// {@template stream_consumer}
/// [StreamConsumer] exposes a [builder] and [stream], [listener], [filter], [loading], [error] in order react to new
/// states.
///
/// [StreamConsumer] should be used for both rebuild UI
/// and execute other reactions to state changes on the given [stream]
/// through the [listener] callback.
///
/// ```dart
/// StreamConsumer<CounterModel>(
///   stream:store.select('counter')
///   listener: (context, state) {
///     // do stuff here based on state
///   },
///   filter: (context, state) {
///     return true or false based on state that trigger to render
///   },
///   loading: widget,
///   error: (error) {
///     return widget here based on error
///   },
///   builder: (context, state) {
///     // return widget here based on state
///   }
/// )
/// ```
/// {@endtemplate}
class StreamConsumer<S> extends StatefulWidget {
  /// {@macro stream_consumer}
  StreamConsumer({
    Key? key,
    required this.stream,
    required this.builder,
    this.filter,
    this.listener,
  })  : loading = CircularProgressIndicator(),
        error = ((error) => new Container()),
        super(key: key);

  final Stream<S> stream;
  //final S? initialData;

  /// The [builder] function which will be invoked on each widget build.
  /// The [builder] takes the `BuildContext` and current `state` and
  /// must return a widget.
  /// This is analogous to the [builder] function in [StreamBuilder].
  final StreamConsumerBuilder<S> builder;

  /// Takes the `BuildContext` along with the `state`
  /// and is responsible for executing in response to `state` changes.
  final StreamConsumerListener<S>? listener;

  final StreamConsumerFilter<S>? filter;
  final StreamConsumerErrorHandler error;
  final Widget loading;

  @override
  _StreamConsumerState<S> createState() => _StreamConsumerState<S>();
}

class _StreamConsumerState<S> extends State<StreamConsumer<S>> {
  ///S? _data;
  _StreamConsumerResponse _data = _StreamConsumerLoading();

  StreamSubscription? _subscription;
  @override
  void initState() {
    _subscription = widget.stream.listen((event) {
      if (widget.filter == null)
        setState(() {
          _data = _StreamConsumerData(event);
          widget.listener?.call(context, event);
        });
      else if (widget.filter!(context, event))
        setState(() {
          _data = _StreamConsumerData(event);
          widget.listener?.call(context, event);
        });
    }, onError: (error) {
      setState(() {
        _data = _StreamConsumerError(error);
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    if (_subscription != null) {
      _subscription?.cancel();
      _subscription = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_data is _StreamConsumerData) {
      return widget.builder(context, (_data as _StreamConsumerData).data);
    } else if (_data is _StreamConsumerLoading) {
      return widget.loading;
    } else if (_data is _StreamConsumerError) {
      return widget.error((_data as _StreamConsumerError).error);
    }
    return Container();
  }
}
