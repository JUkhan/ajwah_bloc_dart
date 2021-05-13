/*ddcf   hfgfc vhrfimport 'package:flutter/material.dart' hide Actions;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mono_state/mono_state.dart';
import './useMono.dart';

typedef EffectCallback<S> = Stream<S> Function(
    Actions action$, MonoState store);

class ActionHandlerResponse<S> {
  final bool loading;
  final dynamic? error;
  final S? data;
  ActionHandlerResponse(this.loading, this.error, this.data);
}

ValueNotifier<ActionHandlerResponse<S>> useActionHandler<S>(
    EffectCallback<S> stream$) {
  final MonoState mono = useMono();
  final state = useState<ActionHandlerResponse<S>>(
      new ActionHandlerResponse(true, null, null));
  useEffect(() {
    final sub = stream$(mono.action$, mono).listen((res) {
      state.value = new ActionHandlerResponse<S>(false, null, res);
    }, onError: ((err) {
      state.value = new ActionHandlerResponse<S>(false, err, state.value.data);
    }));
    return sub.cancel;
  }, [mono]);

  return state;
}
*/