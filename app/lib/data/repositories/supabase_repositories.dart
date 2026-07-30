import 'dart:async';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/customer.dart';
import '../models/outstanding.dart';
import '../models/activity.dart';
import '../models/weekday.dart';
import '../models/place.dart';
import '../models/area.dart';
import '../models/collection.dart';
import '../models/product.dart';
import '../models/sale.dart';
import '../models/location.dart';
import '../models/nominee.dart';
import '../models/id_proof.dart';
import 'customer_repository.dart';
import 'route_repository.dart';
import 'collection_repository.dart';
import 'sale_repository.dart';
import 'product_repository.dart';

Future<String> _uploadFile(String bucket, String localPath, String remotePath) async {
  final client = Supabase.instance.client;
  if (localPath.startsWith('http://') || localPath.startsWith('https://')) {
    return localPath;
  }
  try {
    String cleanPath = localPath;
    if (cleanPath.startsWith('file://')) {
      cleanPath = Uri.parse(cleanPath).toFilePath();
    }
    final file = File(cleanPath);
    if (!await file.exists()) {
      // ignore: avoid_print
      print('Warning: local file does not exist at path: $cleanPath');
      return localPath;
    }
    await client.storage.from(bucket).upload(
      remotePath,
      file,
      fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
    );
    final publicUrl = client.storage.from(bucket).getPublicUrl(remotePath);
    // ignore: avoid_print
    print('Successfully uploaded file to Supabase storage. Public URL: $publicUrl');
    return publicUrl;
  } catch (e, stackTrace) {
    // ignore: avoid_print
    print('Error uploading file to Supabase storage: $e');
    // ignore: avoid_print
    print(stackTrace);
    return localPath;
  }
}

class SupabaseCustomerRepository implements CustomerRepository {
  final _client = Supabase.instance.client;

  @override
  Stream<List<Customer>> watchAllCustomers() {
    return _client
        .from('customers')
        .stream(primaryKey: ['id'])
        .order('sequence_number')
        .asyncMap((maps) async {
          final List<Customer> results = [];
          for (final map in maps) {
            final id = map['id'] as String;
            final nominees = await getNominees(id);
            final proofs = await getProofs(id);
            results.add(Customer(
              id: map['id'] as String,
              customerCode: (map['customer_code'] as String?) ?? '',
              name: (map['name'] as String?) ?? '',
              phone: (map['phone'] as String?) ?? '',
              alternatePhone: map['alternate_phone'] as String?,
              address: (map['address'] as String?) ?? '',
              landmark: map['landmark'] as String?,
              proofUrl: map['proof_url'] as String?,
              locationUrl: map['location_url'] as String?,
              location: (map['latitude'] != null && map['longitude'] != null)
                  ? Location(lat: (map['latitude'] as num).toDouble(), lng: (map['longitude'] as num).toDouble())
                  : null,
              nominees: nominees,
              idProofs: proofs,
              weekdayId: (map['weekday_id'] as String?) ?? '',
              placeId: (map['place_id'] as String?) ?? '',
              areaId: (map['area_id'] as String?) ?? '',
              sequenceNumber: (map['sequence_number'] as num?)?.toInt() ?? 0,
              status: (map['status'] as String?) ?? 'ACTIVE',
              guardianName: map['guardian_name'] as String?,
              dob: map['dob'] as String?,
              occupation: map['occupation'] as String?,
              notes: map['notes'] as String?,
            ));
          }
          return results;
        });
  }

  Future<List<Nominee>> getNominees(String customerId) async {
    final res = await _client.from('customer_nominees').select().eq('customer_id', customerId);
    return res.map((n) => Nominee(
      id: n['id'] as String,
      name: n['name'] as String,
      phone: (n['phone'] as String?) ?? '',
      relation: n['relation'] as String?,
    )).toList();
  }

  Future<List<IdProof>> getProofs(String customerId) async {
    final res = await _client.from('customer_proofs').select().eq('customer_id', customerId);
    return res.map((p) => IdProof(
      id: p['id'] as String,
      type: p['proof_type'] as String,
      number: 'DOC-PROOF',
      document: IdProofDocument(
        filename: 'proof',
        mimeType: 'image/jpeg',
        sizeBytes: 0,
        localUri: p['image_url'] as String,
      ),
    )).toList();
  }

  @override
  Future<List<Customer>> getAllCustomers() async {
    final maps = await _client.from('customers').select().order('sequence_number');
    final List<Customer> results = [];
    for (final map in maps) {
      final id = map['id'] as String;
      final nominees = await getNominees(id);
      final proofs = await getProofs(id);
      results.add(Customer(
        id: map['id'] as String,
        customerCode: (map['customer_code'] as String?) ?? '',
        name: (map['name'] as String?) ?? '',
        phone: (map['phone'] as String?) ?? '',
        alternatePhone: map['alternate_phone'] as String?,
        address: (map['address'] as String?) ?? '',
        landmark: map['landmark'] as String?,
        proofUrl: map['proof_url'] as String?,
        locationUrl: map['location_url'] as String?,
        location: (map['latitude'] != null && map['longitude'] != null)
            ? Location(lat: (map['latitude'] as num).toDouble(), lng: (map['longitude'] as num).toDouble())
            : null,
        nominees: nominees,
        idProofs: proofs,
        weekdayId: (map['weekday_id'] as String?) ?? '',
        placeId: (map['place_id'] as String?) ?? '',
        areaId: (map['area_id'] as String?) ?? '',
        sequenceNumber: (map['sequence_number'] as num?)?.toInt() ?? 0,
        status: (map['status'] as String?) ?? 'ACTIVE',
        guardianName: map['guardian_name'] as String?,
        dob: map['dob'] as String?,
        occupation: map['occupation'] as String?,
        notes: map['notes'] as String?,
      ));
    }
    return results;
  }

  @override
  Stream<List<Customer>> watchCustomersByArea(String areaId) {
    return watchAllCustomers().map((list) => list.where((c) => c.areaId == areaId).toList());
  }

  @override
  Future<List<Customer>> getCustomersByArea(String areaId) async {
    final all = await getAllCustomers();
    return all.where((c) => c.areaId == areaId).toList();
  }

  @override
  Future<Customer?> getCustomerById(String id) async {
    final res = await _client.from('customers').select().eq('id', id).maybeSingle();
    if (res == null) return null;
    final nominees = await getNominees(id);
    final proofs = await getProofs(id);
    return Customer(
      id: res['id'] as String,
      customerCode: (res['customer_code'] as String?) ?? '',
      name: (res['name'] as String?) ?? '',
      phone: (res['phone'] as String?) ?? '',
      alternatePhone: res['alternate_phone'] as String?,
      address: (res['address'] as String?) ?? '',
      landmark: res['landmark'] as String?,
      proofUrl: res['proof_url'] as String?,
      locationUrl: res['location_url'] as String?,
      location: (res['latitude'] != null && res['longitude'] != null)
          ? Location(lat: (res['latitude'] as num).toDouble(), lng: (res['longitude'] as num).toDouble())
          : null,
      nominees: nominees,
      idProofs: proofs,
      weekdayId: (res['weekday_id'] as String?) ?? '',
      placeId: (res['place_id'] as String?) ?? '',
      areaId: (res['area_id'] as String?) ?? '',
      sequenceNumber: (res['sequence_number'] as num?)?.toInt() ?? 0,
      status: (res['status'] as String?) ?? 'ACTIVE',
      guardianName: res['guardian_name'] as String?,
      dob: res['dob'] as String?,
      occupation: res['occupation'] as String?,
      notes: res['notes'] as String?,
    );
  }

  @override
  Stream<Customer?> watchCustomerById(String id) {
    return watchAllCustomers().map((list) {
      final matches = list.where((c) => c.id == id);
      return matches.isEmpty ? null : matches.first;
    });
  }

  @override
  Stream<Outstanding> watchCustomerOutstanding(String customerId) {
    final controller = StreamController<Outstanding>();
    Future<void> reload() async {
      try {
        final outstanding = await getCustomerOutstanding(customerId);
        if (!controller.isClosed) {
          controller.add(outstanding);
        }
      } catch (e) {
        if (!controller.isClosed) {
          controller.addError(e);
        }
      }
    }

    reload();

    final channel = _client.channel('outstanding_$customerId')
      ..onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'collections',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'customer_id',
          value: customerId,
        ),
        callback: (payload) => reload(),
      )
      ..onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'sales',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'customer_id',
          value: customerId,
        ),
        callback: (payload) => reload(),
      )
      ..subscribe();

    controller.onCancel = () {
      channel.unsubscribe();
      controller.close();
    };

    return controller.stream;
  }

  @override
  Future<Outstanding> getCustomerOutstanding(String customerId) async {
    final res = await _client.from('customer_outstanding_view').select().eq('customer_id', customerId).maybeSingle();
    if (res == null) {
      return Outstanding(
        customerId: customerId,
        totalFinanced: 0,
        totalCollected: 0,
        outstandingAmount: 0,
      );
    }
    return Outstanding(
      customerId: customerId,
      totalFinanced: (res['total_financed'] as num?)?.toInt() ?? 0,
      totalCollected: (res['total_collected'] as num?)?.toInt() ?? 0,
      outstandingAmount: (res['outstanding_amount'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  Stream<List<Activity>> watchCustomerTimeline(String customerId) {
    final controller = StreamController<List<Activity>>();
    Future<void> reload() async {
      try {
        final timeline = await getCustomerTimeline(customerId);
        if (!controller.isClosed) {
          controller.add(timeline);
        }
      } catch (e) {
        if (!controller.isClosed) {
          controller.addError(e);
        }
      }
    }

    reload();

    final channel = _client.channel('timeline_$customerId')
      ..onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'collections',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'customer_id',
          value: customerId,
        ),
        callback: (payload) => reload(),
      )
      ..onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'sales',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'customer_id',
          value: customerId,
        ),
        callback: (payload) => reload(),
      )
      ..subscribe();

    controller.onCancel = () {
      channel.unsubscribe();
      controller.close();
    };

    return controller.stream;
  }

  @override
  Future<List<Activity>> getCustomerTimeline(String customerId) async {
    final List<Activity> activities = [];

    // Query collections
    final collectionMaps = await _client
        .from('collections')
        .select()
        .eq('customer_id', customerId);

    for (final col in collectionMaps) {
      final id = col['id'] as String;
      final at = DateTime.parse(col['visit_datetime'] as String);
      final status = col['status'] as String;
      final amount = (col['amount'] as num?)?.toInt() ?? 0;
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

    // Query sales and nested sale items
    final saleMaps = await _client
        .from('sales')
        .select('*, sale_items(*, products(*))')
        .eq('customer_id', customerId);

    for (final sale in saleMaps) {
      final id = sale['id'] as String;
      final at = DateTime.parse(sale['sale_datetime'] as String);
      final total = (sale['total_amount'] as num?)?.toInt() ?? 0;
      final advance = (sale['advance_amount'] as num?)?.toInt() ?? 0;
      final creditAdded = (sale['financed_amount'] as num?)?.toInt() ?? 0;
      final saleTypeStr = sale['sale_type'] as String;
      final soldBy = sale['sold_by'] as String;
      final remarks = sale['remarks'] as String?;

      final List<SaleItemDetail> items = [];
      for (final item in sale['sale_items'] as List<dynamic>) {
        final prod = item['products'] as Map<String, dynamic>;
        items.add(SaleItemDetail(
          productName: prod['name'] as String,
          quantity: (item['quantity'] as num?)?.toInt() ?? 1,
          unitPrice: (item['unit_price'] as num?)?.toInt() ?? 0,
        ));
      }

      activities.add(Activity.sale(
        id: id,
        at: at,
        items: items,
        total: total,
        advance: advance,
        creditAdded: creditAdded,
        saleType: saleTypeStr == 'READY' ? 'READY' : 'CREDIT',
        collectorName: soldBy,
        note: remarks,
      ));
    }

    activities.sort((a, b) => b.at.compareTo(a.at));
    return activities;
  }

  @override
  Future<void> updateCustomerProfile(String id, {String? phone, String? proofUrl, String? locationUrl}) async {
    final Map<String, dynamic> updates = {};
    if (phone != null) updates['phone'] = phone;
    if (locationUrl != null) updates['location_url'] = locationUrl;

    if (proofUrl != null && proofUrl.isNotEmpty) {
      final extension = proofUrl.split('.').last;
      final remotePath = '$id/profile.$extension';
      final remoteProofUrl = await _uploadFile('customer-photos', proofUrl, remotePath);
      updates['proof_url'] = remoteProofUrl;
    }

    if (updates.isNotEmpty) {
      await _client.from('customers').update(updates).eq('id', id);
    }
  }

  @override
  Future<void> addNominee(String customerId, String name, String phone, String relation) async {
    await _client.from('customer_nominees').insert({
      'id': 'nom_${DateTime.now().microsecondsSinceEpoch}',
      'customer_id': customerId,
      'name': name,
      'phone': phone,
      'relation': relation,
    });
  }

  @override
  Future<void> addProofImage(String customerId, String proofType, String imageUrl) async {
    final id = 'proof_${DateTime.now().millisecondsSinceEpoch}';
    String remoteUrl = imageUrl;
    if (imageUrl.isNotEmpty) {
      final extension = imageUrl.split('.').last;
      final remotePath = '$customerId/proof_$id.$extension';
      remoteUrl = await _uploadFile('customer-proofs', imageUrl, remotePath);
    }
    await _client.from('customer_proofs').insert({
      'id': id,
      'customer_id': customerId,
      'proof_type': proofType,
      'image_url': remoteUrl,
    });
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
  }) async {
    final customerId = 'cust_${DateTime.now().millisecondsSinceEpoch}';
    final code = 'LC-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';

    // Get next sequence number in area
    final seqRes = await _client
        .from('customers')
        .select('sequence_number')
        .eq('area_id', areaId)
        .order('sequence_number', ascending: false)
        .limit(1)
        .maybeSingle();
    final nextSeq = seqRes == null ? 1 : ((seqRes['sequence_number'] as num?)?.toInt() ?? 0) + 1;

    final customerData = {
      'id': customerId,
      'customer_code': code,
      'name': name,
      'phone': phone,
      'alternate_phone': alternatePhone,
      'address': address,
      'landmark': landmark,
      'proof_url': null,
      'location_url': location?.lat != null ? 'https://maps.google.com/?q=${location!.lat},${location.lng}' : null,
      'latitude': location?.lat,
      'longitude': location?.lng,
      'weekday_id': weekdayId,
      'place_id': placeId,
      'area_id': areaId,
      'sequence_number': nextSeq,
      'status': 'ACTIVE',
      'dob': dob,
      'occupation': occupation,
      'notes': notes,
      'created_by': 'collector_local',
    };

    await _client.from('customers').insert(customerData);

    if (nominees != null) {
      for (var n in nominees) {
        await _client.from('customer_nominees').insert({
          'id': n.id.isNotEmpty ? n.id : 'nom_${DateTime.now().microsecondsSinceEpoch}_${n.name.hashCode}',
          'customer_id': customerId,
          'name': n.name,
          'phone': n.phone,
          'relation': n.relation,
        });
      }
    }

    if (idProofs != null) {
      for (var p in idProofs) {
        final localPath = p.document?.localUri ?? '';
        String remoteUrl = localPath;
        if (localPath.isNotEmpty) {
          final extension = localPath.split('.').last;
          final sanitizedName = name.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
          final sanitizedType = p.type.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
          final remotePath = '$customerId/${sanitizedName}_$sanitizedType.$extension';
          remoteUrl = await _uploadFile('customer-proofs', localPath, remotePath);
        }
        await _client.from('customer_proofs').insert({
          'id': p.id,
          'customer_id': customerId,
          'proof_type': p.type,
          'image_url': remoteUrl,
        });
      }
    }

    if (openingBalance > 0) {
      final saleId = 'sale_ob_$customerId';
      await _client.from('sales').insert({
        'id': saleId,
        'customer_id': customerId,
        'sale_datetime': DateTime.now().toIso8601String(),
        'sale_type': 'CREDIT',
        'total_amount': openingBalance,
        'advance_amount': 0,
        'financed_amount': openingBalance,
        'sold_by': 'system',
        'remarks': 'Opening Balance',
      });
    }

    final created = await getCustomerById(customerId);
    return created!;
  }

  @override
  Future<void> updateCustomer(Customer customer) async {
    // 1. Update customers table fields (using proof_url for avatar)
    await _client.from('customers').update({
      'name': customer.name,
      'phone': customer.phone,
      'alternate_phone': customer.alternatePhone,
      'address': customer.address,
      'landmark': customer.landmark,
      'proof_url': customer.proofUrl,
      'location_url': customer.locationUrl,
      'latitude': customer.location?.lat,
      'longitude': customer.location?.lng,
      'weekday_id': customer.weekdayId,
      'place_id': customer.placeId,
      'area_id': customer.areaId,
      'status': customer.status,
      'guardian_name': customer.guardianName,
      'dob': customer.dob,
      'occupation': customer.occupation,
      'notes': customer.notes,
    }).eq('id', customer.id);

    // 2. Refresh nominees
    await _client.from('customer_nominees').delete().eq('customer_id', customer.id);
    for (var n in customer.nominees) {
      await _client.from('customer_nominees').insert({
        'id': n.id.isNotEmpty ? n.id : 'nom_${DateTime.now().microsecondsSinceEpoch}_${n.name.hashCode}',
        'customer_id': customer.id,
        'name': n.name,
        'phone': n.phone,
        'relation': n.relation,
      });
    }

    // 3. Refresh proofs (uploading local files to S3 bucket if any)
    await _client.from('customer_proofs').delete().eq('customer_id', customer.id);
    for (var p in customer.idProofs) {
      final localPath = p.document?.localUri ?? '';
      String remoteUrl = localPath;
      if (localPath.isNotEmpty && !localPath.startsWith('http')) {
        final extension = localPath.split('.').last.split('?').first;
        final sanitizedName = customer.name.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
        final sanitizedType = p.type.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
        final remotePath = '${customer.id}/${sanitizedName}_$sanitizedType.$extension';
        remoteUrl = await _uploadFile('customer-proofs', localPath, remotePath);
      }
      await _client.from('customer_proofs').insert({
        'id': p.id,
        'customer_id': customer.id,
        'proof_type': p.type,
        'image_url': remoteUrl,
      });
    }
  }

  @override
  Future<void> undoCustomer(String customerId) async {
    await _client.from('customers').delete().eq('id', customerId);
  }
}

class SupabaseRouteRepository implements RouteRepository {
  final _client = Supabase.instance.client;

  @override
  Future<List<Weekday>> getWeekdays() async {
    final maps = await _client.from('weekdays').select().order('sort_order');
    return maps.map((w) => Weekday.fromJson({
      'id': w['id'],
      'name': w['name'],
      'sortOrder': w['sort_order'],
    })).toList();
  }

  @override
  Stream<List<Weekday>> watchWeekdays() {
    return _client.from('weekdays').stream(primaryKey: ['id']).order('sort_order').map(
      (list) => list.map((w) => Weekday.fromJson({
        'id': w['id'],
        'name': w['name'],
        'sortOrder': w['sort_order'],
      })).toList()
    );
  }

  @override
  Future<List<Place>> getPlacesByWeekday(String weekdayId) async {
    final maps = await _client.from('places').select().eq('weekday_id', weekdayId).order('name');
    return maps.map((p) => Place.fromJson({
      'id': p['id'],
      'weekdayId': p['weekday_id'],
      'name': p['name'],
    })).toList();
  }

  @override
  Stream<List<Place>> watchPlacesByWeekday(String weekdayId) {
    return _client.from('places').stream(primaryKey: ['id']).eq('weekday_id', weekdayId).map(
      (list) => list.map((p) => Place.fromJson({
        'id': p['id'],
        'weekdayId': p['weekday_id'],
        'name': p['name'],
      })).toList()
    );
  }

  @override
  Future<List<Area>> getAreasByPlace(String placeId) async {
    final maps = await _client.from('areas').select().eq('place_id', placeId).order('name');
    return maps.map((a) => Area.fromJson({
      'id': a['id'],
      'placeId': a['place_id'],
      'name': a['name'],
    })).toList();
  }

  @override
  Stream<List<Area>> watchAreasByPlace(String placeId) {
    return _client.from('areas').stream(primaryKey: ['id']).eq('place_id', placeId).map(
      (list) => list.map((a) => Area.fromJson({
        'id': a['id'],
        'placeId': a['place_id'],
        'name': a['name'],
      })).toList()
    );
  }

  @override
  Future<int> getCustomerCountForWeekday(String weekdayId) async {
    final maps = await _client.from('route_summary_view').select('customer_count').eq('weekday_id', weekdayId);
    return maps.fold<int>(0, (sum, row) => sum + ((row['customer_count'] as num?)?.toInt() ?? 0));
  }

  @override
  Future<int> getCustomerCountForPlace(String placeId) async {
    final maps = await _client.from('route_summary_view').select('customer_count').eq('place_id', placeId);
    return maps.fold<int>(0, (sum, row) => sum + ((row['customer_count'] as num?)?.toInt() ?? 0));
  }

  @override
  Future<int> getCustomerCountForArea(String areaId) async {
    final maps = await _client.from('route_summary_view').select('customer_count').eq('area_id', areaId);
    if (maps.isEmpty) return 0;
    return (maps.first['customer_count'] as num?)?.toInt() ?? 0;
  }

  @override
  Future<int> getExpectedCollectionForWeekday(String weekdayId) async {
    final maps = await _client.from('route_summary_view').select('outstanding_amount').eq('weekday_id', weekdayId);
    return maps.fold<int>(0, (sum, row) => sum + ((row['outstanding_amount'] as num?)?.toInt() ?? 0));
  }

  @override
  Future<int> getExpectedCollectionForPlace(String placeId) async {
    final maps = await _client.from('route_summary_view').select('outstanding_amount').eq('place_id', placeId);
    return maps.fold<int>(0, (sum, row) => sum + ((row['outstanding_amount'] as num?)?.toInt() ?? 0));
  }

  @override
  Future<int> getExpectedCollectionForArea(String areaId) async {
    final maps = await _client.from('route_summary_view').select('outstanding_amount').eq('area_id', areaId);
    if (maps.isEmpty) return 0;
    return (maps.first['outstanding_amount'] as num?)?.toInt() ?? 0;
  }

  @override
  Future<int> getActualCollectionForWeekday(String weekdayId) async {
    final customerMaps = await _client.from('customers').select('id').eq('weekday_id', weekdayId);
    final customerIds = customerMaps.map((c) => c['id'] as String).toList();
    if (customerIds.isEmpty) return 0;

    final maps = await _client.from('collections')
        .select('amount')
        .eq('status', 'PAYMENT')
        .inFilter('customer_id', customerIds);
    return maps.fold<int>(0, (sum, row) => sum + ((row['amount'] as num?)?.toInt() ?? 0));
  }

  @override
  Future<int> getActualCollectionForPlace(String placeId) async {
    final customerMaps = await _client.from('customers').select('id').eq('place_id', placeId);
    final customerIds = customerMaps.map((c) => c['id'] as String).toList();
    if (customerIds.isEmpty) return 0;

    final maps = await _client.from('collections')
        .select('amount')
        .eq('status', 'PAYMENT')
        .inFilter('customer_id', customerIds);
    return maps.fold<int>(0, (sum, row) => sum + ((row['amount'] as num?)?.toInt() ?? 0));
  }

  @override
  Future<int> getActualCollectionForArea(String areaId) async {
    final customerMaps = await _client.from('customers').select('id').eq('area_id', areaId);
    final customerIds = customerMaps.map((c) => c['id'] as String).toList();
    if (customerIds.isEmpty) return 0;

    final maps = await _client.from('collections')
        .select('amount')
        .eq('status', 'PAYMENT')
        .inFilter('customer_id', customerIds);
    return maps.fold<int>(0, (sum, row) => sum + ((row['amount'] as num?)?.toInt() ?? 0));
  }

  @override
  Future<Place> addPlace({required String weekdayId, required String name}) async {
    final placeId = 'place_${DateTime.now().millisecondsSinceEpoch}';
    await _client.from('places').insert({
      'id': placeId,
      'weekday_id': weekdayId,
      'name': name,
    });
    return Place(id: placeId, weekdayId: weekdayId, name: name);
  }

  @override
  Future<Area> addArea({required String placeId, required String name}) async {
    final areaId = 'area_${DateTime.now().millisecondsSinceEpoch}';
    await _client.from('areas').insert({
      'id': areaId,
      'place_id': placeId,
      'name': name,
    });
    return Area(id: areaId, placeId: placeId, name: name);
  }
}

class SupabaseCollectionRepository implements CollectionRepository {
  final _client = Supabase.instance.client;

  @override
  Stream<List<Collection>> watchAllCollections() {
    return _client.from('collections').stream(primaryKey: ['id']).order('visit_datetime').map(
      (list) => list.map((c) => Collection.fromJson({
        'id': c['id'],
        'customerId': c['customer_id'],
        'visitDatetime': c['visit_datetime'],
        'status': c['status'],
        'amount': c['amount'],
        'reason': c['reason'],
        'collectedBy': c['collected_by'],
      })).toList()
    );
  }

  @override
  Stream<List<Collection>> watchCollectionsForCustomerToday(String customerId) {
    final todayStr = DateTime.now().toIso8601String().substring(0, 10);
    return watchAllCollections().map((list) => list.where((c) {
      final dateStr = c.visitDatetime.toIso8601String().substring(0, 10);
      return c.customerId == customerId && dateStr == todayStr;
    }).toList());
  }

  @override
  Future<List<Collection>> getCollectionsForCustomerToday(String customerId) async {
    final todayStr = DateTime.now().toIso8601String().substring(0, 10);
    final maps = await _client.from('collections').select().eq('customer_id', customerId);
    final collections = maps.map((c) => Collection.fromJson({
      'id': c['id'],
      'customerId': c['customer_id'],
      'visitDatetime': c['visit_datetime'],
      'status': c['status'],
      'amount': c['amount'],
      'reason': c['reason'],
      'collectedBy': c['collected_by'],
    })).toList();
    return collections.where((c) {
      final dateStr = c.visitDatetime.toIso8601String().substring(0, 10);
      return dateStr == todayStr;
    }).toList();
  }

  @override
  Future<void> saveCollection({
    required String customerId,
    required String status,
    required int amount,
    String? reason,
    required String collectedBy,
    DateTime? customDate,
  }) async {
    final date = customDate ?? DateTime.now();
    await _client.from('collections').insert({
      'id': 'col_${DateTime.now().millisecondsSinceEpoch}',
      'customer_id': customerId,
      'visit_datetime': date.toIso8601String(),
      'status': status,
      'amount': amount,
      'reason': reason,
      'collected_by': collectedBy,
    });
  }

  @override
  Future<void> undoCollection(String collectionId) async {
    await _client.from('collections').delete().eq('id', collectionId);
  }
}

class SupabaseSaleRepository implements SaleRepository {
  final _client = Supabase.instance.client;

  @override
  Stream<List<Sale>> watchAllSales() {
    return _client.from('sales').stream(primaryKey: ['id']).order('sale_datetime').map(
      (list) => list.map((s) => Sale.fromJson({
        'id': s['id'],
        'customerId': s['customer_id'],
        'saleDatetime': s['sale_datetime'],
        'saleType': s['sale_type'],
        'totalAmount': s['total_amount'],
        'advanceAmount': s['advance_amount'],
        'financedAmount': s['financed_amount'],
        'soldBy': s['sold_by'],
        'remarks': s['remarks'],
      })).toList()
    );
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
  }) async {
    final saleId = 'sale_${DateTime.now().millisecondsSinceEpoch}';
    final date = customDate ?? DateTime.now();

    int totalAmount = 0;
    for (var item in items) {
      totalAmount += (item['quantity'] as int) * (item['unitPrice'] as int);
    }
    totalAmount = totalAmount - discount + creditCharge;
    final financedAmount = totalAmount - advanceAmount;
    final saleType = financedAmount == 0 ? 'READY' : 'CREDIT';

    // 1. Save Sale
    await _client.from('sales').insert({
      'id': saleId,
      'customer_id': customerId,
      'sale_datetime': date.toIso8601String(),
      'sale_type': saleType,
      'total_amount': totalAmount,
      'advance_amount': advanceAmount,
      'financed_amount': financedAmount,
      'sold_by': soldBy,
      'remarks': remarks,
    });

    // 2. Save Sale Items and Inventory Transactions
    for (var item in items) {
      final productId = item['productId'] as String;
      final qty = item['quantity'] as int;
      final unitPrice = item['unitPrice'] as int;

      await _client.from('sale_items').insert({
        'id': 'sitem_${DateTime.now().microsecondsSinceEpoch}',
        'sale_id': saleId,
        'product_id': productId,
        'quantity': qty,
        'unit_price': unitPrice,
        'total_price': qty * unitPrice,
      });

      await _client.from('inventory_transactions').insert({
        'id': 'tx_sale_${DateTime.now().microsecondsSinceEpoch}',
        'product_id': productId,
        'transaction_type': 'SALE',
        'quantity': qty,
        'reference_id': saleId,
        'remarks': 'Sale purchase item transaction',
        'created_by': soldBy,
      });
    }
  }

  @override
  Future<void> undoSale(String saleId) async {
    await _client.from('sales').delete().eq('id', saleId);
  }
}

class SupabaseProductRepository implements ProductRepository {
  final _client = Supabase.instance.client;

  @override
  Future<List<Product>> getProducts() async {
    final maps = await _client.from('product_stock_view').select();
    return maps.map((m) => Product.fromJson({
      'id': m['product_id'] ?? m['id'],
      'sku': m['sku'],
      'name': m['name'],
      'brand': m['brand'],
      'categoryId': m['category_id'],
      'minimumStock': m['minimum_stock'] ?? 5,
      'stock': m['current_stock'] ?? m['stock'] ?? 0,
      'costPrice': m['cost_price'] ?? 0,
      'sellingPrice': m['selling_price'] ?? 0,
      'mrp': m['mrp'] ?? 0,
      'imageUrl': m['image_url'],
      'description': m['description'],
    })).toList();
  }

  @override
  Stream<List<Product>> watchProducts() {
    final controller = StreamController<List<Product>>();
    Future<void> reload() async {
      try {
        final list = await getProducts();
        if (!controller.isClosed) {
          controller.add(list);
        }
      } catch (e) {
        if (!controller.isClosed) {
          controller.addError(e);
        }
      }
    }

    reload();

    final channel = _client.channel('products_stock')
      ..onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'products',
        callback: (p) => reload(),
      )
      ..onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'inventory_transactions',
        callback: (p) => reload(),
      )
      ..subscribe();

    controller.onCancel = () {
      channel.unsubscribe();
      controller.close();
    };

    return controller.stream;
  }

  @override
  Future<Product?> getProductById(String id) async {
    final all = await getProducts();
    final matches = all.where((p) => p.id == id);
    return matches.isEmpty ? null : matches.first;
  }

  String _getCategoryName(String categoryId) {
    final map = {
      'cat-kat': 'Kitchen Appliances',
      'cat-laundry': 'Laundry',
      'cat-audio': 'Home Audio',
      'cat-lighting': 'Lighting',
      'cat-cooling': 'Cooling',
    };
    return map[categoryId] ?? 'General';
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
    final productId = 'prod_${DateTime.now().millisecondsSinceEpoch}';

    String? remoteUrl = imageUrl;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      final extension = imageUrl.split('.').last.split('?').first;
      final categoryName = _getCategoryName(categoryId).replaceAll(' ', '_');
      final productName = name.replaceAll(' ', '_');
      final remotePath = '$categoryName/$productName.$extension';
      remoteUrl = await _uploadFile('product-photos', imageUrl, remotePath);
    }

    await _client.from('products').insert({
      'id': productId,
      'sku': sku,
      'name': name,
      'brand': brand,
      'category_id': categoryId,
      'cost_price': costPrice,
      'selling_price': sellingPrice,
      'mrp': mrp,
      'minimum_stock': minimumStock,
      'image_url': remoteUrl,
      'description': description,
    });

    if (stock > 0) {
      await _client.from('inventory_transactions').insert({
        'id': 'tx_purch_${DateTime.now().millisecondsSinceEpoch}',
        'product_id': productId,
        'transaction_type': 'PURCHASE',
        'quantity': stock,
        'reference_id': 'INIT_PURCHASE',
        'remarks': 'Initial product add stock',
        'created_by': 'collector_local',
      });
    }

    final prod = await getProductById(productId);
    return prod!;
  }

  @override
  Future<void> updateProduct(Product product) async {
    String? remoteUrl = product.imageUrl;
    if (product.imageUrl != null && product.imageUrl!.isNotEmpty && !product.imageUrl!.startsWith('http')) {
      final extension = product.imageUrl!.split('.').last.split('?').first;
      final categoryName = _getCategoryName(product.categoryId).replaceAll(' ', '_');
      final productName = product.name.replaceAll(' ', '_');
      final remotePath = '$categoryName/$productName.$extension';
      remoteUrl = await _uploadFile('product-photos', product.imageUrl!, remotePath);
    }

    await _client.from('products').update({
      'sku': product.sku,
      'name': product.name,
      'brand': product.brand,
      'category_id': product.categoryId,
      'cost_price': product.costPrice,
      'selling_price': product.sellingPrice,
      'mrp': product.mrp,
      'minimum_stock': product.minimumStock,
      'image_url': remoteUrl,
      'description': product.description,
    }).eq('id', product.id);
  }
}
