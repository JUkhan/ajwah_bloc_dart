// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:ajwah_bloc/ajwah_bloc.dart';
import 'package:ajwah_bloc_test/ajwah_bloc_test.dart';
import 'package:ajwahh_block_examples/main.dart';

import 'package:flutter_test/flutter_test.dart';

void main() {
  AjwahStore store;
  setUpAll(() {
    store = createStore(exposeApiGlobally: true);
    registerCounterState();
  });
  tearDownAll(() {
    store.dispose();
  });
  ajwahTest(
    "initial counter state data[10,flase]",
    build: () => store.select('counter').map((event) => event.toString()),
    expect: ['{coun:10, isLoading:false}'],
  );
  ajwahTest(
    "check increment[11,false]",
    build: () => store.select('counter').map((event) => event.toString()),
    act: () => store.dispatch(Action(type: 'Inc')),
    skip: 1,
    expect: ['{coun:11, isLoading:false}'],
  );
  ajwahTest(
    "check decrement[10,false]",
    build: () => store.select('counter').map((event) => event.toString()),
    act: () => store.dispatch(Action(type: 'Dec')),
    skip: 1,
    expect: ['{coun:10, isLoading:false}'],
  );

  ajwahTest(
    "check async increment[11,false]",
    build: () => store.select('counter').map((event) => event.toString()),
    act: () => store.dispatch(Action(type: 'AsyncInc')),
    wait: const Duration(milliseconds: 1100),
    skip: 1,
    expect: [
      '{coun:10, isLoading:true}',
      '{coun:11, isLoading:false}',
    ],
  );

  ajwahTest(
    "check decrement[10,false]",
    build: () => store.select('counter').map((event) => event.toString()),
    act: () => store.dispatch(Action(type: 'Dec')),
    skip: 1,
    expect: ['{coun:10, isLoading:false}'],
  );
}
