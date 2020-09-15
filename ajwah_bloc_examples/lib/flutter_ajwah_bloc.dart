import 'dart:async';
import 'package:ajwah_bloc/ajwah_bloc.dart' as store;
import 'package:ajwah_bloc/ajwah_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ajwah_bloc/flutter_ajwah_bloc.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  createStore(states: [CounterState(), ThemeState()], exposeApiGlobally: true);
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CounterBloc(),
      child: StreamConsumer<ThemeData>(
        stream: store.select<ThemeData>('theme'),
        listener: (context, state) {
          print('--------changing theme--------' +
              state.primaryColor.value.toString());
        },
        builder: (_, theme) {
          return MaterialApp(
            theme: theme,
            home: CounterPage(),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () => store.dispatcH('Inc')),
              FlatButton(
                  onPressed: () => store.dispatcH('AsyncInc'),
                  child: Text('Async(+)')),
              IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: () => store.dispatcH('Dec')),
              StreamConsumer<CounterModel>(
                  initialData: CounterModel.init(),
                  stream: store.select('counter'),
                  builder: (context, state) => state.isLoading
                      ? CircularProgressIndicator()
                      : Text(state.count.toString())),
            ],
          ),
          BlocConsumer<CounterBloc, CounterModel>(
            //listenWhen: (previous, current) => current != null,
            listener: (context, state) {
              print(state.count);
            },
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
          StreamConsumer<String>(
            initialData: "",
            stream: context
                .bloc<CounterBloc>()
                .mergeWith(store.storeInstance())
                .onState(store.select('counter'))
                //.onActions(['AsyncInc'])
                .mapEmit<CounterModel, CounterModel, String>(
                    (action, state1, state2) =>
                        'sum: ${state1.count + state2.count}'),
            builder: (context, state) => Text(state),
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
              onPressed: () => context.bloc<CounterBloc>().dispatcH('Inc'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: FloatingActionButton(
              child: Text('Async'),
              onPressed: () => context.bloc<CounterBloc>().dispatcH('AsyncInc'),
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
              onPressed: () => store.dispatcH('themeChange'),
            ),
          ),
        ],
      ),
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

class CounterState extends StateBase<CounterModel> {
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

class ThemeState extends StateBase<ThemeData> {
  ThemeState() : super(name: 'theme', initialState: _lightTheme);

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
