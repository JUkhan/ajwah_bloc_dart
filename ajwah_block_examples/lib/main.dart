import 'package:ajwah_bloc/ajwah_bloc.dart';
import 'package:ajwah_block_examples/counter/components/counterComponent.dart';
import 'package:ajwah_block_examples/counter/store/counterEffect.dart';
import 'package:ajwah_block_examples/counter/store/counterState.dart';
import 'package:flutter_web/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  MyApp() {
    createStore(states: [CounterState()], effects: [CounterEffect()]);
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Ajwah - '),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;
  void menuSelect(String value) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: <Widget>[
          PopupMenuButton(
            onSelected: menuSelect,
            itemBuilder: (ctx) => [
                  PopupMenuItem(
                    value: 'Counter',
                    child: ListTile(
                      title: Text('Counter'),
                    ),
                  )
                ],
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[CounterComponent()],
        ),
      ),
    );
  }
}
