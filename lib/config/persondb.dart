import 'package:operation_flutter/models/person.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class PersonDb {
  final String dbName;
  Database? _db;
  List<Person> _persons = [];
  final _streamController = StreamController<List<Person>>.broadcast();

  PersonDb({required this.dbName});

  Future<List<Person>> _fetchPeople() async {
    final db = _db;
    if (db == null) {
      return [];
    }
    try {
      final read = await db.query(
        'PEOPLE',
        distinct: true,
        columns: [
          'ID',
          'FIRST_NAME',
          'LAST_NAME',
        ],
        orderBy: 'ID',
      );
      final people = read.map((row) => Person.fromRow(row)).toList();
      return people;
    } catch (e) {
      print('Erreur fetching people = $e');
      return [];
    }
  }

  Future<bool> create(String firstName, String lastName) async {
    final db = _db;
    if (db == null) {
      return false;
    }
    try {
      final id = await db.insert('PEOPLE', {
        'FIRST_NAME': firstName,
        'LASTN_AME': lastName,
      });
      final person = Person(id: id, firstName: firstName, lastName: lastName);
      _persons.add(person);
      _streamController.add(_persons);
      return true;
    } catch (e) {
      print('Error of creating of personne = $e');
      return false;
    }
  }

  Future<bool> delete(Person person) async {
    final db = _db;
    if (db == null) {
      return false;
    }
    try {
      final deletedCount = await db.delete(
        'PEOPLE',
        where: 'ID=?',
        whereArgs: [person.id],
      );

      if (deletedCount == 1) {
        _persons.remove(person);
        _streamController.add(_persons);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Delete failde with erreu $e');
      return false;
    }
  }

  Future<bool> close() async {
    final db = _db;
    if (_db == null) {
      return false;
    }
    await db!.close();
    return true;
  }

  Future<bool> open() async {
    if (_db != null) {
      return true;
    }
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/$dbName';

    try {
      final db = await openDatabase(path);
      _db = db;

      //create table
      final create =
          '''CREATE TABLE IF NOT EXISTS PEOPLE(ID INTEGER PRIMARY KEY AUTOINCREMENT,
      FIRST_NAME STRING NOT NULL,
      LASTN_AME STRING NOT NULL)''';

      await db.execute(create);

      _persons = await _fetchPeople();
      _streamController.add(_persons);
      return true;
    } catch (e) {
      print('Erreur = $e');
      return false;
    }
  }

  Future<bool> update(Person person) async {
    final db = _db;
    if (db == null) {
      return false;
    }
    try {
      final updateCount = await db.update(
        'PEOPLE',
        {
          'FIRST_NAME': person.firstName,
          'LASTN_AME': person.lastName,
        },
        where: 'ID = ?',
        whereArgs: [person.id],
      );

      if (updateCount == 1) {
        _persons.removeWhere((other) => other.id == person.id);
        _persons.add(person);
        _streamController.add(_persons);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Failed to update personne error =$e');
      return false;
    }
  }

  Stream<List<Person>> all() =>
      _streamController.stream.map((persons) => persons..sort());
}
