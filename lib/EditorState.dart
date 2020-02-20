class EditorInputtedData{
  static bool graphOutOrInBool=true;
  static bool outOrInBool=true;
  static int inputPrice=0;
  static String inSelectedCategory='給与';
  static String outSelectedCategory='未分類';
  static int ternNum=0;
  static DateTime selectedDay=DateTime.now();
  static DateTime calendarSelectedDay=DateTime.now();
  static DateTime graphSelectedDay=DateTime.now();
  static List<String> inCategoryList = [
    '給与',
    '臨時収入',
    '未分類',
    'その他'
  ];
  static List<String> outCategoryList = [
    '未分類',
    '食費',
    '日用品',
    '交通費',
    '趣味',
    '衣服',
    '教育費',
    'その他'
  ];
}

class ExpenseObj{
  String createTime;
  String year;
  String month;
  String day;
  String category;
  String inOrOut;
  String price;
}