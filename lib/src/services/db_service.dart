import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBService {
  static Database? _db;
  static const String _customersTable = 'customers';
  static const String _ordersTable = 'orders';
  static const String _measurementsTable = 'measurements';
  static const String _shopsTable = 'shops';
  static const String _itemTypesTable = 'item_types';

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'tailoringapp.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_customersTable (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            phone TEXT NOT NULL,
            location TEXT NOT NULL,
            createdAt TEXT NOT NULL,
            lastModified TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE $_ordersTable (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            orderNumber TEXT NOT NULL,
            customerId INTEGER NOT NULL,
            orderDate TEXT NOT NULL,
            dueDate TEXT NOT NULL,
            location TEXT,
            noOfPs INTEGER,
            totalPrice REAL,
            status TEXT NOT NULL,
            totalPieces INTEGER,
            createdAt TEXT NOT NULL,
            lastModified TEXT NOT NULL,
            FOREIGN KEY (customerId) REFERENCES $_customersTable(id)
          )
        ''');
        await db.execute('''
          CREATE TABLE order_details (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            orderId INTEGER NOT NULL,
            itemTypeId INTEGER NOT NULL,
            itemDetail TEXT,
            noOfPs INTEGER,
            price REAL,
            measurementType TEXT,
            createdAt TEXT NOT NULL,
            lastModified TEXT NOT NULL,
            FOREIGN KEY (orderId) REFERENCES $_ordersTable(id),
            FOREIGN KEY (itemTypeId) REFERENCES $_itemTypesTable(id)
          )
        ''');
        await db.execute('''
          CREATE TABLE $_measurementsTable (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            customerId INTEGER NOT NULL,
            itemTypeId INTEGER NOT NULL,
            length TEXT,
            shoulder TEXT,
            slLoose TEXT,
            armHole TEXT,
            chest TEXT,
            hip TEXT,
            point TEXT,
            seat TEXT,
            fNeck TEXT,
            bNeck TEXT,
            bottomLength TEXT,
            bottomWaist TEXT,
            bottom TEXT,
            createdAt TEXT NOT NULL,
            lastModified TEXT NOT NULL,
            FOREIGN KEY (customerId) REFERENCES $_customersTable(id),
            FOREIGN KEY (itemTypeId) REFERENCES $_itemTypesTable(id)
          )
        ''');
        await db.execute('''
          CREATE TABLE $_itemTypesTable (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            type TEXT NOT NULL,
            shortName TEXT NOT NULL,
            description TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE $_shopsTable (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            location TEXT NOT NULL,
            phone TEXT NOT NULL,
            createdAt TEXT NOT NULL,
            lastModified TEXT NOT NULL
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Add itemTypeId column to measurements table
          await db.execute(
            'ALTER TABLE $_measurementsTable ADD COLUMN itemTypeId INTEGER NOT NULL DEFAULT 1',
          );
          // Add foreign key constraint (SQLite doesn't support adding foreign keys to existing tables)
          // We'll recreate the table with the new structure
          await db.execute('DROP TABLE IF EXISTS $_measurementsTable');
        }

        // Since we're resetting, we'll just recreate everything
        await db.execute('DROP TABLE IF EXISTS order_details');
        await db.execute('DROP TABLE IF EXISTS $_ordersTable');
        await db.execute('DROP TABLE IF EXISTS $_measurementsTable');
        await db.execute('DROP TABLE IF EXISTS $_customersTable');
        await db.execute('DROP TABLE IF EXISTS $_itemTypesTable');
        await db.execute('DROP TABLE IF EXISTS $_shopsTable');

        // Recreate tables
        await db.execute('''
          CREATE TABLE $_customersTable (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            phone TEXT NOT NULL,
            location TEXT NOT NULL,
            createdAt TEXT NOT NULL,
            lastModified TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE $_ordersTable (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            orderNumber TEXT NOT NULL,
            customerId INTEGER NOT NULL,
            orderDate TEXT NOT NULL,
            dueDate TEXT NOT NULL,
            location TEXT,
            noOfPs INTEGER,
            totalPrice REAL,
            status TEXT NOT NULL,
            totalPieces INTEGER,
            createdAt TEXT NOT NULL,
            lastModified TEXT NOT NULL,
            FOREIGN KEY (customerId) REFERENCES $_customersTable(id)
          )
        ''');
        await db.execute('''
          CREATE TABLE order_details (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            orderId INTEGER NOT NULL,
            itemTypeId INTEGER NOT NULL,
            itemDetail TEXT,
            noOfPs INTEGER,
            price REAL,
            measurementType TEXT,
            createdAt TEXT NOT NULL,
            lastModified TEXT NOT NULL,
            FOREIGN KEY (orderId) REFERENCES $_ordersTable(id),
            FOREIGN KEY (itemTypeId) REFERENCES $_itemTypesTable(id)
          )
        ''');
        await db.execute('''
          CREATE TABLE $_measurementsTable (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            customerId INTEGER NOT NULL,
            itemTypeId INTEGER NOT NULL,
            length TEXT,
            shoulder TEXT,
            slLoose TEXT,
            armHole TEXT,
            chest TEXT,
            hip TEXT,
            point TEXT,
            seat TEXT,
            fNeck TEXT,
            bNeck TEXT,
            bottomLength TEXT,
            bottomWaist TEXT,
            bottom TEXT,
            createdAt TEXT NOT NULL,
            lastModified TEXT NOT NULL,
            FOREIGN KEY (customerId) REFERENCES $_customersTable(id),
            FOREIGN KEY (itemTypeId) REFERENCES $_itemTypesTable(id)
          )
        ''');
        await db.execute('''
          CREATE TABLE $_itemTypesTable (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            type TEXT NOT NULL,
            shortName TEXT NOT NULL,
            description TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE $_shopsTable (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            location TEXT NOT NULL,
            phone TEXT NOT NULL,
            createdAt TEXT NOT NULL,
            lastModified TEXT NOT NULL
          )
        ''');
      },
    );
  }

  static Future<int> insertCustomer(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(_customersTable, data);
  }

  static Future<int> updateCustomer(int id, Map<String, dynamic> data) async {
    final db = await database;
    return await db.update(
      _customersTable,
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int> deleteCustomer(int id) async {
    final db = await database;
    return await db.delete(_customersTable, where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<Map<String, dynamic>>> getAllCustomers() async {
    final db = await database;
    return await db.query(_customersTable, orderBy: 'createdAt DESC');
  }

  static Future<int> insertOrder(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(_ordersTable, data);
  }

  static Future<int> updateOrder(int id, Map<String, dynamic> data) async {
    final db = await database;
    return await db.update(
      _ordersTable,
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int> deleteOrder(int id) async {
    final db = await database;
    return await db.delete(_ordersTable, where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<Map<String, dynamic>>> getAllOrders() async {
    final db = await database;
    return await db.query(_ordersTable, orderBy: 'createdAt DESC');
  }

  static Future<int> insertMeasurement(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(_measurementsTable, data);
  }

  static Future<int> updateMeasurement(
    int id,
    Map<String, dynamic> data,
  ) async {
    final db = await database;
    return await db.update(
      _measurementsTable,
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int> deleteMeasurement(int id) async {
    final db = await database;
    return await db.delete(
      _measurementsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<List<Map<String, dynamic>>> getAllMeasurements() async {
    final db = await database;
    return await db.query(_measurementsTable, orderBy: 'createdAt DESC');
  }

  static Future<int> insertShop(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(_shopsTable, data);
  }

  static Future<int> updateShop(int id, Map<String, dynamic> data) async {
    final db = await database;
    return await db.update(_shopsTable, data, where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> deleteShop(int id) async {
    final db = await database;
    return await db.delete(_shopsTable, where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<Map<String, dynamic>>> getAllShops() async {
    final db = await database;
    return await db.query(_shopsTable, orderBy: 'createdAt DESC');
  }

  static Future<int> insertItemType(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(_itemTypesTable, data);
  }

  static Future<int> updateItemType(int id, Map<String, dynamic> data) async {
    final db = await database;
    return await db.update(
      _itemTypesTable,
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int> deleteItemType(int id) async {
    final db = await database;
    return await db.delete(_itemTypesTable, where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<Map<String, dynamic>>> getAllItemTypes() async {
    final db = await database;
    return await db.query(_itemTypesTable, orderBy: 'type ASC');
  }

  static Future<int> insertOrderDetail(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert('order_details', data);
  }

  static Future<int> updateOrderDetail(
    int id,
    Map<String, dynamic> data,
  ) async {
    final db = await database;
    return await db.update(
      'order_details',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int> deleteOrderDetail(int id) async {
    final db = await database;
    return await db.delete('order_details', where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<Map<String, dynamic>>> getOrderDetailsByOrderId(
    int orderId,
  ) async {
    final db = await database;
    return await db.query(
      'order_details',
      where: 'orderId = ?',
      whereArgs: [orderId],
    );
  }

  // Update order status
  static Future<int> updateOrderStatus(int id, String status) async {
    final db = await database;
    return await db.update(
      _ordersTable,
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Calculate and update total pieces for an order
  static Future<void> updateOrderTotalPieces(int orderId) async {
    final db = await database;
    final details = await getOrderDetailsByOrderId(orderId);
    int totalPieces = 0;
    for (final detail in details) {
      totalPieces += (detail['noOfPs'] as int?) ?? 0;
    }
    await db.update(
      _ordersTable,
      {'totalPieces': totalPieces},
      where: 'id = ?',
      whereArgs: [orderId],
    );
  }

  // Reset database completely
  static Future<void> resetDatabase() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
    }
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'tailoringapp.db');
    await deleteDatabase(path);
  }

  // --- SYNC SUPPORT FOR CUSTOMERS ---

  // Add or update a customer by id (upsert)
  static Future<void> upsertCustomer(Map<String, dynamic> data) async {
    final db = await database;
    final id = data['id'];
    if (id == null) return;
    final existing = await db.query(
      _customersTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (existing.isEmpty) {
      await db.insert(_customersTable, data);
    } else {
      await db.update(_customersTable, data, where: 'id = ?', whereArgs: [id]);
    }
  }

  // Get customers changed since a timestamp (ISO8601 string)
  static Future<List<Map<String, dynamic>>> getCustomersChangedSince(
    String lastModified,
  ) async {
    final db = await database;
    return await db.query(
      _customersTable,
      where: 'lastModified > ?',
      whereArgs: [lastModified],
    );
  }

  // Bulk upsert customers
  static Future<void> upsertCustomers(
    List<Map<String, dynamic>> customers,
  ) async {
    for (final customer in customers) {
      await upsertCustomer(customer);
    }
  }

  // --- SYNC SUPPORT FOR ORDERS ---

  // Add or update an order by id (upsert)
  static Future<void> upsertOrder(Map<String, dynamic> data) async {
    final db = await database;
    final id = data['id'];
    if (id == null) return;
    final existing = await db.query(
      _ordersTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (existing.isEmpty) {
      await db.insert(_ordersTable, data);
    } else {
      await db.update(_ordersTable, data, where: 'id = ?', whereArgs: [id]);
    }
  }

  // Get orders changed since a timestamp (ISO8601 string)
  static Future<List<Map<String, dynamic>>> getOrdersChangedSince(
    String lastModified,
  ) async {
    final db = await database;
    return await db.query(
      _ordersTable,
      where: 'lastModified > ?',
      whereArgs: [lastModified],
    );
  }

  // Bulk upsert orders
  static Future<void> upsertOrders(List<Map<String, dynamic>> orders) async {
    for (final order in orders) {
      await upsertOrder(order);
    }
  }

  // --- SYNC SUPPORT FOR ORDER_DETAILS ---

  // Add or update an order detail by id (upsert)
  static Future<void> upsertOrderDetail(Map<String, dynamic> data) async {
    final db = await database;
    final id = data['id'];
    if (id == null) return;
    final existing = await db.query(
      'order_details',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (existing.isEmpty) {
      await db.insert('order_details', data);
    } else {
      await db.update('order_details', data, where: 'id = ?', whereArgs: [id]);
    }
  }

  // Get order_details changed since a timestamp (ISO8601 string)
  static Future<List<Map<String, dynamic>>> getOrderDetailsChangedSince(
    String lastModified,
  ) async {
    final db = await database;
    return await db.query(
      'order_details',
      where: 'lastModified > ?',
      whereArgs: [lastModified],
    );
  }

  // Bulk upsert order_details
  static Future<void> upsertOrderDetails(
    List<Map<String, dynamic>> details,
  ) async {
    for (final detail in details) {
      await upsertOrderDetail(detail);
    }
  }

  // --- SYNC SUPPORT FOR MEASUREMENTS ---

  // Add or update a measurement by id (upsert)
  static Future<void> upsertMeasurement(Map<String, dynamic> data) async {
    final db = await database;
    final id = data['id'];
    if (id == null) return;
    final existing = await db.query(
      _measurementsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (existing.isEmpty) {
      await db.insert(_measurementsTable, data);
    } else {
      await db.update(
        _measurementsTable,
        data,
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  // Get measurements changed since a timestamp (ISO8601 string)
  static Future<List<Map<String, dynamic>>> getMeasurementsChangedSince(
    String lastModified,
  ) async {
    final db = await database;
    return await db.query(
      _measurementsTable,
      where: 'lastModified > ?',
      whereArgs: [lastModified],
    );
  }

  // Bulk upsert measurements
  static Future<void> upsertMeasurements(
    List<Map<String, dynamic>> measurements,
  ) async {
    for (final measurement in measurements) {
      await upsertMeasurement(measurement);
    }
  }

  // --- SYNC SUPPORT FOR SHOPS ---

  // Add or update a shop by id (upsert)
  static Future<void> upsertShop(Map<String, dynamic> data) async {
    final db = await database;
    final id = data['id'];
    if (id == null) return;
    final existing = await db.query(
      _shopsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (existing.isEmpty) {
      await db.insert(_shopsTable, data);
    } else {
      await db.update(_shopsTable, data, where: 'id = ?', whereArgs: [id]);
    }
  }

  // Get shops changed since a timestamp (ISO8601 string)
  static Future<List<Map<String, dynamic>>> getShopsChangedSince(
    String lastModified,
  ) async {
    final db = await database;
    return await db.query(
      _shopsTable,
      where: 'lastModified > ?',
      whereArgs: [lastModified],
    );
  }

  // Bulk upsert shops
  static Future<void> upsertShops(List<Map<String, dynamic>> shops) async {
    for (final shop in shops) {
      await upsertShop(shop);
    }
  }

  // --- SYNC SUPPORT FOR ITEM TYPES ---

  // Add or update an item type by id (upsert)
  static Future<void> upsertItemType(Map<String, dynamic> data) async {
    final db = await database;
    final id = data['id'];
    if (id == null) return;
    final existing = await db.query(
      _itemTypesTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (existing.isEmpty) {
      await db.insert(_itemTypesTable, data);
    } else {
      await db.update(_itemTypesTable, data, where: 'id = ?', whereArgs: [id]);
    }
  }

  // Get item types changed since a timestamp (ISO8601 string)
  static Future<List<Map<String, dynamic>>> getItemTypesChangedSince(
    String lastModified,
  ) async {
    final db = await database;
    return await db.query(
      _itemTypesTable,
      where:
          'id > 0', // Since item_types doesn't have lastModified, we'll get all
    );
  }

  // Bulk upsert item types
  static Future<void> upsertItemTypes(
    List<Map<String, dynamic>> itemTypes,
  ) async {
    for (final itemType in itemTypes) {
      await upsertItemType(itemType);
    }
  }
}
