import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';
import '../models/location.dart';
import 'dart:io';

class PlaceImage {
  // Renamed from ImageInfo to PlaceImage
  final String id;
  final String path;
  final DateTime createdAt;

  PlaceImage({
    required this.id,
    required this.path,
    required this.createdAt,
  });
}

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('photozone.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE areas (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE wards (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        areaId TEXT NOT NULL,
        FOREIGN KEY (areaId) REFERENCES areas (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE places (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        wardId TEXT NOT NULL,
        FOREIGN KEY (wardId) REFERENCES wards (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE images (
        id TEXT PRIMARY KEY,
        placeId TEXT NOT NULL,
        path TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (placeId) REFERENCES places (id)
      )
    ''');
  }

  // CRUD operations for Area
  Future<String> createArea(String name) async {
    final db = await database;
    final id = const Uuid().v4();
    await db.insert('areas', {'id': id, 'name': name});
    return id;
  }

  Future<List<Area>> getAreas() async {
    final db = await database;
    final List<Map<String, dynamic>> areasMaps = await db.query('areas');

    List<Area> areas = [];
    for (var areaMap in areasMaps) {
      final wards = await getWardsForArea(areaMap['id']);
      areas.add(Area(
        id: areaMap['id'],
        name: areaMap['name'],
        wards: wards,
      ));
    }
    return areas;
  }

  // CRUD operations for Ward
  Future<String> createWard(String name, String areaId) async {
    final db = await database;
    final id = const Uuid().v4();
    await db.insert('wards', {
      'id': id,
      'name': name,
      'areaId': areaId,
    });
    return id;
  }

  Future<List<Ward>> getWardsForArea(String areaId) async {
    final db = await database;
    final List<Map<String, dynamic>> wardsMaps = await db.query(
      'wards',
      where: 'areaId = ?',
      whereArgs: [areaId],
    );

    List<Ward> wards = [];
    for (var wardMap in wardsMaps) {
      final places = await getPlacesForWard(wardMap['id']);
      wards.add(Ward(
        id: wardMap['id'],
        name: wardMap['name'],
        areaId: wardMap['areaId'],
        places: places,
      ));
    }
    return wards;
  }

  // CRUD operations for Place
  Future<String> createPlace(String name, String wardId) async {
    final db = await database;
    final id = const Uuid().v4();
    await db.insert('places', {
      'id': id,
      'name': name,
      'wardId': wardId,
    });
    return id;
  }

  Future<List<Place>> getPlacesForWard(String wardId) async {
    final db = await database;
    final List<Map<String, dynamic>> placesMaps = await db.query(
      'places',
      where: 'wardId = ?',
      whereArgs: [wardId],
    );

    List<Place> places = [];
    for (var placeMap in placesMaps) {
      final images = await getImagesForPlace(placeMap['id']);
      places.add(Place(
        id: placeMap['id'],
        name: placeMap['name'],
        wardId: placeMap['wardId'],
        images: images,
      ));
    }
    return places;
  }

  // Image operations
  Future<void> addImageToPlace(String placeId, String imagePath) async {
    final db = await database;
    await db.insert('images', {
      'id': const Uuid().v4(),
      'placeId': placeId,
      'path': imagePath,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Future<List<PlaceImage>> getImagesForPlace(String placeId) async {
    final db = await database;
    final List<Map<String, dynamic>> imagesMaps = await db.query(
      'images',
      where: 'placeId = ?',
      whereArgs: [placeId],
      orderBy: 'createdAt DESC',
    );

    return imagesMaps
        .map((img) => PlaceImage(
              id: img['id'] as String,
              path: img['path'] as String,
              createdAt: DateTime.parse(img['createdAt'] as String),
            ))
        .toList();
  }

  // Search functionality
  Future<List<dynamic>> searchLocations(String query) async {
    final db = await database;
    final areas = await db.query(
      'areas',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
    );
    final wards = await db.query(
      'wards',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
    );
    final places = await db.query(
      'places',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
    );

    return [
      ...areas.map((a) => {'type': 'area', ...a}),
      ...wards.map((w) => {'type': 'ward', ...w}),
      ...places.map((p) => {'type': 'place', ...p}),
    ];
  }

  // Delete operations
  Future<void> deleteArea(String id) async {
    final db = await database;
    await db.transaction((txn) async {
      // Get all wards in this area
      final wards =
          await txn.query('wards', where: 'areaId = ?', whereArgs: [id]);

      for (var ward in wards) {
        // Get all places in this ward
        final places = await txn
            .query('places', where: 'wardId = ?', whereArgs: [ward['id']]);

        for (var place in places) {
          // Delete all images for this place
          final images = await txn
              .query('images', where: 'placeId = ?', whereArgs: [place['id']]);
          for (var image in images) {
            // Delete physical file
            try {
              await File(image['path'] as String).delete();
            } catch (e) {
              print('Error deleting image file: $e');
            }
          }
          // Delete images records
          await txn
              .delete('images', where: 'placeId = ?', whereArgs: [place['id']]);
        }
        // Delete places
        await txn
            .delete('places', where: 'wardId = ?', whereArgs: [ward['id']]);
      }
      // Delete wards
      await txn.delete('wards', where: 'areaId = ?', whereArgs: [id]);
      // Delete area
      await txn.delete('areas', where: 'id = ?', whereArgs: [id]);
    });
  }

  Future<void> deleteWard(String id) async {
    final db = await database;
    await db.transaction((txn) async {
      // Get all places in this ward
      final places =
          await txn.query('places', where: 'wardId = ?', whereArgs: [id]);

      for (var place in places) {
        // Delete all images for this place
        final images = await txn
            .query('images', where: 'placeId = ?', whereArgs: [place['id']]);
        for (var image in images) {
          try {
            await File(image['path'] as String).delete();
          } catch (e) {
            print('Error deleting image file: $e');
          }
        }
        await txn
            .delete('images', where: 'placeId = ?', whereArgs: [place['id']]);
      }
      // Delete places
      await txn.delete('places', where: 'wardId = ?', whereArgs: [id]);
      // Delete ward
      await txn.delete('wards', where: 'id = ?', whereArgs: [id]);
    });
  }

  Future<void> deletePlace(String id) async {
    final db = await database;
    await db.transaction((txn) async {
      // Delete all images for this place
      final images =
          await txn.query('images', where: 'placeId = ?', whereArgs: [id]);
      for (var image in images) {
        try {
          await File(image['path'] as String).delete();
        } catch (e) {
          print('Error deleting image file: $e');
        }
      }
      await txn.delete('images', where: 'placeId = ?', whereArgs: [id]);
      // Delete place
      await txn.delete('places', where: 'id = ?', whereArgs: [id]);
    });
  }

  Future<void> deleteImage(String placeId, String imagePath) async {
    final db = await database;
    await db.transaction((txn) async {
      try {
        await File(imagePath).delete();
      } catch (e) {
        print('Error deleting image file: $e');
      }
      await txn.delete('images',
          where: 'placeId = ? AND path = ?', whereArgs: [placeId, imagePath]);
    });
  }

  // Update operations
  Future<void> updateArea(String id, String newName) async {
    final db = await database;
    await db.update(
      'areas',
      {'name': newName},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateWard(String id, String newName) async {
    final db = await database;
    await db.update(
      'wards',
      {'name': newName},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updatePlace(String id, String newName) async {
    final db = await database;
    await db.update(
      'places',
      {'name': newName},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
