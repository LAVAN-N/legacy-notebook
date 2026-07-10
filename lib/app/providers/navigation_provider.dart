import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Represents the navigation path/breadcrumb state.
class NavigationState {
  final String? selectedWeekdayId;
  final String? selectedPlaceId;
  final String? selectedAreaId;

  NavigationState({
    this.selectedWeekdayId,
    this.selectedPlaceId,
    this.selectedAreaId,
  });

  NavigationState copyWith({
    String? selectedWeekdayId,
    String? selectedPlaceId,
    String? selectedAreaId,
  }) {
    return NavigationState(
      selectedWeekdayId: selectedWeekdayId ?? this.selectedWeekdayId,
      selectedPlaceId: selectedPlaceId ?? this.selectedPlaceId,
      selectedAreaId: selectedAreaId ?? this.selectedAreaId,
    );
  }

  @override
  String toString() =>
      'NavigationState(weekday: $selectedWeekdayId, place: $selectedPlaceId, area: $selectedAreaId)';
}

/// Notifier for managing navigation path state.
class NavigationNotifier extends StateNotifier<NavigationState> {
  NavigationNotifier() : super(NavigationState());

  void selectWeekday(String weekdayId) {
    state = state.copyWith(
      selectedWeekdayId: weekdayId,
      selectedPlaceId: null,
      selectedAreaId: null,
    );
  }

  void selectPlace(String placeId) {
    state = state.copyWith(
      selectedPlaceId: placeId,
      selectedAreaId: null,
    );
  }

  void selectArea(String areaId) {
    state = state.copyWith(selectedAreaId: areaId);
  }

  void reset() {
    state = NavigationState();
  }

  void goBack() {
    if (state.selectedAreaId != null) {
      state = state.copyWith(selectedAreaId: null);
    } else if (state.selectedPlaceId != null) {
      state = state.copyWith(selectedPlaceId: null);
    } else if (state.selectedWeekdayId != null) {
      state = state.copyWith(selectedWeekdayId: null);
    }
  }
}

/// Provider for navigation path/breadcrumb state.
final navigationPathProvider =
    StateNotifierProvider<NavigationNotifier, NavigationState>((ref) {
  return NavigationNotifier();
});

/// Get current breadcrumb string for display.
final breadcrumbProvider = Provider<String>((ref) {
  final nav = ref.watch(navigationPathProvider);
  final parts = <String>[];

  if (nav.selectedWeekdayId != null) {
    parts.add('Weekday');
  }
  if (nav.selectedPlaceId != null) {
    parts.add('Place');
  }
  if (nav.selectedAreaId != null) {
    parts.add('Area');
  }

  return parts.isNotEmpty ? parts.join(' › ') : 'Dashboard';
});
