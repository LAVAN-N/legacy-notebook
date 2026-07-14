import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/customer.dart';
import '../../data/models/place.dart';
import '../../data/models/area.dart';
import '../../data/models/weekday.dart';
import '../../data/repositories/customer_repository.dart';
import '../../data/repositories/route_repository.dart';
import '../../data/providers.dart';
import '../dashboard/controllers/dashboard_controller.dart';

class NewClientFormState {
  NewClientFormState({
    this.weekdayId = '',
    this.selectedWeekday = '',
    this.placeId = '',
    this.areaId = '',
    this.name = '',
    this.phone = '',
    this.alternatePhone = '',
    this.address = '',
    this.landmark = '',
    this.nomineeName = '',
    this.nomineeRelation = '',
    this.idProofType = '',
    this.idProofNumber = '',
    this.openingBalance = 0,
    this.visitTime = 'Anytime',
    this.smsReminders = true,
    this.errors = const {},
    this.places = const [],
    this.areas = const [],
    this.isLoading = false,
  });

  final String weekdayId;
  final String selectedWeekday;
  final String placeId;
  final String areaId;
  final String name;
  final String phone;
  final String alternatePhone;
  final String address;
  final String landmark;
  final String nomineeName;
  final String nomineeRelation;
  final String idProofType;
  final String idProofNumber;
  final int openingBalance;
  final String visitTime;
  final bool smsReminders;
  final Map<String, String> errors;
  final List<Place> places;
  final List<Area> areas;
  final bool isLoading;

  NewClientFormState copyWith({
    String? weekdayId,
    String? selectedWeekday,
    String? placeId,
    String? areaId,
    String? name,
    String? phone,
    String? alternatePhone,
    String? address,
    String? landmark,
    String? nomineeName,
    String? nomineeRelation,
    String? idProofType,
    String? idProofNumber,
    int? openingBalance,
    String? visitTime,
    bool? smsReminders,
    Map<String, String>? errors,
    List<Place>? places,
    List<Area>? areas,
    bool? isLoading,
  }) {
    return NewClientFormState(
      weekdayId: weekdayId ?? this.weekdayId,
      selectedWeekday: selectedWeekday ?? this.selectedWeekday,
      placeId: placeId ?? this.placeId,
      areaId: areaId ?? this.areaId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      alternatePhone: alternatePhone ?? this.alternatePhone,
      address: address ?? this.address,
      landmark: landmark ?? this.landmark,
      nomineeName: nomineeName ?? this.nomineeName,
      nomineeRelation: nomineeRelation ?? this.nomineeRelation,
      idProofType: idProofType ?? this.idProofType,
      idProofNumber: idProofNumber ?? this.idProofNumber,
      openingBalance: openingBalance ?? this.openingBalance,
      visitTime: visitTime ?? this.visitTime,
      smsReminders: smsReminders ?? this.smsReminders,
      errors: errors ?? this.errors,
      places: places ?? this.places,
      areas: areas ?? this.areas,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class NewClientController extends StateNotifier<NewClientFormState> {
  NewClientController({
    required this.customerRepo,
    required this.routeRepo,
    required this.ref,
  }) : super(NewClientFormState()) {
    _initialize();
  }

  final CustomerRepository customerRepo;
  final RouteRepository routeRepo;
  final StateNotifierProviderRef ref;

  Future<void> _initialize() async {
    // Initialize with today's weekday
    final now = DateTime.now();
    final weekdayNames = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    final todayName = weekdayNames[now.weekday % 7];
    
    final weekdayId = getWeekdayIdByName(todayName);
    state = state.copyWith(selectedWeekday: todayName, weekdayId: weekdayId);
    
    await setWeekday(weekdayId, todayName);
  }

  String getWeekdayIdByName(String name) {
    // Map weekday name to ID
    final map = {
      'Monday': 'w-1',
      'Tuesday': 'w-2',
      'Wednesday': 'w-3',
      'Thursday': 'w-4',
      'Friday': 'w-5',
      'Saturday': 'w-6',
      'Sunday': 'w-7',
    };
    return map[name] ?? 'w-1';
  }

  Future<void> setWeekday(String weekdayId, String weekdayName) async {
    state = state.copyWith(
      weekdayId: weekdayId,
      selectedWeekday: weekdayName,
      placeId: '',
      areaId: '',
      areas: const [],
      errors: {},
    );
    
    final places = await routeRepo.getPlacesByWeekday(weekdayId);
    state = state.copyWith(places: places);
  }

  Future<void> setPlace(String placeId) async {
    state = state.copyWith(placeId: placeId, areaId: '', errors: {});
    
    final areas = await routeRepo.getAreasByPlace(placeId);
    state = state.copyWith(areas: areas);
  }

  void setArea(String areaId) {
    state = state.copyWith(areaId: areaId, errors: {});
  }

  void setName(String name) {
    state = state.copyWith(name: name, errors: {});
  }

  void setPhone(String phone) {
    // Live format: remove non-digits, then format as "98765 43210"
    final cleaned = phone.replaceAll(RegExp(r'\D'), '');
    String formatted = cleaned;
    if (cleaned.length >= 5) {
      formatted = '${cleaned.substring(0, cleaned.length - 5)} ${cleaned.substring(cleaned.length - 5)}';
    }
    state = state.copyWith(phone: formatted, errors: {});
  }

  void setAlternatePhone(String phone) {
    state = state.copyWith(alternatePhone: phone, errors: {});
  }

  void setAddress(String address) {
    state = state.copyWith(address: address, errors: {});
  }

  void setLandmark(String landmark) {
    state = state.copyWith(landmark: landmark, errors: {});
  }

  void setNomineeName(String name) {
    state = state.copyWith(nomineeName: name);
  }

  void setNomineeRelation(String relation) {
    state = state.copyWith(nomineeRelation: relation);
  }

  void setIdProofType(String type) {
    state = state.copyWith(idProofType: type);
  }

  void setIdProofNumber(String number) {
    state = state.copyWith(idProofNumber: number);
  }

  void setOpeningBalance(int amount) {
    state = state.copyWith(openingBalance: amount, errors: {});
  }

  void setVisitTime(String time) {
    state = state.copyWith(visitTime: time);
  }

  void toggleSmsReminders(bool value) {
    state = state.copyWith(smsReminders: value);
  }

  Future<Place?> addNewPlace(String placeName) async {
    if (placeName.isEmpty || state.weekdayId.isEmpty) return null;
    
    try {
      final newPlace = await routeRepo.addPlace(
        weekdayId: state.weekdayId,
        name: placeName,
      );
      
      final updated = [...state.places, newPlace];
      state = state.copyWith(places: updated);
      return newPlace;
    } catch (e) {
      return null;
    }
  }

  Future<Area?> addNewArea(String areaName) async {
    if (areaName.isEmpty || state.placeId.isEmpty) return null;
    
    try {
      final newArea = await routeRepo.addArea(
        placeId: state.placeId,
        name: areaName,
      );
      
      final updated = [...state.areas, newArea];
      state = state.copyWith(areas: updated);
      return newArea;
    } catch (e) {
      return null;
    }
  }

  Map<String, String> _validate() {
    final errors = <String, String>{};

    // Route placement
    if (state.weekdayId.isEmpty) {
      errors['weekday'] = 'Please select a weekday';
    }
    if (state.placeId.isEmpty) {
      errors['place'] = 'Please select a place';
    }
    if (state.areaId.isEmpty) {
      errors['area'] = 'Please select an area';
    }

    // Customer details
    if (state.name.isEmpty) {
      errors['name'] = 'Name is required';
    } else if (state.name.length > 80) {
      errors['name'] = 'Name must be ≤ 80 characters';
    }

    if (state.phone.isEmpty) {
      errors['phone'] = 'Phone is required';
    } else {
      final cleaned = state.phone.replaceAll(RegExp(r'\D'), '');
      if (!RegExp(r'^[6-9]\d{9}$').hasMatch(cleaned)) {
        errors['phone'] = 'Phone must be 10 digits, starting with 6-9';
      }
    }

    if (state.address.isEmpty) {
      errors['address'] = 'Address is required';
    } else if (state.address.length > 240) {
      errors['address'] = 'Address must be ≤ 240 characters';
    }

    // Opening balance
    if (state.openingBalance < 0) {
      errors['openingBalance'] = 'Opening balance cannot be negative';
    } else if (state.openingBalance > 1000000) {
      errors['openingBalance'] = 'Opening balance cannot exceed ₹10,00,000';
    }

    return errors;
  }

  Future<Customer?> createAndSale() async {
    final errors = _validate();
    if (errors.isNotEmpty) {
      state = state.copyWith(errors: errors);
      return null;
    }

    state = state.copyWith(isLoading: true);

    try {
      final customer = await customerRepo.addCustomer(
        name: state.name,
        phone: state.phone.replaceAll(RegExp(r'\D'), ''),
        alternatePhone: state.alternatePhone.isNotEmpty ? state.alternatePhone : null,
        address: state.address,
        landmark: state.landmark.isNotEmpty ? state.landmark : null,
        weekdayId: state.weekdayId,
        placeId: state.placeId,
        areaId: state.areaId,
        notes: state.nomineeName.isNotEmpty
            ? 'Nominee: ${state.nomineeName} (${ state.nomineeRelation})'
            : null,
        openingBalance: state.openingBalance,
      );

      state = state.copyWith(isLoading: false);
      
      // Invalidate dashboard controller to refresh data
      ref.invalidate(dashboardControllerProvider);
      
      return customer;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errors: {'submit': e.toString()},
      );
      return null;
    }
  }

  Future<Customer?> createOnly() async {
    final errors = _validate();
    if (errors.isNotEmpty) {
      state = state.copyWith(errors: errors);
      return null;
    }

    state = state.copyWith(isLoading: true);

    try {
      final customer = await customerRepo.addCustomer(
        name: state.name,
        phone: state.phone.replaceAll(RegExp(r'\D'), ''),
        alternatePhone: state.alternatePhone.isNotEmpty ? state.alternatePhone : null,
        address: state.address,
        landmark: state.landmark.isNotEmpty ? state.landmark : null,
        weekdayId: state.weekdayId,
        placeId: state.placeId,
        areaId: state.areaId,
        notes: state.nomineeName.isNotEmpty
            ? 'Nominee: ${state.nomineeName} (${state.nomineeRelation})'
            : null,
        openingBalance: state.openingBalance,
      );

      state = state.copyWith(isLoading: false);
      
      // Invalidate dashboard controller to refresh data
      ref.invalidate(dashboardControllerProvider);
      
      return customer;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errors: {'submit': e.toString()},
      );
      return null;
    }
  }

  void saveFormState() {
    // Preserve form state for UNDO (state is already preserved by StateNotifier)
  }

  void resetForm() {
    state = NewClientFormState();
    _initialize();
  }

  bool get isDirty {
    return state.name.isNotEmpty ||
        state.phone.isNotEmpty ||
        state.address.isNotEmpty ||
        state.placeId.isNotEmpty ||
        state.openingBalance > 0;
  }
}

final newClientControllerProvider = StateNotifierProvider<NewClientController, NewClientFormState>((ref) {
  final customerRepo = ref.watch(customerRepositoryProvider);
  final routeRepo = ref.watch(routeRepositoryProvider);
  
  return NewClientController(
    customerRepo: customerRepo,
    routeRepo: routeRepo,
    ref: ref,
  );
});
