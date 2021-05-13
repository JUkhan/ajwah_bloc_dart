import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class ActionHandlerResponse<S> {
  final bool loading;
  final dynamic? error;
  final S? data;
  ActionHandlerResponse(this.loading, this.error, this.data);
}

ValueNotifier<ActionHandlerResponse<S>> useActionHandler<S>(Stream<S> stream$) {
  final state = useState<ActionHandlerResponse<S>>(
      new ActionHandlerResponse(true, null, null));
  useEffect(() {
    final sub = stream$.listen((res) {
      state.value = new ActionHandlerResponse<S>(false, null, res);
    }, onError: ((err) {
      state.value = new ActionHandlerResponse<S>(false, err, state.value.data);
    }));
    return sub.cancel;
  }, []);

  return state;
}
