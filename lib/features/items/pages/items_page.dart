import 'package:flutter/material.dart';

import '../data/item_repository.dart';
import '../models/item.dart';
import '../widgets/status_chip.dart';
import 'add_item_page.dart';
import 'item_detail_page.dart';

class ItemsPage extends StatefulWidget {
  const ItemsPage({super.key});

  @override
  State<ItemsPage> createState() => _ItemsPageState();
}

class _ItemsPageState extends State<ItemsPage> {
  final _repo = ItemRepository();
  late final Stream<List<Item>> _stream = _repo.watchAll();

  String _search = '';
  String _statusFilter = 'All';

  List<Item> _applyFilters(List<Item> items) {
    var list = items;
    final q = _search.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((i) => i.title.toLowerCase().contains(q)).toList();
    }
    if (_statusFilter != 'All') {
      list = list.where((i) => i.status == _statusFilter).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lost & Found')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              onChanged: (value) => setState(() => _search = value),
              decoration: const InputDecoration(
                hintText: 'Search by title',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text('Status: '),
                DropdownButton<String>(
                  value: _statusFilter,
                  items: ['All', ...Item.statuses]
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (value) => setState(() => _statusFilter = value ?? 'All'),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Item>>(
              stream: _stream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Could not load items:\n${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final items = _applyFilters(snapshot.data!);
                if (items.isEmpty) {
                  return const Center(child: Text('No items found'));
                }
                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ListTile(
                      title: Text(item.title),
                      subtitle: Text('${item.category} • ${item.location}'),
                      trailing: StatusChip(item.status),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ItemDetailPage(itemId: item.id, repository: _repo),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AddItemPage(repository: _repo)),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
