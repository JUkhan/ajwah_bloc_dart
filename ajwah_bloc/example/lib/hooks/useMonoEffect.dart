import 'package:ajwah_bloc/ajwah_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

useMonoEffect(Stream<Action> stream$, void Function(Action action) dispatch) {
  useEffect(() {
    final sub = stream$.listen((action) {
      dispatch(action);
    });
    return sub.cancel;
  }, []);
}
