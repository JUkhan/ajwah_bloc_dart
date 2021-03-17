import 'dart:async';

import 'package:flutter/widgets.dart';

typedef StreamWidgetBuilder<S> = Widget Function(BuildContext context, S state);

typedef StreamWidgetListener<S> = void Function(BuildContext context, S state);

/// {@template stream_consumer}
/// [StreamConsumer] exposes a [builder] and [stream], [listener], [initialData] in order react to new
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
    //this.initialData,
    this.listener,
  }) : super(key: key);

  final Stream<S> stream;
  //final S? initialData;

  /// The [builder] function which will be invoked on each widget build.
  /// The [builder] takes the `BuildContext` and current `state` and
  /// must return a widget.
  /// This is analogous to the [builder] function in [StreamBuilder].
  final StreamWidgetBuilder<S> builder;

  /// Takes the `BuildContext` along with the `state`
  /// and is responsible for executing in response to `state` changes.
  final StreamWidgetListener<S>? listener;

  @override
  _StreamConsumerState<S> createState() => _StreamConsumerState<S>();
}

class _StreamConsumerState<S> extends State<StreamConsumer<S>> {
  S? _data;
  StreamSubscription? _subscription;
  @override
  void initState() {
    //_data = widget.initialData;
    _subscription = widget.stream.listen((event) {
      setState(() {
        _data = event;
      });
      widget.listener?.call(context, event);
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
  Widget build(BuildContext context) => _data != null
      ? widget.builder(context, _data ?? false as S)
      : Container();
}
