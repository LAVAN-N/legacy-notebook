import 'dart:async';
import 'dart:convert';
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
import 'config_repository.dart';
import 'local_sqlite_repositories.dart';
import '../models/category.dart';
import '../../core/utils/uuid.dart';

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

Future<void> _deleteFile(String bucket, String publicUrl) async {
  final client = Supabase.instance.client;
  try {
    final uri = Uri.tryParse(publicUrl);
    if (uri == null) return;
    final pathSegments = uri.pathSegments;
    final bucketIdx = pathSegments.indexOf(bucket);
    if (bucketIdx != -1 && bucketIdx + 1 < pathSegments.length) {
      final relativePath = pathSegments.sublist(bucketIdx + 1).join('/');
      await client.storage.from(bucket).remove([relativePath]);
      // ignore: avoid_print
      print('Successfully deleted file from Supabase storage: $relativePath');
    }
  } catch (e) {
    // ignore: avoid_print
    print('Error deleting file from Supabase storage: $e');
  }
}

class SupabaseCustomerRepository implements CustomerRepository {
  final _client = Supabase.instance.client;

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

  Customer _mapToCustomer(Map<String, dynamic> map) {
    final List<dynamic> nomineeList = map['nominees'] != null
        ? (map['nominees'] is String 
            ? jsonDecode(map['nominees'] as String) 
            : map['nominees']) as List<dynamic>
        : [];
    final nominees = nomineeList
        .map((item) => Nominee.fromJson(item as Map<String, dynamic>))
        .toList();

    final List<dynamic> proofList = map['id_proofs'] != null
        ? (map['id_proofs'] is String 
            ? jsonDecode(map['id_proofs'] as String) 
            : map['id_proofs']) as List<dynamic>
        : [];
    final idProofs = proofList
        .map((item) => IdProof.fromJsonCustom(item as Map<String, dynamic>))
        .toList();

    return Customer(
      id: map['id'] as String,
      customerCode: (map['customer_code'] as String?) ?? '',
      name: (map['name'] as String?) ?? '',
      phone: (map['phone'] as String?) ?? '',
      alternatePhone: map['alternate_phone'] as String?,
      address: (map['address'] as String?) ?? '',
      landmark: map['landmark'] as String?,
      profileUrl: map['profile_url'] as String?,
      locationUrl: map['location_url'] as String?,
      location: _parseLocation(map['latitude'], map['longitude'], map['location_url']),
      nominees: nominees,
      idProofs: idProofs,
      weekdayId: (map['weekday_id'] as String?) ?? '',
      placeId: (map['place_id'] as String?) ?? '',
      areaId: (map['area_id'] as String?) ?? '',
      status: (map['status'] as String?) ?? 'ACTIVE',
      dob: map['dob'] as String?,
      occupation: map['occupation'] as String?,
      notes: map['notes'] as String?,
    );
  }

  @override
  Stream<List<Customer>> watchAllCustomers() {
    return _client
        .from('customers')
        .stream(primaryKey: ['id'])
        .order('id')
        .map((maps) => maps.map((map) => _mapToCustomer(map)).toList());
  }

  @override
  Future<List<Customer>> getAllCustomers() async {
    final maps = await _client.from('customers').select().order('id');
    return maps.map((map) => _mapToCustomer(map)).toList();
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
    return _mapToCustomer(res);
  }

  @override
  Stream<Customer?> watchCustomerById(String id) {
    return watchAllCustomers().map((list) {
      final matches = list.where((c) => c.id == id);
      return matches.isEmpty ? null : matches.first;
    });
  }

  @override
  Stream<Outstanding> watchCustomerOutstanding(String customerId, {bool skipInitialFetch = false}) {
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

    if (!skipInitialFetch) reload();

    final channel = _client.channel('outstanding_${customerId}_${DateTime.now().microsecondsSinceEpoch}')
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

    controller.onCancel = () async {
      await channel.unsubscribe();
      await _client.removeChannel(channel);
      await controller.close();
    };

    return controller.stream;
  }

  @override
  Future<Outstanding> getCustomerOutstanding(String customerId) async {
    // Query sales total and lend total
    final salesRes = await _client
        .from('sales')
        .select('financed_amount, sale_type, remarks')
        .eq('customer_id', customerId);

    // Query collections total and target totals
    final collectionsRes = await _client
        .from('collections')
        .select('amount, status, reason')
        .eq('customer_id', customerId)
        .inFilter('status', ['PAYMENT', 'PARTIAL_PAYMENT']);

    int totalFinanced = 0;
    int totalLendFinanced = 0;
    int totalSaleFinanced = 0;

    for (final s in salesRes) {
      final amount = (s['financed_amount'] as num?)?.toInt() ?? 0;
      final type = (s['sale_type'] as String?)?.toUpperCase() ?? '';
      final remarks = s['remarks'] as String?;
      final isLend = type == 'LEND' || (remarks != null && remarks.startsWith('LEND_DETAILS:'));

      totalFinanced += amount;
      if (isLend) {
        totalLendFinanced += amount;
      } else {
        totalSaleFinanced += amount;
      }
    }

    int totalCollected = 0;
    int totalLendCollected = 0;
    int totalSaleCollected = 0;

    for (final col in collectionsRes) {
      final amount = (col['amount'] as num?)?.toInt() ?? 0;
      final reason = col['reason'] as String?;
      totalCollected += amount;
      final isLend = reason != null && reason.startsWith('COLLECTION_TARGET:target=LEND');
      if (isLend) {
        totalLendCollected += amount;
      } else {
        totalSaleCollected += amount;
      }
    }

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

    if (!skipInitialFetch) reload();

    final channel = _client.channel('timeline_${customerId}_${DateTime.now().microsecondsSinceEpoch}')
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

    controller.onCancel = () async {
      await channel.unsubscribe();
      await _client.removeChannel(channel);
      await controller.close();
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
      final dbSaleType = sale['sale_type'] as String;
      final soldBy = sale['sold_by'] as String;
      final remarks = sale['remarks'] as String?;
      final isLend = remarks != null && remarks.startsWith('LEND_DETAILS:');
      final saleTypeStr = isLend ? 'LEND' : dbSaleType;

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
        saleType: saleTypeStr,
        collectorName: soldBy,
        note: remarks,
      ));
    }

    activities.sort((a, b) => b.at.compareTo(a.at));
    return activities;
  }

  @override
  Future<void> updateCustomerProfile(String id, {String? phone, String? profileUrl, String? locationUrl}) async {
    final Map<String, dynamic> updates = {};
    if (phone != null) updates['phone'] = phone;
    if (locationUrl != null) updates['location_url'] = locationUrl;

    if (profileUrl != null && profileUrl.isNotEmpty) {
      final extension = profileUrl.split('.').last.toLowerCase();
      final remotePath = '$id/profile.$extension'.toLowerCase();
      final remoteProfileUrl = await _uploadFile('customer-photos', profileUrl, remotePath);
      updates['profile_url'] = remoteProfileUrl;
    }

    if (updates.isNotEmpty) {
      await _client.from('customers').update(updates).eq('id', id);
    }
  }

  @override
  Future<void> addNominee(String customerId, String name, String phone, String relation) async {
    final customer = await getCustomerById(customerId);
    if (customer != null) {
      final newNominee = Nominee(
        id: 'nom_${DateTime.now().microsecondsSinceEpoch}',
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
    final allRes = await _client.from('customers').select('id');
    int maxId = 0;
    for (final row in allRes) {
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
    final code = '$wCode-$pCode-$aCode-$paddedId';

    String? remoteProfileUrl;
    if (profileUrl != null && profileUrl.isNotEmpty) {
      final extension = profileUrl.split('.').last.split('?').first.toLowerCase();
      final remotePath = '$customerId/profile.$extension'.toLowerCase();
      remoteProfileUrl = await _uploadFile('customer-photos', profileUrl, remotePath);
    }

    final updatedNominees = (nominees ?? []).map((n) {
      return n.copyWith(
        id: n.id.isNotEmpty ? n.id : 'nom_${DateTime.now().microsecondsSinceEpoch}',
      );
    }).toList();

    final List<IdProof> uploadedProofs = [];
    if (idProofs != null) {
      for (var p in idProofs) {
        final localPath = p.document?.localUri ?? '';
        String remoteUrl = localPath;
        if (localPath.isNotEmpty) {
          final extension = localPath.split('.').last.toLowerCase();
          final sanitizedName = name.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
          final sanitizedType = p.type.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
          final remotePath = '$customerId/${sanitizedName}_$sanitizedType.$extension'.toLowerCase();
          remoteUrl = await _uploadFile('customer-proofs', localPath, remotePath);
        }
        uploadedProofs.add(p.copyWith(
          id: p.id.isNotEmpty ? p.id : 'proof_${DateTime.now().microsecondsSinceEpoch}',
          document: p.document?.copyWith(localUri: remoteUrl) ?? IdProofDocument(
            filename: 'proof',
            mimeType: 'image/jpeg',
            sizeBytes: 0,
            localUri: remoteUrl,
          ),
        ));
      }
    }

    final customerData = {
      'id': customerId,
      'customer_code': code,
      'name': name,
      'phone': phone,
      'alternate_phone': alternatePhone,
      'address': address,
      'landmark': landmark,
      'profile_url': remoteProfileUrl,
      'location_url': location?.lat != null ? 'https://maps.google.com/?q=${location!.lat},${location.lng}' : null,
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
      'nominees': updatedNominees.map((n) => n.toJson()).toList(),
      'id_proofs': uploadedProofs.map((p) => p.toJson()).toList(),
    };

    await _client.from('customers').insert(customerData);

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
    final existing = await getCustomerById(customer.id);
    if (existing != null) {
      // 1. Delete removed ID proofs from S3
      final existingProofUrls = existing.idProofs
          .map((p) => p.document?.localUri)
          .whereType<String>()
          .where((uri) => uri.startsWith('http'))
          .toList();
      final newProofUrls = customer.idProofs
          .map((p) => p.document?.localUri)
          .whereType<String>()
          .toList();

      for (final oldUrl in existingProofUrls) {
        if (!newProofUrls.contains(oldUrl)) {
          await _deleteFile('customer-proofs', oldUrl);
        }
      }

      // 2. Delete removed profile photo from S3
      final oldProfileUrl = existing.profileUrl;
      final newProfileUrl = customer.profileUrl;
      if (oldProfileUrl != null &&
          oldProfileUrl.startsWith('http') &&
          (newProfileUrl == null || newProfileUrl.isEmpty)) {
        await _deleteFile('customer-photos', oldProfileUrl);
      }
    }

    String? remoteProfileUrl = customer.profileUrl;
    if (remoteProfileUrl != null && remoteProfileUrl.isNotEmpty && !remoteProfileUrl.startsWith('http')) {
      final extension = remoteProfileUrl.split('.').last.split('?').first.toLowerCase();
      final remotePath = '${customer.id}/profile.$extension'.toLowerCase();
      remoteProfileUrl = await _uploadFile('customer-photos', remoteProfileUrl, remotePath);
    }

    final List<IdProof> uploadedProofs = [];
    for (var p in customer.idProofs) {
      final localPath = p.document?.localUri ?? '';
      String remoteUrl = localPath;
      if (localPath.isNotEmpty && !localPath.startsWith('http')) {
        final extension = localPath.split('.').last.split('?').first.toLowerCase();
        final sanitizedName = customer.name.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
        final sanitizedType = p.type.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
        final remotePath = '${customer.id}/${sanitizedName}_$sanitizedType.$extension'.toLowerCase();
        remoteUrl = await _uploadFile('customer-proofs', localPath, remotePath);
      }
      uploadedProofs.add(p.copyWith(
        id: p.id.isNotEmpty ? p.id : 'proof_${DateTime.now().microsecondsSinceEpoch}',
        document: p.document?.copyWith(localUri: remoteUrl) ?? IdProofDocument(
          filename: 'proof',
          mimeType: 'image/jpeg',
          sizeBytes: 0,
          localUri: remoteUrl,
        ),
      ));
    }

    final locUrl = customer.locationUrl ?? (customer.location != null ? 'https://maps.google.com/?q=${customer.location!.lat},${customer.location!.lng}' : null);

    await _client.from('customers').update({
      'name': customer.name,
      'phone': customer.phone,
      'alternate_phone': customer.alternatePhone,
      'address': customer.address,
      'landmark': customer.landmark,
      'profile_url': remoteProfileUrl,
      'location_url': locUrl,
      'latitude': customer.location?.lat,
      'longitude': customer.location?.lng,
      'weekday_id': customer.weekdayId,
      'place_id': customer.placeId,
      'area_id': customer.areaId,
      'status': customer.status,
      'dob': customer.dob,
      'occupation': customer.occupation,
      'notes': customer.notes,
      'nominees': customer.nominees.map((n) => n.toJson()).toList(),
      'id_proofs': uploadedProofs.map((p) => p.toJson()).toList(),
    }).eq('id', customer.id);
  }

  @override
  Future<void> undoCustomer(String customerId) async {
    await _client.from('customers').delete().eq('id', customerId);
  }
}

class SupabaseRouteRepository implements RouteRepository {
  final _client = Supabase.instance.client;
  final _local = LocalSqliteRouteRepository();

  @override
  Future<List<Weekday>> getWeekdays() async {
    try {
      final maps = await _client.from('weekdays').select().order('sort_order');
      return maps.map((w) => Weekday.fromJson({
        'id': w['id'],
        'name': w['name'],
        'sortOrder': w['sort_order'],
      })).toList();
    } catch (_) {
      return await _local.getWeekdays();
    }
  }

  @override
  Stream<List<Weekday>> watchWeekdays() {
    final controller = StreamController<List<Weekday>>();
    StreamSubscription? localSub;
    StreamSubscription? remoteSub;

    localSub = _local.watchWeekdays().listen((data) {
      if (!controller.isClosed) controller.add(data);
    });

    try {
      remoteSub = _client.from('weekdays').stream(primaryKey: ['id']).order('sort_order').listen(
        (list) {
          if (!controller.isClosed && list.isNotEmpty) {
            controller.add(list.map((w) => Weekday.fromJson({
              'id': w['id'],
              'name': w['name'],
              'sortOrder': w['sort_order'],
            })).toList());
          }
        },
        onError: (_) {},
        cancelOnError: false,
      );
    } catch (_) {}

    controller.onCancel = () {
      localSub?.cancel();
      remoteSub?.cancel();
    };

    return controller.stream;
  }

  @override
  Future<List<Place>> getPlacesByWeekday(String weekdayId) async {
    final places = await SupabaseConfigRepository().getPlaces();
    return places.where((p) => p.weekdayId == weekdayId).toList();
  }

  @override
  Stream<List<Place>> watchPlacesByWeekday(String weekdayId) {
    return SupabaseConfigRepository().watchPlaces().map(
      (places) => places.where((p) => p.weekdayId == weekdayId).toList()
    );
  }

  @override
  Future<List<Area>> getAreasByPlace(String placeId) async {
    final areas = await SupabaseConfigRepository().getAreas();
    return areas.where((a) => a.placeId == placeId).toList();
  }

  @override
  Stream<List<Area>> watchAreasByPlace(String placeId) {
    return SupabaseConfigRepository().watchAreas().map(
      (areas) => areas.where((a) => a.placeId == placeId).toList()
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
    final configRepo = SupabaseConfigRepository();
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
  Future<Area> addArea({required String placeId, required String name}) async {
    final configRepo = SupabaseConfigRepository();
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
  Future<List<Collection>> getAllCollections() async {
    final maps = await _client.from('collections').select().order('visit_datetime');
    return maps.map((c) => Collection.fromJson({
      'id': c['id'],
      'customerId': c['customer_id'],
      'visitDatetime': c['visit_datetime'],
      'status': c['status'],
      'amount': c['amount'],
      'reason': c['reason'],
      'collectedBy': c['collected_by'],
    })).toList();
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
    required double amount,
    String? reason,
    required String collectedBy,
    DateTime? customDate,
  }) async {
    final date = customDate ?? DateTime.now();
    await _client.from('collections').insert({
      'id': UuidUtils.generate(),
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
      (list) => list.map((s) {
        final remarks = s['remarks'] as String?;
        final isLend = remarks != null && remarks.startsWith('LEND_DETAILS:');
        final saleType = isLend ? 'LEND' : s['sale_type'];
        return Sale.fromJson({
          'id': s['id'],
          'customerId': s['customer_id'],
          'saleDatetime': s['sale_datetime'],
          'saleType': saleType,
          'totalAmount': s['total_amount'],
          'advanceAmount': s['advance_amount'],
          'financedAmount': s['financed_amount'],
          'soldBy': s['sold_by'],
          'remarks': remarks,
        });
      }).toList()
    );
  }

  @override
  Future<List<Sale>> getAllSales() async {
    final maps = await _client.from('sales').select().order('sale_datetime');
    return maps.map((s) {
      final remarks = s['remarks'] as String?;
      final isLend = remarks != null && remarks.startsWith('LEND_DETAILS:');
      final saleType = isLend ? 'LEND' : s['sale_type'];

      return Sale.fromJson({
        'id': s['id'],
        'customerId': s['customer_id'],
        'saleDatetime': s['sale_datetime'],
        'saleType': saleType,
        'totalAmount': s['total_amount'],
        'advanceAmount': s['advance_amount'],
        'financedAmount': s['financed_amount'],
        'soldBy': s['sold_by'],
        'remarks': remarks,
      });
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
    final saleId = UuidUtils.generate();
    final date = customDate ?? DateTime.now();

    int totalAmount = 0;
    if (lendAmount != null) {
      totalAmount = lendAmount;
    } else {
      for (var item in items) {
        totalAmount += (item['quantity'] as int) * (item['unitPrice'] as int);
      }
    }
    totalAmount = totalAmount - discount + creditCharge;
    final financedAmount = totalAmount - advanceAmount;
    final saleType = lendAmount != null ? 'LEND' : (financedAmount == 0 ? 'READY' : 'CREDIT');

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
        'id': UuidUtils.generate(),
        'sale_id': saleId,
        'product_id': productId,
        'quantity': qty,
        'unit_price': unitPrice,
        'total_price': qty * unitPrice,
      });

      await _client.from('inventory_transactions').insert({
        'id': UuidUtils.generate(),
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

    final channel = _client.channel('products_stock_${DateTime.now().microsecondsSinceEpoch}')
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

    controller.onCancel = () async {
      await channel.unsubscribe();
      await _client.removeChannel(channel);
      await controller.close();
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
    final productId = UuidUtils.generate();

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
        'id': UuidUtils.generate(),
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

class SupabaseConfigRepository implements ConfigRepository {
  final _client = Supabase.instance.client;
  final _local = LocalSqliteConfigRepository();

  Future<String> _readData(String id) async {
    try {
      final res = await _client.from('config').select('data').eq('id', id).maybeSingle();
      if (res != null && res['data'] != null) {
        final encoded = jsonEncode(res['data']);
        await _local.writeData(id, encoded);
        return encoded;
      }
    } catch (_) {
      // Offline / network failure -> safe fallback to local SQLite cache
    }
    return await _local.readData(id);
  }

  Future<void> _writeData(String id, String dataJson) async {
    await _local.writeData(id, dataJson);
    try {
      final decoded = jsonDecode(dataJson);
      await _client.from('config').upsert({'id': id, 'data': decoded});
    } catch (_) {
      // Offline -> safe local-first write
    }
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
    final controller = StreamController<List<Place>>();
    StreamSubscription? localSub;
    StreamSubscription? remoteSub;

    localSub = _local.watchPlaces().listen((data) {
      if (!controller.isClosed) controller.add(data);
    });

    try {
      remoteSub = _client.from('config').stream(primaryKey: ['id']).eq('id', 'places').listen(
        (list) async {
          if (list.isNotEmpty && list.first['data'] is List) {
            final data = list.first['data'] as List;
            final places = data.map((item) {
              final map = Map<String, dynamic>.from(item as Map);
              if (map.containsKey('weekday_id')) {
                map['weekdayId'] = map['weekday_id'];
              }
              return Place.fromJson(map);
            }).toList();
            await _local.savePlaces(places);
          }
        },
        onError: (_) {
          // Supabase offline / SocketException -> continue serving local SQLite data
        },
        cancelOnError: false,
      );
    } catch (_) {}

    controller.onCancel = () {
      localSub?.cancel();
      remoteSub?.cancel();
    };

    return controller.stream;
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
    final controller = StreamController<List<Area>>();
    StreamSubscription? localSub;
    StreamSubscription? remoteSub;

    localSub = _local.watchAreas().listen((data) {
      if (!controller.isClosed) controller.add(data);
    });

    try {
      remoteSub = _client.from('config').stream(primaryKey: ['id']).eq('id', 'areas').listen(
        (list) async {
          if (list.isNotEmpty && list.first['data'] is List) {
            final data = list.first['data'] as List;
            final areas = data.map((item) {
              final map = Map<String, dynamic>.from(item as Map);
              if (map.containsKey('place_id')) {
                map['placeId'] = map['place_id'];
              }
              return Area.fromJson(map);
            }).toList();
            await _local.saveAreas(areas);
          }
        },
        onError: (_) {
          // Supabase offline / SocketException -> continue serving local SQLite data
        },
        cancelOnError: false,
      );
    } catch (_) {}

    controller.onCancel = () {
      localSub?.cancel();
      remoteSub?.cancel();
    };

    return controller.stream;
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
    final controller = StreamController<List<Category>>();
    StreamSubscription? localSub;
    StreamSubscription? remoteSub;

    localSub = _local.watchCategories().listen((data) {
      if (!controller.isClosed) controller.add(data);
    });

    try {
      remoteSub = _client.from('config').stream(primaryKey: ['id']).eq('id', 'categories').listen(
        (list) async {
          if (list.isNotEmpty && list.first['data'] is List) {
            final data = list.first['data'] as List;
            final categories = data.map((item) => Category.fromJson(item as Map<String, dynamic>)).toList();
            await _local.saveCategories(categories);
          }
        },
        onError: (_) {
          // Supabase offline / SocketException -> continue serving local SQLite data
        },
        cancelOnError: false,
      );
    } catch (_) {}

    controller.onCancel = () {
      localSub?.cancel();
      remoteSub?.cancel();
    };

    return controller.stream;
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
    final controller = StreamController<List<String>>();
    StreamSubscription? localSub;
    StreamSubscription? remoteSub;

    localSub = _local.watchBrands().listen((data) {
      if (!controller.isClosed) controller.add(data);
    });

    try {
      remoteSub = _client.from('config').stream(primaryKey: ['id']).eq('id', 'brands').listen(
        (list) async {
          if (list.isNotEmpty && list.first['data'] is List) {
            final data = list.first['data'] as List;
            final brands = data.map((item) => item as String).toList();
            await _local.saveBrands(brands);
          }
        },
        onError: (_) {
          // Supabase offline / SocketException -> continue serving local SQLite data
        },
        cancelOnError: false,
      );
    } catch (_) {}

    controller.onCancel = () {
      localSub?.cancel();
      remoteSub?.cancel();
    };

    return controller.stream;
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
    final controller = StreamController<List<String>>();
    StreamSubscription? localSub;
    StreamSubscription? remoteSub;

    localSub = _local.watchProofTypes().listen((data) {
      if (!controller.isClosed) controller.add(data);
    });

    try {
      remoteSub = _client.from('config').stream(primaryKey: ['id']).eq('id', 'proof_types').listen(
        (list) async {
          if (list.isNotEmpty && list.first['data'] is List) {
            final data = list.first['data'] as List;
            final proofTypes = data.map((item) => item as String).toList();
            await _local.saveProofTypes(proofTypes);
          }
        },
        onError: (_) {
          // Supabase offline / SocketException -> continue serving local SQLite data
        },
        cancelOnError: false,
      );
    } catch (_) {}

    controller.onCancel = () {
      localSub?.cancel();
      remoteSub?.cancel();
    };

    return controller.stream;
  }

  @override
  Future<void> saveProofTypes(List<String> proofTypes) async {
    final raw = jsonEncode(proofTypes);
    await _writeData('proof_types', raw);
  }
}
