import 'package:flutter/material.dart';
import 'package:notodoapp/ui/NoteTodoScreen.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black38,
        title: Text('Note todo',),
      ),
        body: NoteTodoScreen());
  }
}
