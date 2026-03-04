import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vaxguide/core/blocs/vaccine/vaccine_search_cubit.dart';
import 'package:vaxguide/core/blocs/vaccine/vaccine_search_states.dart';
import 'package:vaxguide/core/constants/strings.dart';
import 'package:vaxguide/core/models/vaccine_category.dart';
import 'package:vaxguide/core/models/vaccine_model.dart';
import 'package:vaxguide/core/styles/colors.dart';
import 'package:vaxguide/modules/VaccineSearch/vaccine_detail_screen.dart';
import 'package:vaxguide/shared/widgets.dart';

class VaccineSearchScreen extends StatelessWidget {
  const VaccineSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => VaccineSearchCubit(),
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
  final _countryController = TextEditingController();

  @override
  void dispose() {
    _countryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VaccineSearchCubit, VaccineSearchStates>(
      builder: (context, state) {
        final cubit = VaccineSearchCubit.get(context);

        // ── Initial — show 4 category buttons ──
        if (state is VaccineSearchInitialState) {
          return _buildCategoriesView(context, cubit);
        }

        // ── Category selected — show subcategory dropdown ──
        if (state is VaccineCategorySelectedState) {
          return _buildSubcategoryView(context, cubit, state);
        }

        // ── Loading ──
        if (state is VaccineSearchLoadingState) {
          return _buildResultsShell(
            context,
            cubit,
            child: const Center(
              child: CircularProgressIndicator(color: fischerBlue100),
            ),
          );
        }

        // ── Error ──
        if (state is VaccineSearchErrorState) {
          return _buildResultsShell(
            context,
            cubit,
            child: Center(
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
                        if (cubit.selectedSubcategory != null) {
                          if (cubit.selectedCategory ==
                              VaccineCategory.travel) {
                            cubit.searchByCountry(cubit.selectedSubcategory!);
                          } else {
                            cubit.selectSubcategory(cubit.selectedSubcategory!);
                          }
                        }
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
            ),
          );
        }

        // ── Empty ──
        if (state is VaccineSearchEmptyState) {
          return _buildResultsShell(
            context,
            cubit,
            child: Center(
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
            ),
          );
        }

        // ── Success — show vaccine list ──
        return _buildResultsShell(
          context,
          cubit,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            itemCount: cubit.vaccines.length,
            itemBuilder: (context, index) {
              return _VaccineCard(vaccine: cubit.vaccines[index]);
            },
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════
  // ── Categories View (4 big buttons)
  // ═══════════════════════════════════════════
  Widget _buildCategoriesView(BuildContext context, VaccineSearchCubit cubit) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Row(
            children: [
              const Icon(
                Icons.vaccines_rounded,
                color: fischerBlue100,
                size: 28,
              ),
              const SizedBox(width: 10),
              const Text(
                vaccineSearchTitle,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Alexandria',
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            vaccineSearchSubtitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 13,
              fontFamily: 'Alexandria',
            ),
          ),
          const SizedBox(height: 28),

          // Category buttons
          ...VaccineCategory.values.map(
            (cat) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _CategoryButton(
                category: cat,
                onTap: () => cubit.selectCategory(cat),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  // ── Subcategory View (dropdown + optional search)
  // ═══════════════════════════════════════════
  Widget _buildSubcategoryView(
    BuildContext context,
    VaccineSearchCubit cubit,
    VaccineCategorySelectedState state,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button + category title
          Row(
            children: [
              GestureDetector(
                onTap: () => cubit.goToCategories(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Icon(state.category.icon, color: fischerBlue100, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  state.category.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Alexandria',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Travel → country search field
          if (state.category == VaccineCategory.travel) ...[
            _buildTravelSearch(context, cubit),
          ] else ...[
            // Preschool / School / Additional → dropdown
            _buildSubcategoryDropdown(context, cubit, state),
          ],
        ],
      ),
    );
  }

  Widget _buildTravelSearch(BuildContext context, VaccineSearchCubit cubit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Country search field with autocomplete
        Autocomplete<String>(
          optionsBuilder: (textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return cubit.travelCountries;
            }
            return cubit.travelCountries.where(
              (c) => c.contains(textEditingValue.text.trim()),
            );
          },
          onSelected: (country) {
            _countryController.text = country;
            cubit.searchByCountry(country);
          },
          fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
            // Sync the internal controller
            _countryController.addListener(() {
              if (controller.text != _countryController.text) {
                controller.text = _countryController.text;
              }
            });
            return TextField(
              controller: controller,
              focusNode: focusNode,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Alexandria',
                fontSize: 15,
              ),
              decoration: InputDecoration(
                hintText: vaccineTravelSearchHint,
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontFamily: 'Alexandria',
                  fontSize: 14,
                ),
                prefixIcon: const Icon(
                  Icons.flight_rounded,
                  color: fischerBlue100,
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
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  cubit.searchByCountry(value.trim());
                }
              },
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topRight,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  margin: const EdgeInsets.only(top: 4),
                  constraints: const BoxConstraints(maxHeight: 200),
                  decoration: BoxDecoration(
                    color: fischerBlue900.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                  ),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final option = options.elementAt(index);
                      return ListTile(
                        dense: true,
                        title: Text(
                          option,
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Alexandria',
                            fontSize: 14,
                          ),
                        ),
                        onTap: () => onSelected(option),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: () {
              final text = _countryController.text.trim();
              if (text.isNotEmpty) {
                cubit.searchByCountry(text);
              }
            },
            icon: const Icon(Icons.search_rounded),
            label: const Text(
              vaccineTravelSearchButton,
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
    );
  }

  Widget _buildSubcategoryDropdown(
    BuildContext context,
    VaccineSearchCubit cubit,
    VaccineCategorySelectedState state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          vaccineSelectSubcategory,
          style: TextStyle(
            color: fischerBlue100,
            fontSize: 15,
            fontWeight: FontWeight.bold,
            fontFamily: 'Alexandria',
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
          ),
          child: DropdownButton<String>(
            value: cubit.selectedSubcategory,
            hint: Text(
              vaccineSelectSubcategory,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontFamily: 'Alexandria',
                fontSize: 14,
              ),
            ),
            isExpanded: true,
            dropdownColor: fischerBlue900.withValues(alpha: 0.95),
            underline: const SizedBox.shrink(),
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: fischerBlue100,
            ),
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Alexandria',
              fontSize: 14,
            ),
            items: state.subcategories.map((sub) {
              return DropdownMenuItem<String>(value: sub, child: Text(sub));
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                cubit.selectSubcategory(value);
              }
            },
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════
  // ── Results shell (back button + header + child)
  // ═══════════════════════════════════════════
  Widget _buildResultsShell(
    BuildContext context,
    VaccineSearchCubit cubit, {
    required Widget child,
  }) {
    final category = cubit.selectedCategory;
    final subcategory = cubit.selectedSubcategory;

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  if (category != null) {
                    cubit.selectCategory(category);
                  } else {
                    cubit.goToCategories();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              if (category != null)
                Icon(category.icon, color: fischerBlue100, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  subcategory ?? category?.label ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Alexandria',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        // Content
        Expanded(child: child),
      ],
    );
  }
}

// ═══════════════════════════════════════════
// ── Category Button Widget
// ═══════════════════════════════════════════
class _CategoryButton extends StatelessWidget {
  final VaccineCategory category;
  final VoidCallback onTap;

  const _CategoryButton({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: fischerBlue100.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(category.icon, color: fischerBlue100, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    category.label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Alexandria',
                    ),
                  ),
                ),
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
    );
  }
}

// ═══════════════════════════════════════════
// ── Vaccine Card Widget
// ═══════════════════════════════════════════
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
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (vaccine.importance.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            vaccine.importance,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.6),
                              fontFamily: 'Alexandria',
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
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
