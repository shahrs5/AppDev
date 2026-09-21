import 'package:flutter/material.dart';
import 'package:lser_list/post.dart';
import 'package:lser_list/initials_avatar.dart';

class detailsPage extends StatefulWidget {
  const detailsPage({super.key, required this.data});
  final UserModel data;

  @override
  State<detailsPage> createState() => _detailsPageState();
}

class _detailsPageState extends State<detailsPage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          leading: BackButton(
            color: Colors.black, // Optional: change the color
            onPressed: () {
              // Optional: Add custom code here before popping
              Navigator.of(context).pop();
            },
          ),
        ),
        body: Column(
          children: [
            InitialsAvatar(name: widget.data.name, radius: 40),
            Row(children: [Icon(Icons.person), Text('Name: ' + widget.data.name)]),
            Row(children: [Icon(Icons.email), Text('Email: ' + widget.data.email)]),
            Row(children: [Icon(Icons.phone), Text('Phone: ' + widget.data.phone)]),
            Row(children: [Icon(Icons.home), Text(
              'Address: ' +
                  widget.data.address.street +
                  ', ' +
                  widget.data.address.city,
            )]),
            Row(children: [Icon(Icons.business), Text('Company:' + widget.data.company.name)]),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Message sent to ' + widget.data.name)),
            );
          },
          child: Icon(Icons.message),
        ),
      ),
    );
  }
}
