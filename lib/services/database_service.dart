import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/url_item.dart';
import '../models/collection.dart';
import '../models/url_collection_relation.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('smart_web_clip.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    // Initialize FFI for desktop platforms
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // URL Items table
    await db.execute('''
      CREATE TABLE url_items (
        id TEXT PRIMARY KEY,
        url TEXT NOT NULL,
        title TEXT NOT NULL,
        thumbnail_path TEXT,
        check_type TEXT NOT NULL,
        html_selector TEXT,
        html_custom_condition TEXT,
        last_content_hash TEXT,
        last_updated_at TEXT,
        last_checked_at TEXT,
        is_active INTEGER NOT NULL DEFAULT 1,
        error_count INTEGER NOT NULL DEFAULT 0,
        last_error_message TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Collections table
    await db.execute('''
      CREATE TABLE collections (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        display_order INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // URL-Collection relations table
    await db.execute('''
      CREATE TABLE url_collection_relations (
        url_item_id TEXT NOT NULL,
        collection_id TEXT NOT NULL,
        created_at TEXT NOT NULL,
        PRIMARY KEY (url_item_id, collection_id),
        FOREIGN KEY (url_item_id) REFERENCES url_items (id) ON DELETE CASCADE,
        FOREIGN KEY (collection_id) REFERENCES collections (id) ON DELETE CASCADE
      )
    ''');

    // Indexes
    await db.execute(
        'CREATE INDEX idx_url_items_updated_at ON url_items(last_updated_at DESC)');
    await db.execute(
        'CREATE INDEX idx_url_items_created_at ON url_items(created_at DESC)');
    await db.execute(
        'CREATE INDEX idx_collections_display_order ON collections(display_order ASC)');
  }

  // URL Items CRUD operations
  Future<String> createUrlItem(UrlItem item) async {
    final db = await database;
    await db.insert('url_items', item.toMap());
    return item.id;
  }

  Future<UrlItem?> getUrlItem(String id) async {
    final db = await database;
    final maps = await db.query(
      'url_items',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return UrlItem.fromMap(maps.first);
    }
    return null;
  }

  Future<List<UrlItem>> getAllUrlItems({
    String? orderBy,
    bool descending = true,
  }) async {
    final db = await database;
    final order = descending ? 'DESC' : 'ASC';
    final orderByClause = orderBy ?? 'last_updated_at $order';

    final maps = await db.query(
      'url_items',
      orderBy: orderByClause,
    );

    return maps.map((map) => UrlItem.fromMap(map)).toList();
  }

  Future<List<UrlItem>> getUrlItemsByCollection(String collectionId) async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT u.* FROM url_items u
      INNER JOIN url_collection_relations r ON u.id = r.url_item_id
      WHERE r.collection_id = ?
      ORDER BY u.last_updated_at DESC
    ''', [collectionId]);

    return maps.map((map) => UrlItem.fromMap(map)).toList();
  }

  Future<List<UrlItem>> getUncategorizedUrlItems() async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT u.* FROM url_items u
      LEFT JOIN url_collection_relations r ON u.id = r.url_item_id
      WHERE r.collection_id IS NULL
      ORDER BY u.last_updated_at DESC
    ''');

    return maps.map((map) => UrlItem.fromMap(map)).toList();
  }

  Future<int> updateUrlItem(UrlItem item) async {
    final db = await database;
    return await db.update(
      'url_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteUrlItem(String id) async {
    final db = await database;
    return await db.delete(
      'url_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteUrlItems(List<String> ids) async {
    final db = await database;
    final batch = db.batch();
    for (final id in ids) {
      batch.delete('url_items', where: 'id = ?', whereArgs: [id]);
    }
    final results = await batch.commit();
    return results.length;
  }

  // Collections CRUD operations
  Future<String> createCollection(Collection collection) async {
    final db = await database;
    await db.insert('collections', collection.toMap());
    return collection.id;
  }

  Future<Collection?> getCollection(String id) async {
    final db = await database;
    final maps = await db.query(
      'collections',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Collection.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Collection>> getAllCollections() async {
    final db = await database;
    final maps = await db.query(
      'collections',
      orderBy: 'display_order ASC',
    );

    return maps.map((map) => Collection.fromMap(map)).toList();
  }

  Future<int> updateCollection(Collection collection) async {
    final db = await database;
    return await db.update(
      'collections',
      collection.toMap(),
      where: 'id = ?',
      whereArgs: [collection.id],
    );
  }

  Future<int> deleteCollection(String id) async {
    final db = await database;
    return await db.delete(
      'collections',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // URL-Collection relations
  Future<void> addUrlToCollection(String urlItemId, String collectionId) async {
    final db = await database;
    final relation = UrlCollectionRelation(
      urlItemId: urlItemId,
      collectionId: collectionId,
    );
    await db.insert('url_collection_relations', relation.toMap());
  }

  Future<void> removeUrlFromCollection(
      String urlItemId, String collectionId) async {
    final db = await database;
    await db.delete(
      'url_collection_relations',
      where: 'url_item_id = ? AND collection_id = ?',
      whereArgs: [urlItemId, collectionId],
    );
  }

  Future<void> addUrlsToCollection(
      List<String> urlItemIds, String collectionId) async {
    final db = await database;
    final batch = db.batch();
    for (final urlItemId in urlItemIds) {
      final relation = UrlCollectionRelation(
        urlItemId: urlItemId,
        collectionId: collectionId,
      );
      batch.insert('url_collection_relations', relation.toMap(),
          conflictAlgorithm: ConflictAlgorithm.ignore);
    }
    await batch.commit();
  }

  Future<List<Collection>> getCollectionsForUrl(String urlItemId) async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT c.* FROM collections c
      INNER JOIN url_collection_relations r ON c.id = r.collection_id
      WHERE r.url_item_id = ?
      ORDER BY c.display_order ASC
    ''', [urlItemId]);

    return maps.map((map) => Collection.fromMap(map)).toList();
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
