import 'package:database_flutter_crud/services/sql_helper.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _journals = [];

  bool _isloading = true;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  void refreshJournals() async {
    final data = await SQLHelper.getItems();
    setState(() {
      _journals = data;
      _isloading = false;
    });
  }

  Future<void> _addItem() async {
    await SQLHelper.createItem(
        _titleController.text, _descriptionController.text);
    refreshJournals();
    print("... number of item ${_journals.length}");
  }

  Future<void> _updateItem(int id) async {
    await SQLHelper.updateItem(
        id, _titleController.text, _descriptionController.text);
    refreshJournals();
    print("... number of item ${_journals.length}");
  }

  Future<void> _deleteItem(int id) async {
    await SQLHelper.deleteItems(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Successfully deleted a journal"),
      ),
    );
    refreshJournals();
    print("... number of item ${_journals.length}");
  }

  void _showForm(int? id) async {
    if (id != null) {
      final existingJournal =
          _journals.firstWhere((element) => element['id'] == id);
      _titleController.text = existingJournal['title'];
      _descriptionController.text = existingJournal['description'];
    }

    showModalBottomSheet(
      context: context,
      elevation: 5,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: EdgeInsets.only(
            top: 15,
            left: 15,
            right: 15,
            //this will prevent the soft keyboard from covering the text fields
            bottom: MediaQuery.of(context).viewInsets.bottom + 120),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(hintText: "Title"),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(hintText: "Description"),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () async {
                if (id == null) {
                  await _addItem();
                }
                if (id != null) {
                  await _updateItem(id);
                }
                // for clearing the text
                _titleController.text = '';
                _descriptionController.text = '';
                // close the bottom sheet
                Navigator.of(context).pop();
              },
              child: Text(id == null ? "Create New" : "Update"),
            )
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    refreshJournals();
    print(".. number of items ${_journals.length}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SQL"),
      ),
      body: ListView.builder(
          itemCount: _journals.length,
          itemBuilder: (context, index) {
            return Card(
              color: Colors.yellow.shade600,
              margin: const EdgeInsets.all(15.0),
              child: ListTile(
                title: Text(_journals[index]['title']),
                subtitle: Text(_journals[index]['description']),
                trailing: SizedBox(
                  width: 100,
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          _showForm(_journals[index]['id']);
                        },
                        icon: const Icon(Icons.edit),
                      ),
                      IconButton(
                          onPressed: () {
                            _deleteItem(_journals[index]['id']);
                          },
                          icon: const Icon(Icons.delete))
                    ],
                  ),
                ),
              ),
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showForm(null);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
