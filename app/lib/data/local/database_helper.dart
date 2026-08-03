import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../mock/mock_data.dart';

class DatabaseHelper {
  DatabaseHelper._init();
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('legacy_notebook.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    if (kIsWeb) {
      throw UnsupportedError('Web database is not supported yet');
    }

    final dbPath = await getApplicationDocumentsDirectory();
    final path = join(dbPath.path, filePath);

    return await openDatabase(
      path,
      version: 9,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future _createDB(Database db, int version) async {
    // 1. Weekdays Table
    await db.execute('''
      CREATE TABLE weekdays (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        sort_order INTEGER NOT NULL
      )
    ''');

    // 2. Config Table
    await db.execute('''
      CREATE TABLE config (
        id TEXT PRIMARY KEY,
        data TEXT NOT NULL
      )
    ''');

    // 4. Products Table
    await db.execute('''
      CREATE TABLE products (
        id TEXT PRIMARY KEY,
        sku TEXT NOT NULL UNIQUE,
        name TEXT NOT NULL,
        brand TEXT NOT NULL,
        category_id TEXT NOT NULL,
        cost_price INTEGER NOT NULL DEFAULT 0,
        selling_price INTEGER NOT NULL DEFAULT 0,
        mrp INTEGER NOT NULL DEFAULT 0,
        minimum_stock INTEGER NOT NULL DEFAULT 5,
        image_url TEXT,
        description TEXT
      )
    ''');

    // 5. Customers Table
    await db.execute('''
      CREATE TABLE customers (
        id TEXT PRIMARY KEY,
        customer_code TEXT NOT NULL UNIQUE,
        name TEXT NOT NULL,
        phone TEXT NOT NULL,
        alternate_phone TEXT,
        address TEXT NOT NULL,
        landmark TEXT,
        profile_url TEXT,
        location_url TEXT,
        latitude REAL,
        longitude REAL,
        weekday_id TEXT NOT NULL,
        place_id TEXT NOT NULL,
        area_id TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'ACTIVE',
        dob TEXT,
        occupation TEXT,
        notes TEXT,
        created_by TEXT NOT NULL,
        nominees TEXT NOT NULL DEFAULT '[]',
        id_proofs TEXT NOT NULL DEFAULT '[]',
        FOREIGN KEY (weekday_id) REFERENCES weekdays (id)
      )
    ''');

    // 8. Collections Table
    await db.execute('''
      CREATE TABLE collections (
        id TEXT PRIMARY KEY,
        customer_id TEXT NOT NULL,
        visit_datetime TEXT NOT NULL,
        status TEXT NOT NULL, -- PAYMENT, PARTIAL_PAYMENT, CARRY_FORWARD
        amount REAL NOT NULL DEFAULT 0.0,
        reason TEXT,
        collected_by TEXT NOT NULL,
        FOREIGN KEY (customer_id) REFERENCES customers (id) ON DELETE CASCADE
      )
    ''');

    // 9. Sales Table
    await db.execute('''
      CREATE TABLE sales (
        id TEXT PRIMARY KEY,
        customer_id TEXT NOT NULL,
        sale_datetime TEXT NOT NULL,
        sale_type TEXT NOT NULL, -- READY, CREDIT
        total_amount INTEGER NOT NULL DEFAULT 0,
        advance_amount INTEGER NOT NULL DEFAULT 0,
        financed_amount INTEGER NOT NULL DEFAULT 0,
        sold_by TEXT NOT NULL,
        remarks TEXT,
        FOREIGN KEY (customer_id) REFERENCES customers (id) ON DELETE CASCADE
      )
    ''');

    // 10. Sale Items Table
    await db.execute('''
      CREATE TABLE sale_items (
        id TEXT PRIMARY KEY,
        sale_id TEXT NOT NULL,
        product_id TEXT NOT NULL,
        quantity INTEGER NOT NULL DEFAULT 1,
        unit_price INTEGER NOT NULL DEFAULT 0,
        total_price INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (sale_id) REFERENCES sales (id) ON DELETE CASCADE,
        FOREIGN KEY (product_id) REFERENCES products (id)
      )
    ''');

    // 11. Inventory Transactions Table
    await db.execute('''
      CREATE TABLE inventory_transactions (
        id TEXT PRIMARY KEY,
        product_id TEXT NOT NULL,
        transaction_type TEXT NOT NULL, -- PURCHASE, SALE, ADJUSTMENT
        quantity INTEGER NOT NULL,
        reference_id TEXT,
        remarks TEXT,
        created_by TEXT NOT NULL,
        FOREIGN KEY (product_id) REFERENCES products (id)
      )
    ''');

    // 12. Create Database Indexes for Query Optimization
    await db.execute('CREATE INDEX idx_customers_area ON customers(area_id)');
    await db.execute('CREATE INDEX idx_collections_customer ON collections(customer_id)');
    await db.execute('CREATE INDEX idx_sales_customer ON sales(customer_id)');
    await db.execute('CREATE INDEX idx_inventory_product ON inventory_transactions(product_id)');

    // 13. Create Database Views
    await db.execute('''
      CREATE VIEW customer_outstanding_view AS
      SELECT 
        c.id AS customer_id,
        COALESCE((SELECT SUM(s.financed_amount) FROM sales s WHERE s.customer_id = c.id), 0) -
        COALESCE((SELECT SUM(col.amount) FROM collections col WHERE col.customer_id = c.id AND col.status IN ('PAYMENT', 'PARTIAL_PAYMENT')), 0) AS outstanding
      FROM customers c;
    ''');

    await db.execute('''
      CREATE VIEW places AS
      SELECT 
        json_extract(value, '\$.id') AS id,
        json_extract(value, '\$.weekday_id') AS weekday_id,
        json_extract(value, '\$.name') AS name
      FROM config, json_each(config.data)
      WHERE config.id = 'places';
    ''');

    await db.execute('''
      CREATE VIEW areas AS
      SELECT 
        json_extract(value, '\$.id') AS id,
        json_extract(value, '\$.place_id') AS place_id,
        json_extract(value, '\$.name') AS name
      FROM config, json_each(config.data)
      WHERE config.id = 'areas';
    ''');

    await db.execute('''
      CREATE VIEW product_stock_view AS
      SELECT 
        p.id AS product_id,
        p.sku,
        p.name,
        p.brand,
        p.category_id,
        p.cost_price,
        p.selling_price,
        p.mrp,
        p.minimum_stock,
        p.image_url,
        p.description,
        COALESCE(SUM(
          CASE 
            WHEN it.transaction_type = 'PURCHASE' THEN it.quantity
            WHEN it.transaction_type = 'SALE' THEN -it.quantity
            WHEN it.transaction_type = 'ADJUSTMENT' THEN it.quantity
            ELSE 0 
          END
        ), 0) AS current_stock
      FROM products p
      LEFT JOIN inventory_transactions it ON it.product_id = p.id
      GROUP BY p.id;
    ''');

    await db.execute('''
      CREATE VIEW route_summary_view AS
      SELECT
        w.id AS weekday_id,
        w.name AS weekday_name,
        p.id AS place_id,
        p.name AS place_name,
        a.id AS area_id,
        a.name AS area_name,
        COUNT(DISTINCT c.id) AS customer_count,
        COALESCE(SUM(v.outstanding), 0) AS outstanding_amount
      FROM weekdays w
      LEFT JOIN places p ON p.weekday_id = w.id
      LEFT JOIN areas a ON a.place_id = p.id
      LEFT JOIN customers c ON c.area_id = a.id
      LEFT JOIN customer_outstanding_view v ON v.customer_id = c.id
      GROUP BY w.id, p.id, a.id;
    ''');

    await db.execute('''
      CREATE VIEW customer_route_view AS
      SELECT
        c.id AS customer_id,
        c.name AS customer_name,
        c.customer_code,
        w.id AS weekday_id,
        w.name AS weekday_name,
        p.id AS place_id,
        p.name AS place_name,
        a.id AS area_id,
        a.name AS area_name,
        COALESCE(v.outstanding, 0) AS outstanding
      FROM customers c
      LEFT JOIN weekdays w ON c.weekday_id = w.id
      LEFT JOIN places p ON c.place_id = p.id
      LEFT JOIN areas a ON c.area_id = a.id
      LEFT JOIN customer_outstanding_view v ON v.customer_id = c.id;
    ''');

    // 14. Seed Initial Data from Mock Data
    await _seedInitialData(db);
  }

  Future<void> _seedInitialData(Database db) async {
    // Seed Weekdays
    for (var w in mockWeekdaysList) {
      await db.insert('weekdays', {
        'id': w.id,
        'name': w.name,
        'sort_order': w.sortOrder,
      });
    }

    // Seed Config (places, areas, categories, brands)
    await db.insert('config', {
      'id': 'places',
      'data': jsonEncode(mockPlacesList.map((p) => p.toJson()).toList()),
    });

    await db.insert('config', {
      'id': 'areas',
      'data': jsonEncode(mockAreasList.map((a) => a.toJson()).toList()),
    });

    await db.insert('config', {
      'id': 'categories',
      'data': jsonEncode(mockCategoriesList.map((c) => c.toJson()).toList()),
    });

    final uniqueBrands = mockProductsList.map((p) => p.brand).toSet().toList();
    uniqueBrands.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    await db.insert('config', {
      'id': 'brands',
      'data': jsonEncode(uniqueBrands),
    });

    await db.insert('config', {
      'id': 'proof_types',
      'data': jsonEncode(['Aadhaar', 'Voter', 'DL', 'PAN', 'Other']),
    });

    // Seed Products & Opening Transactions
    for (var pr in mockProductsList) {
      await db.insert('products', {
        'id': pr.id,
        'sku': pr.sku,
        'name': pr.name,
        'brand': pr.brand,
        'category_id': pr.categoryId,
        'cost_price': pr.costPrice,
        'selling_price': pr.sellingPrice,
        'mrp': pr.mrp,
        'minimum_stock': pr.minimumStock,
        'image_url': pr.imageUrl,
        'description': pr.description,
      });

      if (pr.stock > 0) {
        await db.insert('inventory_transactions', {
          'id': 'tx_init_${pr.id}',
          'product_id': pr.id,
          'transaction_type': 'PURCHASE',
          'quantity': pr.stock,
          'reference_id': 'INIT_STOCK',
          'remarks': 'Seeded opening stock',
          'created_by': 'system',
        });
      }
    }

    // Seed Customers
    for (var c in mockCustomersList) {
      await db.insert('customers', {
        'id': c.id,
        'customer_code': c.customerCode,
        'name': c.name,
        'phone': c.phone,
        'alternate_phone': c.alternatePhone,
        'address': c.address,
        'landmark': c.landmark,
        'profile_url': c.profileUrl,
        'location_url': c.locationUrl,
        'latitude': c.location?.lat,
        'longitude': c.location?.lng,
        'weekday_id': c.weekdayId,
        'place_id': c.placeId,
        'area_id': c.areaId,
        'status': c.status,
        'dob': c.dob,
        'occupation': c.occupation,
        'notes': c.notes,
        'created_by': 'system',
        'nominees': jsonEncode(c.nominees.map((n) => n.toJson()).toList()),
        'id_proofs': jsonEncode(c.idProofs.map((p) => p.toJson()).toList()),
      });
    }

    // Seed Sales & Deduct Inventory Stock
    for (var s in mockSalesList) {
      await db.insert('sales', {
        'id': s.id,
        'customer_id': s.customerId,
        'sale_datetime': s.saleDatetime.toIso8601String(),
        'sale_type': s.saleType,
        'total_amount': s.totalAmount,
        'advance_amount': s.advanceAmount,
        'financed_amount': s.financedAmount,
        'sold_by': s.soldBy,
        'remarks': s.remarks,
      });

      // Match corresponding mock products by price/SKU for correct items
      String matchedProductId = 'pr-1'; // fallback
      if (s.totalAmount == 16500) {
        matchedProductId = 'pr-8'; // LG Refrigerator
      } else if (s.totalAmount == 3200) {
        matchedProductId = 'pr-1'; // Prestige Mixer
      } else if (s.totalAmount == 2800) {
        matchedProductId = 'pr-2'; // Philips Induction
      } else if (s.totalAmount == 28500) {
        matchedProductId = 'pr-7'; // IFB Front Load
      } else if (s.totalAmount == 850) {
        matchedProductId = 'pr-10'; // Usha Dry Iron
      }

      await db.insert('sale_items', {
        'id': 'si_${s.id}',
        'sale_id': s.id,
        'product_id': matchedProductId,
        'quantity': 1,
        'unit_price': s.totalAmount,
        'total_price': s.totalAmount,
      });

      // Deduct inventory
      await db.insert('inventory_transactions', {
        'id': 'tx_sale_${s.id}',
        'product_id': matchedProductId,
        'transaction_type': 'SALE',
        'quantity': 1,
        'reference_id': s.id,
        'remarks': 'Seeded sale deduct',
        'created_by': 'system',
      });
    }

    // Seed Collections
    for (var col in mockCollectionsList) {
      await db.insert('collections', {
        'id': col.id,
        'customer_id': col.customerId,
        'visit_datetime': col.visitDatetime.toIso8601String(),
        'status': col.status,
        'amount': col.amount,
        'reason': col.reason,
        'collected_by': col.collectedBy,
      });
    }
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await _dropAll(db);
    await _createDB(db, newVersion);
  }

  Future _dropAll(Database db) async {
    final tables = [
      'inventory_transactions',
      'sale_items',
      'sales',
      'collections',
      'customers',
      'products',
      'weekdays',
      'config',
    ];
    for (var t in tables) {
      await db.execute('DROP TABLE IF EXISTS $t');
    }
    final views = [
      'customer_outstanding_view',
      'product_stock_view',
      'route_summary_view',
      'customer_route_view',
      'places',
      'areas',
    ];
    for (var v in views) {
      await db.execute('DROP VIEW IF EXISTS $v');
    }
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}
