import 'package:ajwah_bloc/ajwah_bloc.dart';
import 'package:ajwah_block_examples/counter/components/counterComponent.dart';
import 'package:ajwah_block_examples/counter/store/counterEffect.dart';
import 'package:ajwah_block_examples/counter/store/counterState.dart';
import 'package:ajwah_block_examples/todo/components/todoContainer.dart';
import 'package:ajwah_block_examples/todo/store/TodoEffects.dart';
import 'package:ajwah_block_examples/todo/store/TodoState.dart';
import 'package:ajwah_block_examples/wikiSearch/components/searchComponent.dart';
import 'package:ajwah_block_examples/wikiSearch/store/SearchState.dart';
import 'package:ajwah_block_examples/wikiSearch/store/searchEffect.dart';
import 'package:flutter_web/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  MyApp() {
    createStore(
        states: [CounterState(), SearchState(), TodoState()],
        effects: [CounterEffect(), SearchEffect(), TodoEffects()]);
    /*store().exportState().listen((arr) {
      print((arr[0] as Action).type);
      print(arr[1]);
    });
    store()
        .addState(SearchState())
        .removeStateByStateName('counter')
        .addState(CounterState());*/
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: "/",
      routes: {
        '/': (_) => CounterComponent(),
        '/search': (_) => SearchComponent(),
        '/todo': (_) => TodoContainer()
      },
    );
  }
}
