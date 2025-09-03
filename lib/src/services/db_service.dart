import 'dart:io';
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart';
import 'package:free_map/src/fm_constants.dart';
import 'package:free_map/src/services/log_service.dart';

class DbService {
  Database? _db;
  final _logService = LogService();

  DbService._();
  factory DbService() => _instance;
  static final _instance = DbService._();

  /// initialize database
  Future<void> _init() async {
    if (_db != null) return;
    final dbPath = await getDatabasesPath();
    _db = await openDatabase(
      version: 1,
      path.join(dbPath, 'free_map.db'),
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE ${TableName.geocode} (${ColName.id} INTEGER PRIMARY KEY AUTOINCREMENT, ${ColName.address} TEXT NOT NULL, ${ColName.data} TEXT NOT NULL)',
        );

        await db.execute(
          'CREATE TABLE ${TableName.address} (${ColName.id} INTEGER PRIMARY KEY AUTOINCREMENT, ${ColName.lat} REAL NOT NULL, ${ColName.lng} REAL NOT NULL, ${ColName.data} TEXT NOT NULL)',
        );

        await db.execute(
          'CREATE TABLE ${TableName.search} (${ColName.id} INTEGER PRIMARY KEY AUTOINCREMENT, ${ColName.query} TEXT NOT NULL, ${ColName.data} TEXT NOT NULL)',
        );

        await db.execute(
          'CREATE TABLE ${TableName.polyline} (${ColName.id} INTEGER PRIMARY KEY AUTOINCREMENT, ${ColName.points} TEXT NOT NULL, ${ColName.data} TEXT NOT NULL)',
        );
      },
    );
  }

  /// Get geocode
  Future<Map<String, dynamic>?> getGeocode(String address) async {
    final res = await _find(
      whereArgs: [address],
      tableName: TableName.geocode,
      where: '${ColName.address} = ?',
    );
    return res == null ? null : jsonDecode(res[ColName.data]);
  }

  /// Save Geocode
  Future<void> saveGeocode(String address, Map<String, dynamic> data) async {
    await _save(
      whereArgs: [address],
      tableName: TableName.geocode,
      where: '${ColName.address} = ?',
      values: {ColName.address: address, ColName.data: jsonEncode(data)},
    );
  }

  /// Get address
  Future<Map<String, dynamic>?> getAddress(double lat, double lng) async {
    final res = await _find(
      whereArgs: [lat, lng],
      tableName: TableName.address,
      where: '${ColName.lat} = ? AND ${ColName.lng} = ?',
    );
    return res == null ? null : jsonDecode(res[ColName.data]);
  }

  /// Save address
  Future<void> saveAddress(
    double lat,
    double lng,
    Map<String, dynamic> data,
  ) async {
    await _save(
      whereArgs: [lat, lng],
      tableName: TableName.address,
      where: '${ColName.lat} = ? AND ${ColName.lng} = ?',
      values: {
        ColName.lat: lat,
        ColName.lng: lng,
        ColName.data: jsonEncode(data)
      },
    );
  }

  /// Get search
  Future<List<dynamic>?> getSearch(Map<String, dynamic> query) async {
    final res = await _find(
      tableName: TableName.search,
      where: '${ColName.query} = ?',
      whereArgs: [jsonEncode(query)],
    );
    return res == null ? null : jsonDecode(res[ColName.data]);
  }

  /// Save search
  Future<void> saveSearch(
    Map<String, dynamic> query,
    List<dynamic> data,
  ) async {
    await _save(
      tableName: TableName.search,
      where: '${ColName.query} = ?',
      whereArgs: [jsonEncode(query)],
      values: {
        ColName.query: jsonEncode(query),
        ColName.data: jsonEncode(data)
      },
    );
  }

  /// Get polyline
  Future<List<dynamic>?> getPolyline(List<dynamic> points) async {
    final res = await _find(
      tableName: TableName.polyline,
      where: '${ColName.points} = ?',
      whereArgs: [jsonEncode(points)],
    );
    return res == null ? null : jsonDecode(res[ColName.data]);
  }

  /// Save search
  Future<void> savePolyline(List<dynamic> points, List<dynamic> data) async {
    await _save(
      tableName: TableName.polyline,
      where: '${ColName.points} = ?',
      whereArgs: [jsonEncode(points)],
      values: {
        ColName.data: jsonEncode(data),
        ColName.points: jsonEncode(points),
      },
    );
  }

  Future<Map<String, dynamic>?> _find({
    required String where,
    required String tableName,
    required List<dynamic> whereArgs,
  }) async {
    if (kIsWeb || (!Platform.isAndroid & !Platform.isIOS)) return null;
    await _init();
    final res = await _db?.query(
      limit: 1,
      tableName,
      where: where,
      whereArgs: whereArgs,
    );
    return res?.firstOrNull;
  }

  Future<void> _save({
    required String where,
    required String tableName,
    required List<dynamic> whereArgs,
    required Map<String, dynamic> values,
  }) async {
    if (kIsWeb || (!Platform.isAndroid & !Platform.isIOS)) return;
    try {
      final res = await _find(
        where: where,
        whereArgs: whereArgs,
        tableName: tableName,
      );

      if (res != null) {
        await _db?.update(
          tableName,
          values,
          where: '${ColName.id} = ?',
          whereArgs: [res[ColName.id]],
        );
      } else {
        await _deleteOld(tableName);
        await _db?.insert(tableName, values);
      }
    } catch (e, st) {
      _logService.logError(e, st);
    }
  }

  Future<void> _deleteOld(String tableName) async {
    final res = await _db?.query(
      tableName,
      columns: [ColName.id],
      orderBy: '${ColName.id} ASC',
    );
    if (res == null || res.length < 100) return;
    final ids = res.take(res.length - 100 + 1).map((e) => e[ColName.id]);
    await _db?.delete(
      tableName,
      where: '${ColName.id} IN (${ids.join(',')})',
    );
  }
}
