import 'package:ajwah_bloc/ajwah_bloc.dart';
import 'package:ajwah_block_examples/actionTypes.dart';
import 'package:ajwah_block_examples/counter/store/counterState.dart';
import 'package:ajwah_block_examples/widgets/popupMenu.dart';
import 'package:flutter_web/material.dart';

class CounterComponent extends StatelessWidget {
  const CounterComponent({Key key}) : super(key: key);

  void increment() {
    dispatch(actionType: ActionTypes.Inc);
  }

  void decrement() {
    dispatch(actionType: ActionTypes.Dec);
  }

  void asyncIncrement() {
    dispatch(actionType: ActionTypes.AsyncInc);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Counter'),
        actions: <Widget>[PopupMemu()],
      ),
      body: Container(
          child: Row(
        children: <Widget>[
          ButtonBar(mainAxisSize: MainAxisSize.min, children: <Widget>[
            RaisedButton(
              textColor: Colors.white,
              color: Colors.blue,
              child: Icon(Icons.add),
              onPressed: increment,
            ),
            new RaisedButton(
              textColor: Colors.white,
              color: Colors.blue,
              child: Text('Async(+)'),
              onPressed: asyncIncrement,
            ),
            RaisedButton(
              textColor: Colors.white,
              color: Colors.blue,
              child: Icon(Icons.remove),
              onPressed: decrement,
            )
          ]),
          SizedBox(
            width: 10.0,
          ),
          StreamBuilder<CounterModel>(
            stream: store().select(stateName: 'counter'),
            builder:
                (BuildContext context, AsyncSnapshot<CounterModel> snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data.isLoading) {
                  return CircularProgressIndicator();
                }
                return Text(
                  snapshot.data.count.toString(),
                  style: Theme.of(context).textTheme.title,
                );
              } else if (snapshot.hasError) {
                return Text(snapshot.error.toString());
              }
              return CircularProgressIndicator();
            },
          )
        ],
      )),
    );
  }
}
