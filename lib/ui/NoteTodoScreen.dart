import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notodoapp/model/nodoItem.dart';
import 'package:notodoapp/util/database_client.dart';

class NoteTodoScreen extends StatefulWidget {
  @override
  _NoteTodoScreenState createState() => _NoteTodoScreenState();
}

class _NoteTodoScreenState extends State<NoteTodoScreen> {

  TextEditingController textEditingController=new TextEditingController();
  var db=new DatabaseHelper();
  final List<NoDoItem> _itemList=<NoDoItem>[];

  @override
  void initState() {
    //this shows the list of notes in the db
    _readNoDoList();
  }

  void _handleSubmitted(String text)async{
    textEditingController.clear();
    NoDoItem noDoItem=new NoDoItem(text, DateFormat("EEE, MMM d, yy").format(DateTime.now()));  //pass d values to be saved 2ru a contructor
    int saveItem= await db.saveUser(noDoItem);  // save in db

    //This shows items that is been savd immediately
    NoDoItem addedItem=await db.getUser(saveItem);
    setState(() {
      _itemList.insert(0, addedItem);  // insert your saved item to your list
    });
    print("Item saved id: $saveItem");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
        body:Column(
          children: [
            Flexible(child: ListView.builder(
              itemCount: _itemList.length,
                reverse: false,
                itemBuilder: (_,int position){
              return Card(
                color: Colors.white10,
                elevation: 10,
                child: ListTile(
                  title: Text(_itemList[position].itemName,
                  style: TextStyle(
                    color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.9
                  ),),
                  subtitle: Text(_itemList[position].dateCreated,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white,
                    fontStyle: FontStyle.italic
                  ),),
                  onLongPress: (){
                    print("Long press me");
                    _updateItem(_itemList[position], position);
                  },
                  trailing: Listener(
                    key: Key(_itemList[position].itemName),
                    onPointerDown: (PointerEvent){
                      //Delete note from the db
                      deleteNoDo(_itemList[position].id, position);
                    },
                    child: Icon(Icons.remove_circle,
                      color: Colors.redAccent,
                    ),
                  ),
                ),
              );
            }))
          ],
        ),

      floatingActionButton: FloatingActionButton(
        tooltip: "Add Item",
        backgroundColor: Colors.redAccent,
        child: ListTile(
          title: Icon(Icons.add),
        ),
        onPressed: _showFromDialog,
      ),
    );
  }

  void _showFromDialog(){

    var alert=new AlertDialog(
      content: Row(
        children: [
          Expanded(
            child: TextField(
              controller: textEditingController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: "Item",
                hintText: "e.g don't buy stuff",
                icon: Icon(Icons.note_add)
              ),
            ),
          )
        ],
      ),
      actions: [
        FlatButton(onPressed: (){
          _handleSubmitted(textEditingController.text);
          textEditingController.clear();
          Navigator.pop(context);
        }, child: Text('Save')),

        FlatButton(onPressed: (){
          Navigator.pop(context);
        }, child: Text('Cancel'))
      ],
    );
    showDialog(context: context,
    builder: (_){
      return alert;
    });
  }
  
  _readNoDoList() async{
    List items=await db.getAllUsers();
    items.forEach((item) {
      setState(() {
        _itemList.add(NoDoItem.map(item));
      });
     // NoDoItem noDoItem=NoDoItem.fromMap(item);
     // print("DB Items: ${noDoItem.itemName}");
    });
  }

  //delete from db
  void deleteNoDo(int id, int position)async {
    await db.deleteUser(id);
    setState(() {
      _itemList.removeAt(position); //update the item in the list after deleting from db
    });

  }

  void _updateItem(NoDoItem item, int position) {
    var alert=AlertDialog(
      content: Row(
        children: [
          Expanded(
            child: TextField(
              controller: textEditingController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: "Item upd",
               // hintText: "write somwthing",
                icon: Icon(Icons.update)
              ),
            ),
          )
        ],
      ),
      actions: [
        FlatButton(
          onPressed: () async{
            NoDoItem newItemUpdate=NoDoItem.fromMap(
              {
                "itemName":textEditingController.text,
                "dateCreated":DateFormat("EEE, MMM d, yy").format(DateTime.now()),
                "id": item.id});
            _handleSubmittedUpdated(position, item); //redrawing the screen
            await db.updateUser(newItemUpdate);  //updating all items in the db
            setState(() {
              _readNoDoList();   //redrawing the screen with all items saved in the db
            });
            Navigator.pop(context);
          },
            child: Text("Update")),

        FlatButton(
          onPressed: ()async{
            Navigator.pop(context);
          },
            child: Text("Cancel")),
      ],
    );

    showDialog(context: context,builder: (_){
      return alert;
    });
  }

  void _handleSubmittedUpdated(int position, NoDoItem item) {
    setState(() {
      _itemList.removeWhere((element)=>_itemList[position].itemName==item.itemName);
    });
  }


}
