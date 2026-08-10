import 'dart:async';
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../models/customer.dart';
import '../models/outstanding.dart';
import '../models/activity.dart';
import '../models/location.dart';
import '../models/nominee.dart';
import '../models/id_proof.dart';
import '../models/weekday.dart';
import '../models/place.dart';
import '../models/area.dart';
import '../models/collection.dart';
import '../models/sale.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../local/database_helper.dart';

import '../../core/utils/uuid.dart';
import 'customer_repository.dart';
import 'route_repository.dart';
import 'collection_repository.dart';
import 'sale_repository.dart';
import 'product_repository.dart';
import 'config_repository.dart';

/// A lightweight broadcaster that notifies subscribers of updates on specific tables
/// to mimic real-time reactive streams.
class TableBroadcaster {
  TableBroadcaster._init();
  static final TableBroadcaster instance = TableBroadcaster._init();

  final _controller = StreamController<String>.broadcast();

  Stream<String> get stream => _controller.stream;

  void notify(String tableName) {
    _controller.add(tableName);
  }
}

/// Helper to watch tables and re-run queries reactively
Stream<T> watchQuery<T>({
  required List<String> tables,
  required Future<T> Function() query,
}) {
  final controller = StreamController<T>();

  void runQuery() {
    query().then((val) {
      if (!controller.isClosed) {
        controller.add(val);
      }
    }).catchError((err) {
      if (!controller.isClosed) {
        controller.addError(err);
      }
    });
  }

  // Initial load
  runQuery();

  final subscription = TableBroadcaster.instance.stream.listen((tableName) {
    if (tables.contains(tableName)) {
      runQuery();
    }
  });

  controller.onCancel = () {
    subscription.cancel();
    controller.close();
  };

  return controller.stream;
}

// ─── CustomerRepository ──────────────────────────────────────

class LocalSqliteCustomerRepository implements CustomerRepository {
  static Location? _parseLocation(dynamic lat, dynamic lng, dynamic locationUrl) {
    if (lat != null && lng != null) {
      final parsedLat = (lat is num) ? lat.toDouble() : double.tryParse(lat.toString());
      final parsedLng = (lng is num) ? lng.toDouble() : double.tryParse(lng.toString());
      if (parsedLat != null && parsedLng != null) {
        return Location(lat: parsedLat, lng: parsedLng);
      }
    }
    if (locationUrl is String && locationUrl.isNotEmpty) {
      try {
        final uri = Uri.parse(locationUrl);
        final q = uri.queryParameters['q'];
        if (q != null) {
          final parts = q.split(',');
          if (parts.length >= 2) {
            final parsedLat = double.tryParse(parts[0].trim());
            final parsedLng = double.tryParse(parts[1].trim());
            if (parsedLat != null && parsedLng != null) {
              return Location(lat: parsedLat, lng: parsedLng);
            }
          }
        }
      } catch (_) {}
    }
    return null;
  }

  @override
  Stream<List<Customer>> watchAllCustomers() {
    return watchQuery(
      tables: ['customers'],
      query: getAllCustomers,
    );
  }

  @override
  Future<List<Customer>> getAllCustomers() async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query('customers', orderBy: 'id ASC');
    final List<Customer> results = [];

    for (final map in maps) {
      final List<dynamic> nomineeList = map['nominees'] != null
          ? jsonDecode(map['nominees'] as String) as List<dynamic>
          : [];
      final nominees = nomineeList
          .map((item) => Nominee.fromJson(item as Map<String, dynamic>))
          .toList();

      final List<dynamic> proofList = map['id_proofs'] != null
          ? jsonDecode(map['id_proofs'] as String) as List<dynamic>
          : [];
      final idProofs = proofList
          .map((item) => IdProof.fromJsonCustom(item as Map<String, dynamic>))
          .toList();

      results.add(Customer(
        id: map['id'] as String,
        customerCode: map['customer_code'] as String,
        name: map['name'] as String,
        phone: map['phone'] as String,
        alternatePhone: map['alternate_phone'] as String?,
        address: map['address'] as String,
        landmark: map['landmark'] as String?,
        profileUrl: map['profile_url'] as String?,
        locationUrl: map['location_url'] as String?,
        location: _parseLocation(map['latitude'], map['longitude'], map['location_url']),
        nominees: nominees,
        idProofs: idProofs,
        weekdayId: map['weekday_id'] as String,
        placeId: map['place_id'] as String,
        areaId: map['area_id'] as String,
        status: map['status'] as String,
        dob: map['dob'] as String?,
        occupation: map['occupation'] as String?,
        notes: map['notes'] as String?,
      ));
    }
    return results;
  }

  @override
  Stream<List<Customer>> watchCustomersByArea(String areaId) {
    return watchQuery(
      tables: ['customers'],
      query: () => getCustomersByArea(areaId),
    );
  }

  @override
  Future<List<Customer>> getCustomersByArea(String areaId) async {
    final all = await getAllCustomers();
    return all.where((c) => c.areaId == areaId).toList();
  }

  @override
  Future<Customer?> getCustomerById(String id) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query('customers', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;

    final map = maps.first;
    final List<dynamic> nomineeList = map['nominees'] != null
        ? jsonDecode(map['nominees'] as String) as List<dynamic>
        : [];
    final nominees = nomineeList
        .map((item) => Nominee.fromJson(item as Map<String, dynamic>))
        .toList();

    final List<dynamic> proofList = map['id_proofs'] != null
        ? jsonDecode(map['id_proofs'] as String) as List<dynamic>
        : [];
    final idProofs = proofList
        .map((item) => IdProof.fromJsonCustom(item as Map<String, dynamic>))
        .toList();

    return Customer(
      id: id,
      customerCode: map['customer_code'] as String,
      name: map['name'] as String,
      phone: map['phone'] as String,
      alternatePhone: map['alternate_phone'] as String?,
      address: map['address'] as String,
      landmark: map['landmark'] as String?,
      profileUrl: map['profile_url'] as String?,
      locationUrl: map['location_url'] as String?,
      location: map['latitude'] != null && map['longitude'] != null
          ? Location(lat: map['latitude'] as double, lng: map['longitude'] as double)
          : null,
      nominees: nominees,
      idProofs: idProofs,
      weekdayId: map['weekday_id'] as String,
      placeId: map['place_id'] as String,
      areaId: map['area_id'] as String,
      status: map['status'] as String,
      dob: map['dob'] as String?,
      occupation: map['occupation'] as String?,
      notes: map['notes'] as String?,
    );
  }

  @override
  Stream<Customer?> watchCustomerById(String id) {
    return watchQuery(
      tables: ['customers'],
      query: () => getCustomerById(id),
    );
  }

  @override
  Stream<Outstanding> watchCustomerOutstanding(String customerId, {bool skipInitialFetch = false}) {
    return watchQuery(
      tables: ['sales', 'collections'],
      query: () => getCustomerOutstanding(customerId),
    );
  }

  @override
  Future<Outstanding> getCustomerOutstanding(String customerId) async {
    final db = await DatabaseHelper.instance.database;

    final saleResult = await db.rawQuery(
      'SELECT SUM(financed_amount) AS total FROM sales WHERE customer_id = ?',
      [customerId],
    );
    final collectionResult = await db.rawQuery(
      'SELECT SUM(amount) AS total FROM collections WHERE customer_id = ? AND status IN (\'PAYMENT\', \'PARTIAL_PAYMENT\')',
      [customerId],
    );

    final lendSaleResult = await db.rawQuery(
      'SELECT SUM(financed_amount) AS total FROM sales WHERE customer_id = ? AND (sale_type = \'LEND\' OR remarks LIKE \'LEND_DETAILS:%\')',
      [customerId],
    );
    final saleSaleResult = await db.rawQuery(
      'SELECT SUM(financed_amount) AS total FROM sales WHERE customer_id = ? AND sale_type != \'LEND\' AND (remarks IS NULL OR remarks NOT LIKE \'LEND_DETAILS:%\')',
      [customerId],
    );

    final lendCollectionResult = await db.rawQuery(
      'SELECT SUM(amount) AS total FROM collections WHERE customer_id = ? AND status IN (\'PAYMENT\', \'PARTIAL_PAYMENT\') AND reason LIKE \'COLLECTION_TARGET:target=LEND%\'',
      [customerId],
    );
    final saleCollectionResult = await db.rawQuery(
      'SELECT SUM(amount) AS total FROM collections WHERE customer_id = ? AND status IN (\'PAYMENT\', \'PARTIAL_PAYMENT\') AND (reason IS NULL OR reason NOT LIKE \'COLLECTION_TARGET:target=LEND%\')',
      [customerId],
    );

    final totalFinanced = Sqflite.firstIntValue(saleResult) ?? 0;
    final totalCollected = Sqflite.firstIntValue(collectionResult) ?? 0;

    final totalLendFinanced = Sqflite.firstIntValue(lendSaleResult) ?? 0;
    final totalSaleFinanced = Sqflite.firstIntValue(saleSaleResult) ?? 0;

    final totalLendCollected = Sqflite.firstIntValue(lendCollectionResult) ?? 0;
    final totalSaleCollected = Sqflite.firstIntValue(saleCollectionResult) ?? 0;

    return Outstanding(
      customerId: customerId,
      totalFinanced: totalFinanced,
      totalCollected: totalCollected,
      outstandingAmount: totalFinanced - totalCollected,
      totalLendFinanced: totalLendFinanced,
      totalLendCollected: totalLendCollected,
      totalSaleFinanced: totalSaleFinanced,
      totalSaleCollected: totalSaleCollected,
    );
  }

  @override
  Stream<List<Activity>> watchCustomerTimeline(String customerId, {bool skipInitialFetch = false}) {
    return watchQuery(
      tables: ['sales', 'collections', 'sale_items', 'products'],
      query: () => getCustomerTimeline(customerId),
    );
  }

  @override
  Future<List<Activity>> getCustomerTimeline(String customerId) async {
    final db = await DatabaseHelper.instance.database;
    final List<Activity> activities = [];

    // Query collections
    final collectionMaps = await db.query(
      'collections',
      where: 'customer_id = ?',
      whereArgs: [customerId],
    );

    for (final col in collectionMaps) {
      final id = col['id'] as String;
      final at = DateTime.parse(col['visit_datetime'] as String);
      final status = col['status'] as String;
      final amount = col['amount'] as int;
      final reason = col['reason'] as String?;
      final collectedBy = col['collected_by'] as String;

      if (status == 'PAYMENT') {
        activities.add(Activity.payment(
          id: id,
          at: at,
          amount: amount,
          note: reason,
          collectorName: collectedBy,
        ));
      } else if (status == 'PARTIAL_PAYMENT') {
        activities.add(Activity.partialPayment(
          id: id,
          at: at,
          amount: amount,
          note: reason ?? '',
          collectorName: collectedBy,
        ));
      } else if (status == 'CARRY_FORWARD') {
        activities.add(Activity.carryForward(
          id: id,
          at: at,
          note: reason ?? '',
          collectorName: collectedBy,
        ));
      }
    }

    // Query sales
    final saleMaps = await db.query(
      'sales',
      where: 'customer_id = ?',
      whereArgs: [customerId],
    );

    for (final sale in saleMaps) {
      final id = sale['id'] as String;
      final at = DateTime.parse(sale['sale_datetime'] as String);
      final remarks = sale['remarks'] as String?;
      final dbSaleType = sale['sale_type'] as String;
      final isLend = remarks != null && remarks.startsWith('LEND_DETAILS:');
      final saleType = isLend ? 'LEND' : dbSaleType;
      final total = sale['total_amount'] as int;
      final advance = sale['advance_amount'] as int;
      final creditAdded = sale['financed_amount'] as int;
      final soldBy = sale['sold_by'] as String;

      // Query sale items left join products to get the product name
      final itemMaps = await db.rawQuery('''
        SELECT si.quantity, si.unit_price, p.name AS product_name
        FROM sale_items si
        JOIN products p ON p.id = si.product_id
        WHERE si.sale_id = ?
      ''', [id]);

      final items = itemMaps.map((it) => SaleItemDetail(
        productName: it['product_name'] as String,
        quantity: it['quantity'] as int,
        unitPrice: it['unit_price'] as int,
      )).toList();

      activities.add(Activity.sale(
        id: id,
        at: at,
        items: items,
        total: total,
        advance: advance,
        creditAdded: creditAdded,
        saleType: saleType,
        collectorName: soldBy,
        note: remarks,
      ));
    }

    // Unified customer timeline sorted by at DESC
    activities.sort((a, b) => b.at.compareTo(a.at));
    return activities;
  }

  @override
  Future<void> updateCustomerProfile(String id, {String? phone, String? profileUrl, String? locationUrl}) async {
    final db = await DatabaseHelper.instance.database;
    final Map<String, dynamic> updates = {};
    if (phone != null) updates['phone'] = phone;
    if (profileUrl != null) updates['profile_url'] = profileUrl;
    if (locationUrl != null) updates['location_url'] = locationUrl;

    if (updates.isNotEmpty) {
      await db.update('customers', updates, where: 'id = ?', whereArgs: [id]);
      TableBroadcaster.instance.notify('customers');
    }
  }

  @override
  Future<void> addNominee(String customerId, String name, String phone, String relation) async {
    final customer = await getCustomerById(customerId);
    if (customer != null) {
      final newNominee = Nominee(
        id: 'nom_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        phone: phone,
        relation: relation,
      );
      final updated = customer.copyWith(
        nominees: [...customer.nominees, newNominee],
      );
      await updateCustomer(updated);
    }
  }

  @override
  Future<void> addProofImage(String customerId, String proofType, String imageUrl) async {
    final customer = await getCustomerById(customerId);
    if (customer != null) {
      final newProof = IdProof(
        id: 'prf_${DateTime.now().millisecondsSinceEpoch}',
        type: proofType,
        proofUrl: imageUrl,
        document: IdProofDocument(
          filename: 'proof',
          mimeType: 'image/jpeg',
          sizeBytes: 0,
          localUri: imageUrl,
        ),
      );
      final updated = customer.copyWith(
        idProofs: [...customer.idProofs, newProof],
      );
      await updateCustomer(updated);
    }
  }

  @override
  Future<Customer> addCustomer({
    required String name,
    required String phone,
    required String address,
    required String weekdayId,
    required String placeId,
    required String areaId,
    String? alternatePhone,
    String? landmark,
    String? notes,
    String? dob,
    String? occupation,
    int openingBalance = 0,
    List<Nominee>? nominees,
    List<IdProof>? idProofs,
    Location? location,
    String? profileUrl,
  }) async {
    final db = await DatabaseHelper.instance.database;
    final idResult = await db.rawQuery("SELECT id FROM customers WHERE id LIKE 'CU-%'");
    int maxId = 0;
    for (final row in idResult) {
      final rawId = row['id']?.toString() ?? '';
      final numPart = rawId.replaceAll('CU-', '');
      final parsed = int.tryParse(numPart);
      if (parsed != null && parsed > maxId) {
        maxId = parsed;
      }
    }
    final nextIdNum = maxId + 1;
    final customerId = 'CU-${nextIdNum.toString().padLeft(3, '0')}';

    final wCode = weekdayId.replaceAll('w-', 'W').toUpperCase();
    final pCode = placeId.replaceAll('p-', 'P').toUpperCase();
    final aCode = areaId.replaceAll('a-', 'A').toUpperCase();
    final paddedId = nextIdNum.toString().padLeft(3, '0');
    final customerCode = '$wCode-$pCode-$aCode-$paddedId';

    final customerMap = {
      'id': customerId,
      'customer_code': customerCode,
      'name': name,
      'phone': phone,
      'alternate_phone': alternatePhone,
      'address': address,
      'landmark': landmark,
      'profile_url': profileUrl,
      'location_url': location != null ? 'https://maps.google.com/?q=${location.lat},${location.lng}' : null,
      'latitude': location?.lat,
      'longitude': location?.lng,
      'weekday_id': weekdayId,
      'place_id': placeId,
      'area_id': areaId,
      'status': 'ACTIVE',
      'dob': dob,
      'occupation': occupation,
      'notes': notes,
      'created_by': 'collector_local',
      'nominees': jsonEncode((nominees ?? []).map((n) => n.toJson()).toList()),
      'id_proofs': jsonEncode((idProofs ?? []).map((p) => p.toJson()).toList()),
    };

    await db.transaction((txn) async {
      await txn.insert('customers', customerMap);

      // Handle opening balance as initial credit sale
      if (openingBalance > 0) {
        final saleId = 'sale_ob_$customerId';
        await txn.insert('sales', {
          'id': saleId,
          'customer_id': customerId,
          'sale_datetime': DateTime.now().toIso8601String(),
          'sale_type': 'CREDIT',
          'total_amount': openingBalance,
          'advance_amount': 0,
          'financed_amount': openingBalance,
          'sold_by': 'system',
          'remarks': 'Opening balance',
        });
      }
    });

    TableBroadcaster.instance.notify('customers');
    TableBroadcaster.instance.notify('sales');

    final created = await getCustomerById(customerId);
    return created!;
  }

  @override
  Future<void> updateCustomer(Customer customer) async {
    final db = await DatabaseHelper.instance.database;
    await db.update('customers', {
      'name': customer.name,
      'phone': customer.phone,
      'alternate_phone': customer.alternatePhone,
      'address': customer.address,
      'landmark': customer.landmark,
      'profile_url': customer.profileUrl,
      'location_url': customer.locationUrl ?? (customer.location != null ? 'https://maps.google.com/?q=${customer.location!.lat},${customer.location!.lng}' : null),
      'latitude': customer.location?.lat,
      'longitude': customer.location?.lng,
      'weekday_id': customer.weekdayId,
      'place_id': customer.placeId,
      'area_id': customer.areaId,
      'status': customer.status,
      'dob': customer.dob,
      'occupation': customer.occupation,
      'notes': customer.notes,
      'nominees': jsonEncode(customer.nominees.map((n) => n.toJson()).toList()),
      'id_proofs': jsonEncode(customer.idProofs.map((p) => p.toJson()).toList()),
    }, where: 'id = ?', whereArgs: [customer.id]);

    TableBroadcaster.instance.notify('customers');
  }

  @override
  Future<void> undoCustomer(String customerId) async {
    final db = await DatabaseHelper.instance.database;
    await db.transaction((txn) async {
      await txn.delete('customers', where: 'id = ?', whereArgs: [customerId]);
      await txn.delete('sales', where: 'customer_id = ? AND remarks = ?', whereArgs: [customerId, 'Opening balance']);
    });
    TableBroadcaster.instance.notify('customers');
    TableBroadcaster.instance.notify('sales');
  }
}

// ─── RouteRepository ─────────────────────────────────────────

class LocalSqliteRouteRepository implements RouteRepository {
  @override
  Future<List<Weekday>> getWeekdays() async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query('weekdays', orderBy: 'sort_order ASC');
    return maps.map((m) => Weekday(
      id: m['id'] as String,
      name: m['name'] as String,
      sortOrder: m['sort_order'] as int,
    )).toList();
  }

  @override
  Stream<List<Weekday>> watchWeekdays() {
    return watchQuery(tables: ['weekdays'], query: getWeekdays);
  }

  @override
  Future<List<Place>> getPlacesByWeekday(String weekdayId) async {
    final places = await LocalSqliteConfigRepository().getPlaces();
    return places.where((p) => p.weekdayId == weekdayId).toList();
  }

  @override
  Stream<List<Place>> watchPlacesByWeekday(String weekdayId) {
    return watchQuery(tables: ['config'], query: () => getPlacesByWeekday(weekdayId));
  }

  @override
  Future<List<Area>> getAreasByPlace(String placeId) async {
    final areas = await LocalSqliteConfigRepository().getAreas();
    return areas.where((a) => a.placeId == placeId).toList();
  }

  @override
  Stream<List<Area>> watchAreasByPlace(String placeId) {
    return watchQuery(tables: ['config'], query: () => getAreasByPlace(placeId));
  }

  @override
  Future<int> getCustomerCountForWeekday(String weekdayId) async {
    final db = await DatabaseHelper.instance.database;
    final res = await db.rawQuery('SELECT COUNT(*) FROM customers WHERE weekday_id = ?', [weekdayId]);
    return Sqflite.firstIntValue(res) ?? 0;
  }

  @override
  Future<int> getCustomerCountForPlace(String placeId) async {
    final db = await DatabaseHelper.instance.database;
    final res = await db.rawQuery('SELECT COUNT(*) FROM customers WHERE place_id = ?', [placeId]);
    return Sqflite.firstIntValue(res) ?? 0;
  }

  @override
  Future<int> getCustomerCountForArea(String areaId) async {
    final db = await DatabaseHelper.instance.database;
    final res = await db.rawQuery('SELECT COUNT(*) FROM customers WHERE area_id = ?', [areaId]);
    return Sqflite.firstIntValue(res) ?? 0;
  }

  @override
  Future<int> getExpectedCollectionForWeekday(String weekdayId) async {
    final db = await DatabaseHelper.instance.database;
    final res = await db.rawQuery('''
      SELECT SUM(v.outstanding) AS total 
      FROM customer_outstanding_view v
      JOIN customers c ON c.id = v.customer_id
      WHERE c.weekday_id = ?
    ''', [weekdayId]);
    return Sqflite.firstIntValue(res) ?? 0;
  }

  @override
  Future<int> getExpectedCollectionForPlace(String placeId) async {
    final db = await DatabaseHelper.instance.database;
    final res = await db.rawQuery('''
      SELECT SUM(v.outstanding) AS total 
      FROM customer_outstanding_view v
      JOIN customers c ON c.id = v.customer_id
      WHERE c.place_id = ?
    ''', [placeId]);
    return Sqflite.firstIntValue(res) ?? 0;
  }

  @override
  Future<int> getExpectedCollectionForArea(String areaId) async {
    final db = await DatabaseHelper.instance.database;
    final res = await db.rawQuery('''
      SELECT SUM(v.outstanding) AS total 
      FROM customer_outstanding_view v
      JOIN customers c ON c.id = v.customer_id
      WHERE c.area_id = ?
    ''', [areaId]);
    return Sqflite.firstIntValue(res) ?? 0;
  }

  @override
  Future<int> getActualCollectionForWeekday(String weekdayId) async {
    final db = await DatabaseHelper.instance.database;
    final res = await db.rawQuery('''
      SELECT SUM(col.amount) AS total 
      FROM collections col
      JOIN customers c ON c.id = col.customer_id
      WHERE c.weekday_id = ? AND col.status IN ('PAYMENT', 'PARTIAL_PAYMENT')
    ''', [weekdayId]);
    return Sqflite.firstIntValue(res) ?? 0;
  }

  @override
  Future<int> getActualCollectionForPlace(String placeId) async {
    final db = await DatabaseHelper.instance.database;
    final res = await db.rawQuery('''
      SELECT SUM(col.amount) AS total 
      FROM collections col
      JOIN customers c ON c.id = col.customer_id
      WHERE c.place_id = ? AND col.status IN ('PAYMENT', 'PARTIAL_PAYMENT')
    ''', [placeId]);
    return Sqflite.firstIntValue(res) ?? 0;
  }

  @override
  Future<int> getActualCollectionForArea(String areaId) async {
    final db = await DatabaseHelper.instance.database;
    final res = await db.rawQuery('''
      SELECT SUM(col.amount) AS total 
      FROM collections col
      JOIN customers c ON c.id = col.customer_id
      WHERE c.area_id = ? AND col.status IN ('PAYMENT', 'PARTIAL_PAYMENT')
    ''', [areaId]);
    return Sqflite.firstIntValue(res) ?? 0;
  }

  @override
  Future<Place> addPlace({
    required String weekdayId,
    required String name,
  }) async {
    final configRepo = LocalSqliteConfigRepository();
    final places = await configRepo.getPlaces();
    
    final idPattern = RegExp(r'^p-(\d+)$');
    int maxId = 0;
    for (final p in places) {
      final match = idPattern.firstMatch(p.id);
      if (match != null) {
        final val = int.tryParse(match.group(1) ?? '0') ?? 0;
        if (val > maxId) {
          maxId = val;
        }
      }
    }
    final placeId = 'p-${maxId + 1}';
    
    final place = Place(id: placeId, weekdayId: weekdayId, name: name);
    places.add(place);
    await configRepo.savePlaces(places);
    return place;
  }

  @override
  Future<Area> addArea({
    required String placeId,
    required String name,
  }) async {
    final configRepo = LocalSqliteConfigRepository();
    final areas = await configRepo.getAreas();
    
    final idPattern = RegExp(r'^a-(\d+)$');
    int maxId = 0;
    for (final a in areas) {
      final match = idPattern.firstMatch(a.id);
      if (match != null) {
        final val = int.tryParse(match.group(1) ?? '0') ?? 0;
        if (val > maxId) {
          maxId = val;
        }
      }
    }
    final areaId = 'a-${maxId + 1}';
    
    final area = Area(id: areaId, placeId: placeId, name: name);
    areas.add(area);
    await configRepo.saveAreas(areas);
    return area;
  }
}

// ─── CollectionRepository ────────────────────────────────────

class LocalSqliteCollectionRepository implements CollectionRepository {
  @override
  Stream<List<Collection>> watchAllCollections() {
    return watchQuery(tables: ['collections'], query: _getAllCollections);
  }

  @override
  Future<List<Collection>> getAllCollections() => _getAllCollections();

  Future<List<Collection>> _getAllCollections() async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query('collections', orderBy: 'visit_datetime DESC');
    return maps.map((m) => Collection(
      id: m['id'] as String,
      customerId: m['customer_id'] as String,
      visitDatetime: DateTime.parse(m['visit_datetime'] as String),
      status: m['status'] as String,
      amount: (m['amount'] as num).toDouble(),
      reason: m['reason'] as String?,
      collectedBy: m['collected_by'] as String,
    )).toList();
  }

  @override
  Stream<List<Collection>> watchCollectionsForCustomerToday(String customerId) {
    return watchQuery(
      tables: ['collections'],
      query: () => getCollectionsForCustomerToday(customerId),
    );
  }

  @override
  Future<List<Collection>> getCollectionsForCustomerToday(String customerId) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.rawQuery('''
      SELECT * FROM collections 
      WHERE customer_id = ? 
      AND strftime('%Y-%m-%d', visit_datetime) = strftime('%Y-%m-%d', 'now', 'localtime')
      ORDER BY visit_datetime DESC
    ''', [customerId]);

    return maps.map((m) => Collection(
      id: m['id'] as String,
      customerId: m['customer_id'] as String,
      visitDatetime: DateTime.parse(m['visit_datetime'] as String),
      status: m['status'] as String,
      amount: (m['amount'] as num).toDouble(),
      reason: m['reason'] as String?,
      collectedBy: m['collected_by'] as String,
    )).toList();
  }

  @override
  Future<void> saveCollection({
    required String customerId,
    required String status,
    required double amount,
    String? reason,
    required String collectedBy,
    DateTime? customDate,
  }) async {
    final db = await DatabaseHelper.instance.database;
    final collectionId = UuidUtils.generate();

    // Business Rule 9: Carry forward never changes outstanding. Force amount to 0.
    final adjustedAmount = (status == 'CARRY_FORWARD') ? 0.0 : amount;

    await db.insert('collections', {
      'id': collectionId,
      'customer_id': customerId,
      'visit_datetime': (customDate ?? DateTime.now()).toIso8601String(),
      'status': status,
      'amount': adjustedAmount,
      'reason': reason,
      'collected_by': collectedBy,
    });

    TableBroadcaster.instance.notify('collections');
  }

  @override
  Future<void> undoCollection(String collectionId) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('collections', where: 'id = ?', whereArgs: [collectionId]);
    TableBroadcaster.instance.notify('collections');
  }
}

// ─── SaleRepository ──────────────────────────────────────────

class LocalSqliteSaleRepository implements SaleRepository {
  @override
  Stream<List<Sale>> watchAllSales() {
    return watchQuery(tables: ['sales'], query: _getAllSales);
  }

  @override
  Future<List<Sale>> getAllSales() => _getAllSales();

  Future<List<Sale>> _getAllSales() async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query('sales', orderBy: 'sale_datetime DESC');
    return maps.map((m) {
      final remarks = m['remarks'] as String?;
      final dbSaleType = m['sale_type'] as String;
      final isLend = remarks != null && remarks.startsWith('LEND_DETAILS:');
      return Sale(
        id: m['id'] as String,
        customerId: m['customer_id'] as String,
        saleDatetime: DateTime.parse(m['sale_datetime'] as String),
        saleType: isLend ? 'LEND' : dbSaleType,
        totalAmount: m['total_amount'] as int,
        advanceAmount: m['advance_amount'] as int,
        financedAmount: m['financed_amount'] as int,
        soldBy: m['sold_by'] as String,
        remarks: remarks,
      );
    }).toList();
  }

  @override
  Future<void> saveSale({
    required String customerId,
    required List<Map<String, dynamic>> items,
    required int advanceAmount,
    required String soldBy,
    int discount = 0,
    int creditCharge = 0,
    String? remarks,
    DateTime? customDate,
    int? lendAmount,
  }) async {
    final db = await DatabaseHelper.instance.database;
    final saleId = UuidUtils.generate();

    // Calculate totals
    int totalAmount = 0;
    if (lendAmount != null) {
      totalAmount = lendAmount;
    } else {
      for (var item in items) {
        final qty = item['quantity'] as int;
        final unitPrice = item['unitPrice'] as int;
        totalAmount += qty * unitPrice;
      }
    }
    totalAmount -= discount;
    totalAmount += creditCharge;

    // Business Rule 5: Enforce advance <= totalAmount
    if (advanceAmount > totalAmount) {
      throw ArgumentError('Advance amount (₹${advanceAmount / 100}) cannot exceed sale total (₹${totalAmount / 100})');
    }

    final financedAmount = totalAmount - advanceAmount;

    // Business Rule 3: Derived Sale Type
    final saleType = lendAmount != null ? 'LEND' : ((financedAmount == 0) ? 'READY' : 'CREDIT');

    await db.transaction((txn) async {
      // Save sale
      await txn.insert('sales', {
        'id': saleId,
        'customer_id': customerId,
        'sale_datetime': (customDate ?? DateTime.now()).toIso8601String(),
        'sale_type': saleType,
        'total_amount': totalAmount,
        'advance_amount': advanceAmount,
        'financed_amount': financedAmount,
        'sold_by': soldBy,
        'remarks': remarks,
      });

      // Save sale items and log inventory transactions
      for (var item in items) {
        final productId = item['productId'] as String;
        final qty = item['quantity'] as int;
        final unitPrice = item['unitPrice'] as int;
        final itemId = UuidUtils.generate();

        await txn.insert('sale_items', {
          'id': itemId,
          'sale_id': saleId,
          'product_id': productId,
          'quantity': qty,
          'unit_price': unitPrice,
          'total_price': qty * unitPrice,
        });

        // Rule 11: Transaction-driven inventory deduct
        await txn.insert('inventory_transactions', {
          'id': UuidUtils.generate(),
          'product_id': productId,
          'transaction_type': 'SALE',
          'quantity': qty,
          'reference_id': saleId,
          'remarks': 'Sale to customer',
          'created_by': soldBy,
        });
      }
    });

    TableBroadcaster.instance.notify('sales');
    TableBroadcaster.instance.notify('inventory_transactions');
  }

  @override
  Future<void> undoSale(String saleId) async {
    final db = await DatabaseHelper.instance.database;
    await db.transaction((txn) async {
      await txn.delete('sales', where: 'id = ?', whereArgs: [saleId]);
      await txn.delete('inventory_transactions', where: 'reference_id = ?', whereArgs: [saleId]);
    });
    TableBroadcaster.instance.notify('sales');
    TableBroadcaster.instance.notify('inventory_transactions');
  }
}

// ─── ProductRepository ───────────────────────────────────────

class LocalSqliteProductRepository implements ProductRepository {
  @override
  Future<List<Product>> getProducts() async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.rawQuery('SELECT * FROM product_stock_view');

    return maps.map((m) => Product(
      id: m['product_id'] as String,
      sku: m['sku'] as String,
      name: m['name'] as String,
      brand: m['brand'] as String,
      categoryId: m['category_id'] as String,
      minimumStock: m['minimum_stock'] as int,
      stock: (m['current_stock'] as num).toInt(),
      costPrice: m['cost_price'] as int,
      sellingPrice: m['selling_price'] as int,
      mrp: m['mrp'] as int,
      imageUrl: m['image_url'] as String?,
      description: m['description'] as String?,
    )).toList();
  }

  @override
  Stream<List<Product>> watchProducts() {
    return watchQuery(tables: ['products', 'inventory_transactions'], query: getProducts);
  }

  @override
  Future<Product?> getProductById(String id) async {
    final all = await getProducts();
    final matches = all.where((p) => p.id == id);
    return matches.isEmpty ? null : matches.first;
  }

  @override
  Future<Product> addProduct({
    required String name,
    required String brand,
    required String sku,
    required int costPrice,
    required int sellingPrice,
    required int mrp,
    required int stock,
    required String categoryId,
    required int minimumStock,
    String? description,
    String? imageUrl,
  }) async {
    final db = await DatabaseHelper.instance.database;
    final productId = UuidUtils.generate();

    await db.transaction((txn) async {
      // 1. Insert product
      await txn.insert('products', {
        'id': productId,
        'sku': sku,
        'name': name,
        'brand': brand,
        'category_id': categoryId,
        'cost_price': costPrice,
        'selling_price': sellingPrice,
        'mrp': mrp,
        'minimum_stock': minimumStock,
        'image_url': imageUrl,
        'description': description,
      });

      // 2. Insert inventory purchase transaction for opening stock
      if (stock > 0) {
        await txn.insert('inventory_transactions', {
          'id': UuidUtils.generate(),
          'product_id': productId,
          'transaction_type': 'PURCHASE',
          'quantity': stock,
          'reference_id': 'INIT_PURCHASE',
          'remarks': 'Initial product add stock',
          'created_by': 'collector_local',
        });
      }
    });

    TableBroadcaster.instance.notify('products');
    TableBroadcaster.instance.notify('inventory_transactions');

    final created = await getProductById(productId);
    return created!;
  }

  @override
  Future<void> updateProduct(Product product) async {
    final db = await DatabaseHelper.instance.database;
    await db.update('products', {
      'sku': product.sku,
      'name': product.name,
      'brand': product.brand,
      'category_id': product.categoryId,
      'cost_price': product.costPrice,
      'selling_price': product.sellingPrice,
      'mrp': product.mrp,
      'minimum_stock': product.minimumStock,
      'image_url': product.imageUrl,
      'description': product.description,
    }, where: 'id = ?', whereArgs: [product.id]);

    TableBroadcaster.instance.notify('products');
  }
}

class LocalSqliteConfigRepository implements ConfigRepository {
  Future<Database> _getDb() => DatabaseHelper.instance.database;

  Future<String> _readData(String id) async {
    final db = await _getDb();
    final res = await db.query('config', where: 'id = ?', whereArgs: [id]);
    if (res.isEmpty) return '[]';
    return res.first['data'] as String;
  }

  Future<void> _writeData(String id, String data) async {
    final db = await _getDb();
    await db.insert(
      'config',
      {'id': id, 'data': data},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    TableBroadcaster.instance.notify('config');
  }

  @override
  Future<List<Place>> getPlaces() async {
    final raw = await _readData('places');
    final List decoded = jsonDecode(raw);
    return decoded.map((item) {
      final map = Map<String, dynamic>.from(item as Map);
      if (map.containsKey('weekday_id')) {
        map['weekdayId'] = map['weekday_id'];
      }
      return Place.fromJson(map);
    }).toList();
  }

  @override
  Stream<List<Place>> watchPlaces() {
    return watchQuery(
      tables: ['config'],
      query: getPlaces,
    );
  }

  @override
  Future<void> savePlaces(List<Place> places) async {
    final raw = jsonEncode(places.map((p) {
      final map = p.toJson();
      map['weekday_id'] = p.weekdayId;
      return map;
    }).toList());
    await _writeData('places', raw);
  }

  @override
  Future<List<Area>> getAreas() async {
    final raw = await _readData('areas');
    final List decoded = jsonDecode(raw);
    return decoded.map((item) {
      final map = Map<String, dynamic>.from(item as Map);
      if (map.containsKey('place_id')) {
        map['placeId'] = map['place_id'];
      }
      return Area.fromJson(map);
    }).toList();
  }

  @override
  Stream<List<Area>> watchAreas() {
    return watchQuery(
      tables: ['config'],
      query: getAreas,
    );
  }

  @override
  Future<void> saveAreas(List<Area> areas) async {
    final raw = jsonEncode(areas.map((a) {
      final map = a.toJson();
      map['place_id'] = a.placeId;
      return map;
    }).toList());
    await _writeData('areas', raw);
  }

  @override
  Future<List<Category>> getCategories() async {
    final raw = await _readData('categories');
    final List decoded = jsonDecode(raw);
    return decoded.map((item) => Category.fromJson(item as Map<String, dynamic>)).toList();
  }

  @override
  Stream<List<Category>> watchCategories() {
    return watchQuery(
      tables: ['config'],
      query: getCategories,
    );
  }

  @override
  Future<void> saveCategories(List<Category> categories) async {
    final raw = jsonEncode(categories.map((c) => c.toJson()).toList());
    await _writeData('categories', raw);
  }

  @override
  Future<List<String>> getBrands() async {
    final raw = await _readData('brands');
    final List decoded = jsonDecode(raw);
    return decoded.map((item) => item as String).toList();
  }

  @override
  Stream<List<String>> watchBrands() {
    return watchQuery(
      tables: ['config'],
      query: getBrands,
    );
  }

  @override
  Future<void> saveBrands(List<String> brands) async {
    final raw = jsonEncode(brands);
    await _writeData('brands', raw);
  }

  @override
  Future<List<String>> getProofTypes() async {
    final raw = await _readData('proof_types');
    final List decoded = jsonDecode(raw);
    return decoded.map((item) => item as String).toList();
  }

  @override
  Stream<List<String>> watchProofTypes() {
    return watchQuery(
      tables: ['config'],
      query: getProofTypes,
    );
  }

  @override
  Future<void> saveProofTypes(List<String> proofTypes) async {
    final raw = jsonEncode(proofTypes);
    await _writeData('proof_types', raw);
  }
}
