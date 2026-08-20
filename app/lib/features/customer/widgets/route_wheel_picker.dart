import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/weekday.dart';
import '../../../data/models/place.dart';
import '../../../data/models/area.dart';

class WheelItem {
  final String? id;
  final String name;
  const WheelItem({required this.id, required this.name});
}

class RouteWheelPicker extends StatelessWidget {
  final List<Weekday> allWeekdays;
  final List<Place> allPlaces;
  final List<Area> allAreas;
  final String? selectedWeekday;
  final String? selectedPlace;
  final String? selectedArea;
  final void Function(String? weekdayId, String? placeId, String? areaId) onSelectionChanged;

  const RouteWheelPicker({
    super.key,
    required this.allWeekdays,
    required this.allPlaces,
    required this.allAreas,
    required this.selectedWeekday,
    required this.selectedPlace,
    required this.selectedArea,
    required this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final visiblePlaces = selectedWeekday == null
        ? allPlaces
        : allPlaces.where((p) => p.weekdayId == selectedWeekday).toList();

    final visibleAreas = selectedPlace != null
        ? allAreas.where((a) => a.placeId == selectedPlace).toList()
        : (selectedWeekday != null
            ? () {
                final pIds = visiblePlaces.map((p) => p.id).toSet();
                return allAreas.where((a) => pIds.contains(a.placeId)).toList();
              }()
            : allAreas);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Column Headers
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'WEEKDAY',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: colors.mutedFg.withValues(alpha: 0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'PLACE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: colors.mutedFg.withValues(alpha: 0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'AREA',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: colors.mutedFg.withValues(alpha: 0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),

        // Time-Picker Style Wheels Container
        Container(
          height: 132,
          decoration: BoxDecoration(
            color: colors.muted.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.border.withValues(alpha: 0.5)),
          ),
          child: Stack(
            children: [
              // Central Selection Lens
              Positioned(
                top: 44,
                left: 6,
                right: 6,
                height: 44,
                child: Container(
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: colors.primary.withValues(alpha: 0.25),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colors.foreground.withValues(alpha: 0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),

              // Separator dots between the 3 columns
              Positioned(
                top: 44 + 18,
                left: 0,
                right: 0,
                child: Row(
                  children: [
                    const Spacer(flex: 1),
                    Container(
                      width: 3,
                      height: 8,
                      decoration: BoxDecoration(
                        color: colors.mutedFg.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const Spacer(flex: 1),
                    Container(
                      width: 3,
                      height: 8,
                      decoration: BoxDecoration(
                        color: colors.mutedFg.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const Spacer(flex: 1),
                  ],
                ),
              ),

              // ShaderMask for fading top and bottom edges
              ShaderMask(
                shaderCallback: (Rect bounds) {
                  return const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black,
                      Colors.black,
                      Colors.transparent,
                    ],
                    stops: [0.0, 0.22, 0.78, 1.0],
                  ).createShader(bounds);
                },
                blendMode: BlendMode.dstIn,
                child: Row(
                  children: [
                    // Column 1: Weekday
                    Expanded(
                      child: ScrollWheelColumn(
                        items: [
                          const WheelItem(id: null, name: 'Any'),
                          ...allWeekdays.map((w) => WheelItem(id: w.id, name: w.name)),
                        ],
                        selectedIndex: selectedWeekday == null
                            ? 0
                            : (allWeekdays.indexWhere((w) => w.id == selectedWeekday) + 1).clamp(0, allWeekdays.length),
                        onSelectedIndexChanged: (index) {
                          final weekdayItems = [
                            const WheelItem(id: null, name: 'Any'),
                            ...allWeekdays.map((w) => WheelItem(id: w.id, name: w.name)),
                          ];
                          final wId = weekdayItems[index].id;
                          String? newPlace = selectedPlace;
                          String? newArea = selectedArea;

                          if (newPlace != null && wId != null) {
                            final currentPlace = allPlaces.firstWhere(
                              (p) => p.id == newPlace,
                              orElse: () => const Place(id: '', weekdayId: '', name: ''),
                            );
                            if (currentPlace.weekdayId != wId) {
                              newPlace = null;
                              newArea = null;
                            }
                          }
                          onSelectionChanged(wId, newPlace, newArea);
                        },
                        colors: colors,
                      ),
                    ),

                    // Column 2: Place
                    Expanded(
                      child: ScrollWheelColumn(
                        items: [
                          const WheelItem(id: null, name: 'Any'),
                          ...visiblePlaces.map((p) => WheelItem(id: p.id, name: p.name)),
                        ],
                        selectedIndex: selectedPlace == null
                            ? 0
                            : (visiblePlaces.indexWhere((p) => p.id == selectedPlace) + 1).clamp(0, visiblePlaces.length),
                        onSelectedIndexChanged: (index) {
                          final placeItems = [
                            const WheelItem(id: null, name: 'Any'),
                            ...visiblePlaces.map((p) => WheelItem(id: p.id, name: p.name)),
                          ];
                          final pId = placeItems[index].id;
                          String? newWeekday = selectedWeekday;
                          String? newArea = selectedArea;

                          if (pId != null) {
                            final selectedP = visiblePlaces.firstWhere(
                              (p) => p.id == pId,
                              orElse: () => const Place(id: '', weekdayId: '', name: ''),
                            );
                            if (selectedP.weekdayId.isNotEmpty) {
                              newWeekday = selectedP.weekdayId;
                            }
                          }
                          if (newArea != null && pId != null) {
                            final currentArea = allAreas.firstWhere(
                              (a) => a.id == newArea,
                              orElse: () => const Area(id: '', placeId: '', name: ''),
                            );
                            if (currentArea.placeId != pId) {
                              newArea = null;
                            }
                          }
                          onSelectionChanged(newWeekday, pId, newArea);
                        },
                        colors: colors,
                      ),
                    ),

                    // Column 3: Area
                    Expanded(
                      child: ScrollWheelColumn(
                        items: [
                          const WheelItem(id: null, name: 'Any'),
                          ...visibleAreas.map((a) => WheelItem(id: a.id, name: a.name)),
                        ],
                        selectedIndex: selectedArea == null
                            ? 0
                            : (visibleAreas.indexWhere((a) => a.id == selectedArea) + 1).clamp(0, visibleAreas.length),
                        onSelectedIndexChanged: (index) {
                          final areaItems = [
                            const WheelItem(id: null, name: 'Any'),
                            ...visibleAreas.map((a) => WheelItem(id: a.id, name: a.name)),
                          ];
                          final aId = areaItems[index].id;
                          String? newWeekday = selectedWeekday;
                          String? newPlace = selectedPlace;

                          if (aId != null) {
                            final selectedA = visibleAreas.firstWhere(
                              (a) => a.id == aId,
                              orElse: () => const Area(id: '', placeId: '', name: ''),
                            );
                            newPlace = selectedA.placeId;
                            final parentPlace = allPlaces.firstWhere(
                              (p) => p.id == selectedA.placeId,
                              orElse: () => const Place(id: '', weekdayId: '', name: ''),
                            );
                            if (parentPlace.weekdayId.isNotEmpty) {
                              newWeekday = parentPlace.weekdayId;
                            }
                          }
                          onSelectionChanged(newWeekday, newPlace, aId);
                        },
                        colors: colors,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ScrollWheelColumn extends StatefulWidget {
  final List<WheelItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelectedIndexChanged;
  final AppColors colors;

  const ScrollWheelColumn({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelectedIndexChanged,
    required this.colors,
  });

  @override
  State<ScrollWheelColumn> createState() => _ScrollWheelColumnState();
}

class _ScrollWheelColumnState extends State<ScrollWheelColumn> {
  late FixedExtentScrollController _controller;
  int _lastReportedIndex = -1;

  @override
  void initState() {
    super.initState();
    final initial = widget.selectedIndex.clamp(0, widget.items.isEmpty ? 0 : widget.items.length - 1);
    _lastReportedIndex = initial;
    _controller = FixedExtentScrollController(initialItem: initial);
  }

  @override
  void didUpdateWidget(covariant ScrollWheelColumn oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex != oldWidget.selectedIndex || widget.items.length != oldWidget.items.length) {
      final target = widget.selectedIndex.clamp(0, widget.items.isEmpty ? 0 : widget.items.length - 1);
      _lastReportedIndex = target;
      if (_controller.hasClients && _controller.selectedItem != target) {
        _controller.jumpToItem(target);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListWheelScrollView.useDelegate(
      controller: _controller,
      itemExtent: 44.0,
      physics: const FixedExtentScrollPhysics(),
      perspective: 0.0001,
      diameterRatio: 50.0,
      overAndUnderCenterOpacity: 0.35,
      onSelectedItemChanged: (index) {
        if (index >= 0 && index < widget.items.length && index != _lastReportedIndex) {
          _lastReportedIndex = index;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              widget.onSelectedIndexChanged(index);
            }
          });
        }
      },
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: widget.items.length,
        builder: (context, index) {
          final isSelected = index == widget.selectedIndex;
          final item = widget.items[index];

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              _controller.animateToItem(
                index,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
              );
            },
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(
                  item.name,
                  style: TextStyle(
                    fontSize: isSelected ? 13.5 : 12.0,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? widget.colors.primary : widget.colors.foreground,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
