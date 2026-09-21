import 'package:flutter/material.dart';

class detailsPage extends StatefulWidget {
  final String data;

  const detailsPage({super.key, required this.data});

  @override
  State<detailsPage> createState() => _detailsPageState();
}

class _detailsPageState extends State<detailsPage> {

  @override
  Widget build(BuildContext context) {
   
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: Column(
          
        ),
      ),
    );
  }
}