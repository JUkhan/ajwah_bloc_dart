import 'package:ajwah_bloc/ajwah_bloc.dart';
import 'package:ajwah_block_examples/actionTypes.dart';
import 'package:ajwah_block_examples/wikiSearch/store/SearchState.dart';
import 'package:flutter_web/material.dart';

class SearchComponent extends StatelessWidget {
  const SearchComponent({Key key}) : super(key: key);

  searchInput(String text) {
    dispatch(actionType: ActionTypes.SearchInput, payload: text);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SearchModel>(
      stream: store().select(stateName: 'search'),
      builder: (BuildContext context, AsyncSnapshot<SearchModel> snapshot) {
        if (snapshot.hasData) {
          return Column(mainAxisSize: MainAxisSize.max, children: <Widget>[
            TextField(
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
    );
  }
}
