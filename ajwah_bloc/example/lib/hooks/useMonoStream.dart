import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

ValueNotifier<S> useMonoStream<S>(Stream<S> stream$, S initialData) {
  final state = useState<S>(initialData);
  useEffect(() {
    final sub = stream$.listen((res) {
      state.value = res;
    });
    return sub.cancel;
  }, []);
  return state;
}
