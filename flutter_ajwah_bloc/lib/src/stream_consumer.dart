import 'dart:async';

import 'package:flutter/widgets.dart';

import '../flutter_ajwah_bloc.dart';

class StreamConsumer<S> extends StatefulWidget {
  StreamConsumer({
    Key key,
    @required this.stream,
    @required this.builder,
    this.listener,
  })  : assert(builder != null),
        assert(stream != null),
        super(key: key);

  final Stream<S> stream;

  /// The [builder] function which will be invoked on each widget build.
  /// The [builder] takes the `BuildContext` and current `state` and
  /// must return a widget.
  /// This is analogous to the [builder] function in [StreamBuilder].
  final BlocWidgetBuilder<S> builder;

  /// Takes the `BuildContext` along with the [skinny] `state`
  /// and is responsible for executing in response to `state` changes.
  final BlocWidgetListener<S> listener;

  @override
  _StreamConsumerState<S> createState() => _StreamConsumerState<S>();
}

class _StreamConsumerState<S> extends State<StreamConsumer<S>> {
  S _data;
  StreamSubscription _sub;
  @override
  void initState() {
    //_data = widget.initialData;

    _sub = widget.stream.listen((event) {
      setState(() {
        _data = event;
      });
      widget.listener?.call(context, event);
    });
    super.initState();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _data == null ? Container() : widget.builder(context, _data);
  }
}
