import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExpensesTableDB {
  static Database connectedDB;

  static Future<String> getPath() async {
    //パスを取得
    return join(await getDatabasesPath(), 'expensesTable.db');
  }

  static Future<Database> connectDB() async {
    //データベースを返す。テーブルがなければ作成する。
    connectedDB ??= await openDatabase(
      await getPath(),
      onCreate: (Database db, int version) async {
        createExpensesTable(db);
      },
      version: 1,
    );
    return connectedDB;
  }

  static void createExpensesTable(Database db) async {
    //テーブルを作成
    await db.execute(
        'create table expensesTable(createTime text,year text,month text,day text,category text,inOrOut text,price text)');
  }

  static Future<int> insertData(
      {
        String createTime,
        String year,
        String month,
        String day,
        String category,
        String inOrOut,
        String price
      }) async {
    //returnのintが何の値なのか
    return await connectedDB.insert('expensesTable', {
      'createTime':createTime,
      'year': year,
      'month': month,
      'day': day,
      'category': category,
      'inOrOut': inOrOut,
      'price': price
    });
  }

  static Future<List<Map<String, dynamic>>> getTableData() async {
    return await connectedDB.query('expensesTable');
  }

  static Future<void> updateData(
      {
        String createTime,
        String year,
        String month,
        String day,
        String category,
        String inOrOut,
        String price
      }) async {
    return await connectedDB.update('expensesTable', {
      'createTime':createTime,
      'year': year,
      'month': month,
      'day': day,
      'category': category,
      'inOrOut': inOrOut,
      'price': price
    },
        where: 'createTime=?', whereArgs: [createTime]
    );
  }

  static Future deleteData(String createTime) async {
    return await connectedDB.delete('expensesTable',
        where: 'createTime=?', whereArgs: [createTime]);
  }

  static Future getDataFromCalendar({String year, String month}) async {
    return await connectedDB.query('expensesTable',
        where: 'year=? AND month=?', whereArgs: [year, month],
        orderBy: 'year asc,month asc,day asc');
  }

  static Future getDataFromGraph({String year, String month, String day}) async {
    List<Map<String,dynamic>>loadedTernData;
    if(month==null){
      //一年間のデータ
      loadedTernData=
      await connectedDB.query('expensesTable',
          where: 'year=?', whereArgs: [year],
          orderBy: 'inOrOut asc,category asc');
    }else{
      //一月間のデータ
      if(day==null){
        loadedTernData=
        await connectedDB.query('expensesTable',
            where: 'year=? AND month=?', whereArgs: [year, month],
            orderBy: 'inOrOut asc,category asc');
      }else{
        //１日間のデータ
        loadedTernData=
        await connectedDB.query('expensesTable',
            where: 'year=? AND month=? AND day=?', whereArgs: [year, month, day],
            orderBy: 'inOrOut asc,category asc');
      }
    }
    return loadedTernData;
  }
}