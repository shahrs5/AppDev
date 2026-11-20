import 'package:flutter/material.dart';

import '../data/item_repository.dart';
import '../models/item.dart';

class AddItemPage extends StatefulWidget {
  const AddItemPage({super.key, required this.repository});

  final ItemRepository repository;

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _category = TextEditingController();
  final _location = TextEditingController();
  final _description = TextEditingController();
  final _postedBy = TextEditingController();
  String _status = 'Found';
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    _category.dispose();
    _location.dispose();
    _description.dispose();
    _postedBy.dispose();
    super.dispose();
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await widget.repository.add(Item(
        id: '',
        title: _title.text.trim(),
        category: _category.text.trim(),
        location: _location.text.trim(),
        status: _status,
        description: _description.text.trim(),
        postedBy: _postedBy.text.trim(),
      ));
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not save: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Item')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: _required,
            ),
            TextFormField(
              controller: _category,
              decoration: const InputDecoration(labelText: 'Category'),
              validator: _required,
            ),
            TextFormField(
              controller: _location,
              decoration: const InputDecoration(labelText: 'Location'),
              validator: _required,
            ),
            DropdownButtonFormField<String>(
              initialValue: _status,
              decoration: const InputDecoration(labelText: 'Status'),
              items: const [
                DropdownMenuItem(value: 'Lost', child: Text('Lost')),
                DropdownMenuItem(value: 'Found', child: Text('Found')),
              ],
              onChanged: (value) => setState(() => _status = value ?? 'Found'),
            ),
            TextFormField(
              controller: _description,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            TextFormField(
              controller: _postedBy,
              decoration: const InputDecoration(labelText: 'Your name'),
              validator: _required,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              child: Text(_saving ? 'Saving...' : 'Post Item'),
            ),
          ],
        ),
      ),
    );
  }
}
