import 'package:phone/domain/contact.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class ContactHelper {
  static final ContactHelper _instance = ContactHelper.internal();

  factory ContactHelper() => _instance;

  ContactHelper.internal();

  Database? _db;

  Future<Database?> get db async {
    return _db ?? await initDb();
  }

  Future<Database> initDb() async {
    String? databasesPath = await getDatabasesPath();
    String path = join(databasesPath, "contacts.db");

    return await openDatabase(path, version: 1,
        onCreate: (Database db, int newerVersion) async {
      await db.execute(
          "CREATE TABLE ${Contact.contactTable}(${Contact.idColumn} INTEGER PRIMARY KEY, "
          "                                 ${Contact.nameColumn} TEXT, "
          "                                 ${Contact.emailColumn} TEXT, "
          "                                 ${Contact.phoneColumn} TEXT, "
          "                                 ${Contact.imgColumn} TEXT) ");
    });
  }

  Future<Contact> saveContact(Contact contact) async {
    Database? dbContact = await db;
    if (dbContact != null) {
      contact.id =
          await dbContact.insert(Contact.contactTable, contact.toMap());
    }
    return contact;
  }

  Future<Contact?> getContact(int id) async {
    Database? dbContact = await db;
    if (dbContact != null) {
      List<Map> maps = await dbContact.query(Contact.contactTable,
          columns: [
            Contact.idColumn,
            Contact.nameColumn,
            Contact.emailColumn,
            Contact.phoneColumn,
            Contact.imgColumn
          ],
          where: "${Contact.idColumn} = ?",
          whereArgs: [id]);
      return maps.isNotEmpty ? Contact.fromMap(maps.first) : null;
    }
    return null;
  }

  Future<int> deleteContact(int id) async {
    Database? dbContact = await db;
    if (dbContact == null) return 0;
    return await dbContact.delete(Contact.contactTable,
        where: "${Contact.idColumn} = ?", whereArgs: [id]);
  }

  Future<int> updateContact(Contact c) async {
    Database? dbContact = await db;
    if (dbContact != null) {
      return await dbContact.update(Contact.contactTable, c.toMap(),
          where: "${Contact.idColumn} = ?", whereArgs: [c.id]);
    } else {
      return 0;
    }
  }

  Future<List> getAllContact() async {
    Database? dbContact = await db;
    if (dbContact != null) {
      List listMap = await dbContact.query(Contact.contactTable);
      List<Contact> listContacts = [];

      for (Map m in listMap) {
        listContacts.add(Contact.fromMap(m));
      }
      return listContacts;
    } else {
      return [];
    }
  }

  Future<int?> getNumber() async {
    Database? dbContact = await db;
    if (dbContact != null) {
      return Sqflite.firstIntValue(await dbContact
          .rawQuery("SELECT COUNT(*) FROM ${Contact.contactTable}"));
    } else {
      return 0;
    }
  }
}
