import 'package:flutter_hooks/flutter_hooks.dart';

useNotifier<S>(Stream<S> stream$, void Function(S action) nootify) {
  useEffect(() {
    final sub = stream$.listen((action) {
      nootify(action);
    });
    return sub.cancel;
  }, []);
}
