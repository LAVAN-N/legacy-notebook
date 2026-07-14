import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/router/routes.dart';
import '../../data/models/customer.dart';
import '../../data/repositories/customer_repository.dart';
import '../../data/providers.dart';
import '../../data/mock/mock_data.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/empty_state.dart';

class ClientsScreen extends ConsumerStatefulWidget {
  const ClientsScreen({super.key});

  @override
  ConsumerState<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends ConsumerState<ClientsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    
    // In a real app we'd have a dedicated controller for this screen to fetch 
    // all customers and compute outstanding. Since we are using mock data directly
    // for this quick implementation, we can read it from the provider.
    final repo = ref.watch(customerRepositoryProvider);
    
    return AppScaffold(
      title: Text('Clients', style: AppTypography.headlineMedium.copyWith(color: colors.foreground)),
      body: FutureBuilder<List<Customer>>(
        // For the sake of the mock, we fetch all
        future: Future.value(mockCustomersList), 
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          List<Customer> allCustomers = snapshot.data ?? [];
          
          // Filter logic
          var filtered = allCustomers.where((c) {
            final q = _searchQuery.toLowerCase();
            final matchesSearch = c.name.toLowerCase().contains(q) || c.phone.contains(q) || c.address.toLowerCase().contains(q);
            
            if (!matchesSearch) return false;
            if (_selectedFilter == 'All') return true;
            if (_selectedFilter == 'Has outstanding') {
              // we don't have outstanding data immediately available on customer object unless we join sales/collections.
              // For UI demonstration, we'll just show them all.
              return true;
            }
            // Weekday filter
            // Here we'd map weekdayId to actual name, but we skip for brevity
            return true;
          }).toList();

          return Column(
            children: [
              // Search
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by name, phone, or address',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
              ),
              
              // Filters
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Row(
                  children: ['All', 'Has outstanding', 'Monday', 'Thursday'].map((filter) {
                    final isSelected = _selectedFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        label: Text(filter),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) setState(() => _selectedFilter = filter);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              
              // List
              Expanded(
                child: filtered.isEmpty 
                    ? const EmptyState(
                        title: 'No clients found',
                        message: 'Try adjusting your search or filters.',
                        icon: Icons.people_outline,
                      )
                    : ListView.separated(
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final c = filtered[index];
                          // Dummy outstanding calculation for UI
                          final out = index % 2 == 0 ? 150000 : 0;
                          
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: colors.primary.withOpacity(0.1),
                              child: Text(
                                c.name.substring(0, 1).toUpperCase(),
                                style: TextStyle(color: colors.primary),
                              ),
                            ),
                            title: Text(c.name, style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w600)),
                            subtitle: Text('Place ${c.placeId} · Area ${c.areaId}', style: AppTypography.labelSmall.copyWith(color: colors.mutedFg)),
                            trailing: Text(
                              rupees(out),
                              style: AppTypography.currencySmall.copyWith(
                                color: out > 0 ? colors.danger : colors.mutedFg,
                              ),
                            ),
                            onTap: () {
                              context.push(Routes.customer('Monday', c.placeId, c.areaId, c.id));
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
