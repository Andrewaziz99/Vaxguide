import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vaxguide/core/blocs/vaccine/vaccine_search_cubit.dart';
import 'package:vaxguide/core/blocs/vaccine/vaccine_search_states.dart';
import 'package:vaxguide/core/constants/strings.dart';
import 'package:vaxguide/core/models/vaccine_model.dart';
import 'package:vaxguide/core/styles/colors.dart';
import 'package:vaxguide/modules/VaccineSearch/vaccine_detail_screen.dart';
import 'package:vaxguide/shared/widgets.dart';

class VaccineSearchScreen extends StatelessWidget {
  const VaccineSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => VaccineSearchCubit()..fetchVaccines(),
      child: const _VaccineSearchBody(),
    );
  }
}

class _VaccineSearchBody extends StatefulWidget {
  const _VaccineSearchBody();

  @override
  State<_VaccineSearchBody> createState() => _VaccineSearchBodyState();
}

class _VaccineSearchBodyState extends State<_VaccineSearchBody> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterSheet(BuildContext context) {
    final cubit = VaccineSearchCubit.get(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        String? tempAge = cubit.selectedAgeGroup;
        String? tempDisease = cubit.selectedDisease;
        String? tempManufacturer = cubit.selectedManufacturer;

        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                  decoration: BoxDecoration(
                    color: fischerBlue900.withValues(alpha: 0.85),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    border: Border(
                      top: BorderSide(
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Handle bar
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Title row
                      Row(
                        children: [
                          const Icon(
                            Icons.filter_list_rounded,
                            color: fischerBlue100,
                            size: 24,
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            vaccineFilterTitle,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Alexandria',
                            ),
                          ),
                          const Spacer(),
                          if (tempAge != null ||
                              tempDisease != null ||
                              tempManufacturer != null)
                            TextButton(
                              onPressed: () {
                                setSheetState(() {
                                  tempAge = null;
                                  tempDisease = null;
                                  tempManufacturer = null;
                                });
                              },
                              child: const Text(
                                vaccineFilterClearAll,
                                style: TextStyle(
                                  color: red300,
                                  fontSize: 13,
                                  fontFamily: 'Alexandria',
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // ── Age Group Filter ──
                      _FilterSection(
                        title: vaccineFilterByAge,
                        icon: Icons.child_care_rounded,
                        options: cubit.ageGroups,
                        selected: tempAge,
                        onSelected: (val) {
                          setSheetState(() => tempAge = val);
                        },
                      ),
                      const SizedBox(height: 16),

                      // ── Disease Filter ──
                      _FilterSection(
                        title: vaccineFilterByDisease,
                        icon: Icons.coronavirus_rounded,
                        options: cubit.diseases,
                        selected: tempDisease,
                        onSelected: (val) {
                          setSheetState(() => tempDisease = val);
                        },
                      ),
                      const SizedBox(height: 16),

                      // ── Manufacturer Filter ──
                      _FilterSection(
                        title: vaccineFilterByManufacturer,
                        icon: Icons.factory_rounded,
                        options: cubit.manufacturers,
                        selected: tempManufacturer,
                        onSelected: (val) {
                          setSheetState(() => tempManufacturer = val);
                        },
                      ),
                      const SizedBox(height: 24),

                      // Apply button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            cubit.filterByAgeGroup(tempAge);
                            cubit.filterByDisease(tempDisease);
                            cubit.filterByManufacturer(tempManufacturer);
                            Navigator.pop(sheetContext);
                          },
                          icon: const Icon(Icons.check_rounded),
                          label: const Text(
                            vaccineFilterApply,
                            style: TextStyle(
                              fontFamily: 'Alexandria',
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: fischerBlue100,
                            foregroundColor: fischerBlue900,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Search Bar + Filter Button ──
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Row(
            children: [
              // Search field
              Expanded(
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Alexandria',
                    fontSize: 15,
                  ),
                  decoration: InputDecoration(
                    hintText: vaccineSearchHint,
                    hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontFamily: 'Alexandria',
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: fischerBlue100,
                    ),
                    suffixIcon: ValueListenableBuilder<TextEditingValue>(
                      valueListenable: _searchController,
                      builder: (_, value, __) {
                        if (value.text.isEmpty) return const SizedBox.shrink();
                        return IconButton(
                          icon: const Icon(
                            Icons.close_rounded,
                            color: Colors.white70,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            VaccineSearchCubit.get(context).searchVaccines('');
                          },
                        );
                      },
                    ),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.08),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: fischerBlue100),
                    ),
                  ),
                  onChanged: (query) {
                    VaccineSearchCubit.get(context).searchVaccines(query);
                  },
                ),
              ),
              const SizedBox(width: 10),

              // Filter button
              BlocBuilder<VaccineSearchCubit, VaccineSearchStates>(
                builder: (context, state) {
                  final cubit = VaccineSearchCubit.get(context);
                  return GestureDetector(
                    onTap: () => _showFilterSheet(context),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: cubit.hasActiveFilters
                            ? fischerBlue100.withValues(alpha: 0.2)
                            : Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: cubit.hasActiveFilters
                              ? fischerBlue100
                              : Colors.white.withValues(alpha: 0.12),
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            Icons.filter_list_rounded,
                            color: cubit.hasActiveFilters
                                ? fischerBlue100
                                : Colors.white70,
                            size: 24,
                          ),
                          // Active filter indicator dot
                          if (cubit.hasActiveFilters)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: fischerBlue100,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        // ── Active Filter Chips ──
        BlocBuilder<VaccineSearchCubit, VaccineSearchStates>(
          builder: (context, state) {
            final cubit = VaccineSearchCubit.get(context);
            if (!cubit.hasActiveFilters) return const SizedBox(height: 8);

            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    if (cubit.selectedAgeGroup != null)
                      _ActiveFilterChip(
                        label: cubit.selectedAgeGroup!,
                        icon: Icons.child_care_rounded,
                        onRemove: () => cubit.filterByAgeGroup(null),
                      ),
                    if (cubit.selectedDisease != null)
                      _ActiveFilterChip(
                        label: cubit.selectedDisease!,
                        icon: Icons.coronavirus_rounded,
                        onRemove: () => cubit.filterByDisease(null),
                      ),
                    if (cubit.selectedManufacturer != null)
                      _ActiveFilterChip(
                        label: cubit.selectedManufacturer!,
                        icon: Icons.factory_rounded,
                        onRemove: () => cubit.filterByManufacturer(null),
                      ),
                    // Clear all chip
                    Padding(
                      padding: const EdgeInsetsDirectional.only(start: 6),
                      child: ActionChip(
                        label: const Text(
                          vaccineFilterClearAll,
                          style: TextStyle(
                            color: red300,
                            fontSize: 12,
                            fontFamily: 'Alexandria',
                          ),
                        ),
                        backgroundColor: red500.withValues(alpha: 0.12),
                        side: BorderSide(color: red500.withValues(alpha: 0.3)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        onPressed: () {
                          _searchController.clear();
                          cubit.clearFilters();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 8),

        // ── Results ──
        Expanded(
          child: BlocBuilder<VaccineSearchCubit, VaccineSearchStates>(
            builder: (context, state) {
              if (state is VaccineSearchLoadingState) {
                return const Center(
                  child: CircularProgressIndicator(color: fischerBlue100),
                );
              }

              if (state is VaccineSearchErrorState) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          color: red500,
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          vaccineSearchError,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'Alexandria',
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton.icon(
                          onPressed: () {
                            VaccineSearchCubit.get(context).fetchVaccines();
                          },
                          icon: const Icon(
                            Icons.refresh_rounded,
                            color: fischerBlue100,
                          ),
                          label: const Text(
                            vaccineSearchRetry,
                            style: TextStyle(
                              color: fischerBlue100,
                              fontFamily: 'Alexandria',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (state is VaccineSearchEmptyState) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          color: Colors.white.withValues(alpha: 0.4),
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          vaccineSearchNoResults,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 16,
                            fontFamily: 'Alexandria',
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final cubit = VaccineSearchCubit.get(context);
              final vaccines = cubit.filteredVaccines;

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                itemCount: vaccines.length,
                itemBuilder: (context, index) {
                  return _VaccineCard(vaccine: vaccines[index]);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Active Filter Chip ──
class _ActiveFilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onRemove;

  const _ActiveFilterChip({
    required this.label,
    required this.icon,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 6),
      child: Chip(
        avatar: Icon(icon, color: fischerBlue900, size: 16),
        label: Text(
          label,
          style: const TextStyle(
            color: fischerBlue900,
            fontSize: 12,
            fontFamily: 'Alexandria',
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        deleteIcon: const Icon(
          Icons.close_rounded,
          size: 16,
          color: Colors.white70,
        ),
        onDeleted: onRemove,
        backgroundColor: fischerBlue100,
        side: BorderSide(color: fischerBlue100.withValues(alpha: 0.3)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}

// ── Filter Section in Bottom Sheet ──
class _FilterSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<String> options;
  final String? selected;
  final ValueChanged<String?> onSelected;

  const _FilterSection({
    required this.title,
    required this.icon,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: fischerBlue100, size: 18),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                color: fischerBlue100,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontFamily: 'Alexandria',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 36,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: options.length + 1, // +1 for "All" chip
            itemBuilder: (context, index) {
              if (index == 0) {
                final isSelected = selected == null;
                return Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: ChoiceChip(
                    label: Text(
                      vaccineFilterAll,
                      style: TextStyle(
                        fontFamily: 'Alexandria',
                        fontSize: 12,
                        color: isSelected ? fischerBlue900 : Colors.black,
                      ),
                    ),
                    selected: isSelected,
                    showCheckmark: false,
                    selectedColor: fischerBlue100.withValues(alpha: 0.25),
                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                    side: BorderSide(
                      color: isSelected
                          ? fischerBlue100
                          : Colors.white.withValues(alpha: 0.15),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    onSelected: (_) => onSelected(null),
                  ),
                );
              }

              final option = options[index - 1];
              final isSelected = selected == option;

              return Padding(
                padding: const EdgeInsetsDirectional.only(end: 8),
                child: ChoiceChip(
                  label: Text(
                    option,
                    style: TextStyle(
                      fontFamily: 'Alexandria',
                      fontSize: 12,
                      color: isSelected ? fischerBlue900 : Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  selected: isSelected,
                  showCheckmark: false,
                  selectedColor: fischerBlue100.withValues(alpha: 0.25),
                  backgroundColor: Colors.white.withValues(alpha: 0.08),
                  side: BorderSide(
                    color: isSelected
                        ? fischerBlue100
                        : Colors.white.withValues(alpha: 0.15),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  onSelected: (_) => onSelected(isSelected ? null : option),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Vaccine Card ──
class _VaccineCard extends StatelessWidget {
  final VaccineModel vaccine;

  const _VaccineCard({required this.vaccine});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => navigateTo(context, VaccineDetailScreen(vaccine: vaccine)),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
              ),
              child: Row(
                children: [
                  // Vaccine icon
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: fischerBlue100.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.vaccines_rounded,
                      color: fischerBlue100,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Text content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vaccine.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Alexandria',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (vaccine.disease.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.coronavirus_rounded,
                                size: 14,
                                color: fischerBlue100,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  vaccine.disease,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white.withValues(alpha: 0.7),
                                    fontFamily: 'Alexandria',
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (vaccine.manufacturer.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(
                                Icons.factory_rounded,
                                size: 14,
                                color: fischerBlue100,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  vaccine.manufacturer,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withValues(alpha: 0.5),
                                    fontFamily: 'Alexandria',
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Arrow
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white.withValues(alpha: 0.3),
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
