import 'package:ajwah_bloc/ajwah_bloc.dart';
import 'package:ajwah_bloc_examples/actionTypes.dart';
import 'package:ajwah_bloc_examples/store/states/SearchState.dart';
import 'package:ajwah_bloc_examples/widgets/popupMenu.dart';
import 'package:flutter/material.dart';

class SearchComponent extends StatelessWidget {
  const SearchComponent({Key key}) : super(key: key);

  searchInput(String text) {
    dispatch(ActionTypes.SearchInput, text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wiki Search'),
        actions: <Widget>[PopupMemu()],
      ),
      body: Container(
        child: StreamBuilder<SearchModel>(
          stream: select('search'),
          builder: (BuildContext context, AsyncSnapshot<SearchModel> snapshot) {
            if (snapshot.hasData) {
              return Column(mainAxisSize: MainAxisSize.max, children: <Widget>[
                TextField(
                  autofocus: true,
                  decoration: InputDecoration(
                      prefix: snapshot.data.isLoading
                          ? CircularProgressIndicator()
                          : null,
                      hintText: 'Wiki search',
                      icon: Icon(Icons.search)),
                  onChanged: searchInput,
                ),
                Expanded(
                    child: ListView.builder(
                  itemCount: snapshot.data.data.length,
                  itemBuilder: (context, position) {
                    return ListTile(
                      title: Text(snapshot.data.data[position]),
                    );
                  },
                )),
              ]);
            } else if (snapshot.hasError) {
              return Text(snapshot.error.toString());
            }
            return Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
