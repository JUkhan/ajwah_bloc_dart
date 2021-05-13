import 'package:ajwah_bloc/ajwah_bloc.dart';

enum SearchCategory { All, Active, Completed }

class SearchCategoryState extends StateController<SearchCategory> {
  SearchCategoryState() : super(SearchCategory.All);

  setCategory(SearchCategory category) {
    emit(category);
  }
}
