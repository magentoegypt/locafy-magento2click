import '../entities/category.dart';
import 'detail_category_model.dart';
import 'list_category_model.dart';

abstract class CategoryModel extends ListCategoryModel {
  List<Category>? get categories;

  Map<String?, Category> get categoryList;

  void sortCategoryList({
    List<Category>? categoryList,
    dynamic sortingList,
    String? categoryLayout,
  });

  void refreshCategoryList();

  void mapCategories(List<Category> categories, List<Map> remapCategories);

  Future<void> getCategories({
    lang,
    sortingList,
    categoryLayout,
    List<Map>? remapCategories,
  });

  List<Category>? getCategory({required String parentId});

  /// Why the last [getCategories] failed, or null when it succeeded or is
  /// still running. Lets a screen tell "couldn't load" apart from "this
  /// store has no categories" and offer a retry instead of rendering blank.
  Object? get loadError;

  /// Runs [getCategories] again with the arguments it was last called with.
  Future<void> reloadCategories();

  /// Optimize

  void initSubcategory(Category category, {bool fetchData = false}) {}

  DetailCategoryModel? getDetailCategoryModel(String id) {
    return null;
  }

  List<Category>? get rootCategories =>
      categories?.where((element) => element.isRoot).toList();
}
