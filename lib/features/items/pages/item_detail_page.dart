import 'package:flutter/material.dart';

import '../data/item_repository.dart';
import '../models/item.dart';
import '../widgets/status_chip.dart';

class ItemDetailPage extends StatefulWidget {
  const ItemDetailPage({super.key, required this.itemId, required this.repository});

  final String itemId;
  final ItemRepository repository;

  @override
  State<ItemDetailPage> createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends State<ItemDetailPage> {
  late final Stream<Item?> _stream = widget.repository.watchOne(widget.itemId);
  bool _busy = false;

  void _show(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _claim() async {
    setState(() => _busy = true);
    try {
      await widget.repository.markClaimed(widget.itemId);
      if (mounted) _show('Marked as claimed');
    } on AlreadyClaimedException catch (e) {
      if (mounted) _show('$e');
    } catch (e) {
      if (mounted) _show('Could not update: $e');
    }
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete item?'),
        content: const Text('This will remove the post for everyone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok != true) return;
    await widget.repository.remove(widget.itemId);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Item'),
        actions: [
          IconButton(icon: const Icon(Icons.delete), onPressed: _delete),
        ],
      ),
      body: StreamBuilder<Item?>(
        stream: _stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final item = snapshot.data;
          if (item == null) {
            return const Center(child: Text('This item was deleted'));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.title,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                  StatusChip(item.status),
                ],
              ),
              const SizedBox(height: 16),
              Text('Category: ${item.category}'),
              Text('Location: ${item.location}'),
              Text('Posted by: ${item.postedBy}'),
              const SizedBox(height: 16),
              Text(item.description.isEmpty ? 'No description' : item.description),
              const SizedBox(height: 24),
              if (item.status != 'Claimed')
                ElevatedButton(
                  onPressed: _busy ? null : _claim,
                  child: Text(_busy ? 'Please wait...' : 'Mark as Claimed'),
                ),
            ],
          );
        },
      ),
    );
  }
}
