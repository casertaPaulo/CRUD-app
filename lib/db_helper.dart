import 'package:sqflite/sqflite.dart' as sql;

class SQLHelper {
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE data(
      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      title TEXT,
      desc TEXT,
      createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP  
    )""");
  }

  static Future<sql.Database> db() async {
    return sql.openDatabase("database_name.db", version: 1,
        onCreate: (sql.Database database, int version) async {
      await createTables(database);
    });
  }

  // Método para adicionar um Data
  static Future<int> createData(String title, String? desc) async {
    final db = await SQLHelper.db();

    final data = {'title': title, 'desc': desc};
    final id = await db.insert('data', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  // Método para pegar todo o Data
  static Future<List<Map<String, dynamic>>> getAllData() async {
    final db = await SQLHelper.db();

    return db.query('data', orderBy: 'id');
  }

  // Método para pegar somente um Data com base no id
  static Future<List<Map<String, dynamic>>> getSingleData(int id) async {
    final db = await SQLHelper.db();
    return db.query('data', where: "id = ?", whereArgs: [id], limit: 1);
  }

  // Método para atualizar um Data com base no id
  static Future<int> updateData(int id, String title, String? desc) async {
    final db = await SQLHelper.db();
    final data = {
      'title': title,
      'desc': desc,
      'createdAt': DateTime.now().toString()
    };
    final result =
        await db.update('data', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  // Método para deletar um Data com base no id
  static Future<void> deleteData(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete('data', where: "id = ?", whereArgs: [id]);
    } catch (e) {
      print('Não foi possível deletar o Data');
    }
  }
}
