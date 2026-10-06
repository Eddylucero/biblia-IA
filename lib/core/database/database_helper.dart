import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();
  static const String _assetPath = 'assets/database/bible.db';
  static const String _databaseName = 'bible.db';

  Database? _database;
  Future<Database>? _databaseFuture;

  Future<Database> get database async {
    if (_database case final database?) return database;
    final pendingDatabase = _databaseFuture;
    if (pendingDatabase != null) return pendingDatabase;

    final databaseFuture = _openDatabase();
    _databaseFuture = databaseFuture;
    try {
      return await databaseFuture;
    } catch (_) {
      _databaseFuture = null;
      rethrow;
    }
  }

  Future<Database> _openDatabase() async {
    final databaseDirectory = await getDatabasesPath();
    final databasePath = path.join(databaseDirectory, _databaseName);
    final databaseFile = File(databasePath);

    if (!await databaseFile.exists()) {
      await databaseFile.parent.create(recursive: true);
      final assetData = await rootBundle.load(_assetPath);
      await databaseFile.writeAsBytes(
        assetData.buffer.asUint8List(
          assetData.offsetInBytes,
          assetData.lengthInBytes,
        ),
        flush: true,
      );
    }

    final database = await openDatabase(databasePath, readOnly: true);
    _database = database;
    return database;
  }
}
