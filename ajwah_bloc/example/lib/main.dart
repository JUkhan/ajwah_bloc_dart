import 'package:ajwah_bloc/ajwah_bloc.dart';

void main() {
  createStore(states: []);
  dispatch(actionType: 'Inc');
  print('hello world');
}
