import 'package:flutter/material.dart';
import 'package:persistencia/db_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _allData = [];

  bool _isLoading = true;

  void _refreshData() async {
    final data = await SQLHelper.getAllData();
    print('Data $data');
    setState(() {
      _allData = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    _refreshData();

    super.initState();
  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  Future<void> _addData() async {
    SQLHelper.createData(_titleController.text, _descController.text);
    _refreshData();
  }

  Future<void> _updateData(int id) async {
    SQLHelper.updateData(id, _titleController.text, _descController.text);
    _refreshData();
  }

  Future<void> _deleteData(int id) async {
    SQLHelper.deleteData(id);
    _refreshData();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data Deleted'),
      ),
    );
  }

  void showBottomSheet(int? id) {
    if (id != null) {
      final dataExistente =
          _allData.firstWhere((element) => element['id'] == id);
      _titleController.text = dataExistente['title'];
      _descController.text = dataExistente['desc'];
    }

    showModalBottomSheet(
      elevation: 5,
      isScrollControlled: true,
      context: context,
      builder: (_) => Container(
        height: MediaQuery.sizeOf(context).height / 1.5,
        width: MediaQuery.sizeOf(context).width,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Title',
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: TextFormField(
                controller: _descController,
                maxLines: 4,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Description',
                ),
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: FloatingActionButton(
                  onPressed: () {
                    if (id == null) _addData();
                    if (id != null) _updateData(id);

                    _titleController.text = '';
                    _descController.text = '';

                    Navigator.pop(context);
                    print("Data Added");
                  },
                  child: const Icon(Icons.check),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('SQLite Aplication'),
          elevation: 10,
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : ListView.builder(
                itemCount: _allData.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Card(
                      elevation: 5,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(10),
                        title: Text(
                          _allData[index]['title'],
                          style: const TextStyle(fontSize: 20),
                        ),
                        subtitle: Text(
                          _allData[index]['desc'],
                          style: const TextStyle(fontSize: 20),
                        ),
                        trailing: SizedBox(
                          width: 100,
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () =>
                                    showBottomSheet(_allData[index]['id']),
                                icon: const Icon(Icons.update),
                              ),
                              IconButton(
                                onPressed: () =>
                                    _deleteData(_allData[index]['id']),
                                icon: const Icon(Icons.delete),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => showBottomSheet(null),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
