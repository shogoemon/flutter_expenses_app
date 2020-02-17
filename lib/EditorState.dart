import 'package:shared_preferences/shared_preferences.dart';
class EditorInputtedData{
  static bool outOrInBool=true;
  static int inputPrice=0;
  static String selectedCategory;
  static DateTime selectedDay=DateTime.now();
  static List<String> categoryList = [
    '未分類',
    '食費',
    '日用品',
  ];

  static Future<List<String>> loadCategoryList(bool mustLoad)async{
    List<String> addCategoryList;
    if(mustLoad||categoryList==null){
      categoryList=[];
      SharedPreferences prefs=await SharedPreferences.getInstance();
      addCategoryList=prefs.getStringList('expenseCategory');
      if (addCategoryList != null) {
        EditorInputtedData.categoryList += addCategoryList;
      }
    }
    return EditorInputtedData.categoryList;
  }
}