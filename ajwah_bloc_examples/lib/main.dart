import 'dart:async';

import 'package:ajwah_bloc/ajwah_bloc.dart' as store;
import 'package:ajwah_bloc/ajwah_bloc.dart';

import 'package:flutter/material.dart';
import 'package:flutter_ajwah_bloc/flutter_ajwah_bloc.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  createStore(states: [CounterState()], enableGlobalApi: true);

  runApp(App());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: BlocProvider(
        create: (context) => CounterBloc(),
        child: SkinnyWidget(),
      ), // MyHomePage(),
    );
  }
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ThemeBloc(),
      child: BlocConsumer<ThemeBloc, ThemeData>(
        builder: (_, theme) {
          return MaterialApp(
            theme: theme,
            home: BlocProvider(
              create: (_) => CounterBloc(),
              child: CounterPage(),
            ),
          );
        },
      ),
    );
  }
}

class CounterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Counter')),
      body: Column(
        children: [
          StreamConsumer<int>(
              initialData: 0,
              stream: store.select('counter').map((event) => event.count),
              listener: (context, state) {
                //print(state?.toString());
              },
              builder: (context, state) => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () => store.dispatcH('Inc')),
                      IconButton(
                          icon: Icon(Icons.remove),
                          onPressed: () => store.dispatcH('Dec')),
                      Text(state.toString()),
                    ],
                  )),
          BlocConsumer<CounterBloc, CounterModel>(
            listenWhen: (previous, current) => current != null,
            listener: (context, state) {
              if (state?.isLoading ?? false) {
                store.dispatcH('AsyncInc');
              }
              print(state?.count);
            },
            buildWhen: (previous, current) =>
                current != null && current.count < 8,
            builder: (_, counter) {
              print(counter);
              return Center(
                child: counter.isLoading
                    ? CircularProgressIndicator()
                    : Text('${counter.count}',
                        style: Theme.of(context).textTheme.headline1),
              );
            },
          ),
        ],
      ),
      floatingActionButton: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () => store.dispatcH(
                  'Inc'), //context.bloc<CounterBloc>().dispatcH('Inc'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: FloatingActionButton(
              child: const Icon(Icons.remove),
              onPressed: () => context.bloc<CounterBloc>().dispatcH('Dec'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: FloatingActionButton(
              child: const Icon(Icons.brightness_6),
              onPressed: () =>
                  context.bloc<ThemeBloc>().dispatcH('themeChange'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: FloatingActionButton(
              backgroundColor: Colors.red,
              child: const Icon(Icons.error),
              onPressed: () => context.bloc<CounterBloc>().dispatcH('AsyncInc'),
            ),
          ),
        ],
      ),
    );
  }
}

class CounterBloc extends SkinnyStore<CounterModel> {
  CounterBloc() : super(CounterModel.init());

  @override
  Stream<CounterModel> mapActionToState(
    CounterModel state,
    store.Action action,
    Store store,
  ) async* {
    switch (action.type) {
      case 'Inc':
        yield state.copyWith(count: state.count + 1, isLoading: false);
        break;
      case 'Dec':
        yield state.copyWith(count: state.count - 1, isLoading: false);
        break;
      case 'AsyncInc':
        yield state.copyWith(isLoading: true);
        await Future.delayed(Duration(seconds: 1));
        store.dispatcH('Inc');
        break;
      default:
        yield getState(store);
    }
  }
}

class ThemeBloc extends SkinnyStore<ThemeData> {
  /// {@macro brightness_cubit}
  ThemeBloc() : super(_lightTheme);

  static final _lightTheme = ThemeData(
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      foregroundColor: Colors.white,
    ),
    brightness: Brightness.light,
  );

  static final _darkTheme = ThemeData(
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      foregroundColor: Colors.black,
    ),
    brightness: Brightness.dark,
  );

  /// Toggles the current brightness between light and dark.
  @override
  Stream<ThemeData> mapActionToState(
    ThemeData state,
    store.Action action,
    Store store,
  ) async* {
    switch (action.type) {
      case 'themeChange':
        yield state.brightness == Brightness.dark ? _lightTheme : _darkTheme;
        break;

      default:
        yield getState(store);
    }
  }
}

class SkinnyWidget extends StatelessWidget {
  const SkinnyWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CounterBloc, CounterModel>(
      builder: (context, state) => Text(state.count.toString()),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajwah Store'),
      ),
      body: Container(
          child: Column(
        children: <Widget>[
          StateOnDemand(),
          Counter(),
          ExportState(),
        ],
      )),
    );
  }
}

class Counter extends StatelessWidget {
  const Counter({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        RaisedButton(
          onPressed: () => dispatcH('Inc'),
          child: Text('+'),
        ),
        RaisedButton(
          onPressed: () => dispatcH('Dec'),
          child: Text('-'),
        ),
        RaisedButton(
          onPressed: () => dispatcH('AsyncInc'),
          child: Text('Async +'),
        ),
        StreamBuilder<CounterModel>(
          stream: select('counter'),
          builder:
              (BuildContext context, AsyncSnapshot<CounterModel> snapshot) {
            if (snapshot.hasData) {
              return snapshot.data.isLoading
                  ? CircularProgressIndicator()
                  : Text(
                      '  ${snapshot.data.count}',
                      style: TextStyle(fontSize: 24, color: Colors.blue),
                    );
            }
            return Container();
          },
        ),
      ],
    );
  }
}

class StateOnDemand extends StatelessWidget {
  const StateOnDemand({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        RaisedButton(
          onPressed: () => removeStateByStateName('counter'),
          child: Text('Remove State'),
        ),
        RaisedButton(
          onPressed: () => addState(CounterState()),
          child: Text('Add State'),
        ),
        RaisedButton(
          onPressed: () => importState(
              {'counter': CounterModel(count: 999, isLoading: false)}),
          child: Text('Import State'),
        ),
      ],
    );
  }
}

class ExportState extends StatelessWidget {
  const ExportState({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: exportState(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          var state = snapshot.data[1].length > 0
              ? snapshot.data[1]['counter']?.toString() ?? ''
              : 'empty';
          return Container(
            child: Text.rich(
              TextSpan(text: 'Export State\n', children: [
                TextSpan(
                    text: 'actionType:${snapshot.data[0].type} \nstate:$state',
                    style: TextStyle(color: Colors.purple, fontSize: 24))
              ]),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.indigo, fontSize: 20),
            ),
          );
        }
        return Container();
      },
    );
  }
}

class CounterModel {
  final int count;
  final bool isLoading;
  CounterModel({this.count, this.isLoading});
  CounterModel.init() : this(count: 10, isLoading: false);
  CounterModel copyWith({int count, bool isLoading}) => CounterModel(
      count: count ?? this.count, isLoading: isLoading ?? this.isLoading);
  @override
  String toString() {
    return '{coun:$count, isLoading:$isLoading}';
  }
}

class CounterState extends BaseState<CounterModel> {
  CounterState() : super(name: 'counter', initialState: CounterModel.init());

  Stream<CounterModel> mapActionToState(
      CounterModel state, store.Action action, Store store) async* {
    switch (action.type) {
      case 'Inc':
        yield state.copyWith(count: state.count + 1, isLoading: false);
        break;
      case 'Dec':
        yield state.copyWith(count: state.count - 1, isLoading: false);
        break;
      case 'AsyncInc':
        yield state.copyWith(isLoading: true);
        await Future.delayed(Duration(seconds: 1));
        store.dispatcH('Inc');
        break;
      default:
        yield getState(store);
    }
  }
}
