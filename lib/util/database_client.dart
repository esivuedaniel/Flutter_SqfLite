import 'dart:async';
import 'dart:io';
import 'package:notodoapp/model/nodoItem.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper{
  //this class is responsible for creating the database, table, etc
  //initiate a singleton

  static final DatabaseHelper _instance=new DatabaseHelper.internal();
  factory DatabaseHelper()=>_instance;

  final String tableUser="nodoTbl";
  final String columnID="id";
  final String columnItemName="itemName";
  final String columnDateCreated="dateCreated";

  static Database _db;
  Future<Database> get db async{
    if(_db !=null){
      return _db;
    }
    //if db is null, create a new db
    _db=await initDb();
    return _db;
  }
  DatabaseHelper.internal();

  initDb() async {
    //create our database here. Get the app doc dirctory
    Directory documentDirectory=await getApplicationDocumentsDirectory();
    String path=join(documentDirectory.path, "notodo_db.db"); //home://dirctory/files/main.db

    var ourDb=await openDatabase(path,version: 1, onCreate: _onCreate);
    return ourDb;
  }


  void _onCreate(Database db, int version) async{
    //the db that excecute take a sql query and a list of argument
    await db.execute(
        "CREATE TABLE $tableUser($columnID INTEGER PRIMARY KEY, $columnItemName TEXT, $columnDateCreated TEXT)");
  }

  //CRUD

  //iNSERT.  When you insert anything into the database, it returns an integer which is 1 0r 0.
  //1 means everything works correctly, 0 means something went wrong
  Future<int> saveUser(NoDoItem user) async{
    var dbClient=await db;
    int res=await dbClient.insert("$tableUser", user.toMap());
    return res;
  }

  //Get user
  Future<List> getAllUsers() async{
    var dbClient=await db;
    var result=await dbClient.rawQuery("SELECT * FROM $tableUser ORDER BY $columnItemName ASC");
    return result.toList();
  }

  //get the count for all items in the rows
  Future<int> getCount() async{
    var dbClient=await db;
    return Sqflite.firstIntValue(
        await dbClient.rawQuery("SELECT COUNT(*) FROM $tableUser"));
  }

  //GET ONE USER
  Future<NoDoItem> getUser(int id) async{
    var dbClient=await db;
    var result=await dbClient.rawQuery("SELECT * FROM $tableUser WHERE $columnID=$id");
    if(result.length==0) return null;
    return new NoDoItem.fromMap(result.first);
  }

//delet user from db
  Future<int> deleteUser(int id) async{
    var dbClient=await db;
    return await dbClient.delete(tableUser, where: "$columnID =?", whereArgs: [id]);
  }

//update
  Future<int> updateUser(NoDoItem user) async{
    var dbClient=await db;
    return await dbClient.update(tableUser, user.toMap(), where: "$columnID = ?", whereArgs: [user.id]);
  }

//we need to close our db once we are done with everything
  Future close()async{
    var dbClient=await db;
    return dbClient.close();
  }

}