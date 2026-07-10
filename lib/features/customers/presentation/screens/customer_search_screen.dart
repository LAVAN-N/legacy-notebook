import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:legacy_notebook/core/constants/app_spacing.dart';
import 'package:legacy_notebook/shared/models/customer_model.dart';
import 'package:legacy_notebook/shared/providers/mock_providers.dart';
import 'package:legacy_notebook/shared/widgets/states/empty_state.dart';
import 'package:legacy_notebook/shared/widgets/states/error_state.dart';
import 'package:legacy_notebook/shared/widgets/states/loading_state.dart';
import 'package:url_launcher/url_launcher.dart';

extension _ColorExtension on Color {
  Color withOpacityValue(double opacity) {
    return withValues(alpha: opacity);
  }
}

/// Customer search screen with filtering, searching, and quick actions.
class CustomerSearchScreen extends ConsumerStatefulWidget {
  const CustomerSearchScreen({super.key});

  @override
  ConsumerState<CustomerSearchScreen> createState() => _CustomerSearchScreenState();
}

class _CustomerSearchScreenState extends ConsumerState<CustomerSearchScreen> {
  late TextEditingController _searchController;
  String _selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matchesFilter(CustomerModel customer) {
    final query = _searchController.text.toLowerCase();
    
    // Status filter
    if (_selectedStatus != 'all' && customer.status != _selectedStatus) {
      return false;
    }

    // Search query filter (name, code, phone)
    if (query.isEmpty) return true;
    
    return customer.name.toLowerCase().contains(query) ||
        customer.code.toLowerCase().contains(query) ||
        customer.phone.contains(query);
  }

  Future<void> _handleCallAction(CustomerModel customer) async {
    final phoneUrl = Uri(scheme: 'tel', path: customer.phone);
    try {
      if (await canLaunchUrl(phoneUrl)) {
        await launchUrl(phoneUrl);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Unable to make call'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(mockCustomersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Customer'),
        elevation: 0,
      ),
      body: customersAsync.when(
        loading: () => const Center(
          child: LoadingState(itemCount: 5, isVertical: true),
        ),
        error: (err, stack) => Center(
          child: ErrorState(
            headline: 'Failed to load customers',
            message: err.toString(),
            onRetryPressed: () => ref.refresh(mockCustomersProvider),
          ),
        ),
        data: (customers) {
          final filteredCustomers = customers.where(_matchesFilter).toList();

          return RefreshIndicator(
            onRefresh: () async {
              await Future.delayed(const Duration(milliseconds: 400));
              return ref.refresh(mockCustomersProvider.future);
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                // Search bar
                _buildSearchBar(context),
                const SizedBox(height: AppSpacing.lg),

                // Status filter chips
                _buildStatusFilterChips(context),
                const SizedBox(height: AppSpacing.lg),

                // Results
                if (filteredCustomers.isEmpty)
                  SizedBox(
                    height: 400,
                    child: EmptyState(
                      headline: 'No customers found',
                      subtext: _selectedStatus != 'all'
                          ? 'Try changing filters or search terms'
                          : 'Try searching by name, code, or phone',
                      icon: Icons.person_search_outlined,
                    ),
                  )
                else
                  Column(
                    children: [
                      Text(
                        '${filteredCustomers.length} customer${filteredCustomers.length != 1 ? 's' : ''} found',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredCustomers.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: AppSpacing.md),
                        itemBuilder: (context, index) {
                          final customer = filteredCustomers[index];
                          return _buildCustomerCard(context, customer);
                        },
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return SearchBar(
      controller: _searchController,
      onChanged: (value) {
        setState(() {});
      },
      hintText: 'Search by name, code, or phone',
      leading: Icon(
        Icons.search,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      trailing: _searchController.text.isNotEmpty
          ? [
              Material(
                color: Colors.transparent,
                child: IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                ),
              ),
            ]
          : [],
      backgroundColor: WidgetStateProperty.all(
        Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      elevation: WidgetStateProperty.all(0),
      side: WidgetStateProperty.all(
        BorderSide(
          color: Theme.of(context).colorScheme.outline,
          width: 1,
        ),
      ),
    );
  }

  Widget _buildStatusFilterChips(BuildContext context) {
    final statusOptions = [
      ('all', 'All'),
      ('collected', 'Collected'),
      ('partially_collected', 'Partial'),
      ('pending', 'Pending'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: statusOptions.map((option) {
          final (statusValue, label) = option;
          final isSelected = _selectedStatus == statusValue;

          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: FilterChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedStatus = statusValue;
                });
              },
              backgroundColor: Colors.transparent,
              selectedColor: Theme.of(context).colorScheme.primaryContainer,
              side: BorderSide(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline,
                width: 1,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCustomerCard(BuildContext context, CustomerModel customer) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacityValue(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            context.push('/search/customer/${customer.id}');
          },
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: _getAvatarColor(customer.id),
                      child: Text(
                        customer.initials,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),

                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Name and code
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      customer.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      customer.code,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              _buildStatusBadge(context, customer.status),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Phone
                          Row(
                            children: [
                              Icon(
                                Icons.phone_outlined,
                                size: 16,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                customer.maskedPhone,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Outstanding
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Outstanding',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                              Text(
                                '₹${_formatAmount(customer.outstanding)}',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: customer.outstanding > 0
                                          ? Theme.of(context).colorScheme.error
                                          : Theme.of(context)
                                              .colorScheme
                                              .primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Trailing arrow
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                // Quick action buttons
                Row(
                  children: [
                    _buildQuickActionButton(
                      context,
                      Icons.call,
                      'Call',
                      () => _handleCallAction(customer),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _buildQuickActionButton(
                      context,
                      Icons.check_circle_outline,
                      'Collect',
                      () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Opening collection form...'),
                            duration: Duration(milliseconds: 800),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _buildQuickActionButton(
                      context,
                      Icons.edit_outlined,
                      'Edit',
                      () {
                        context.push('/search/customer/${customer.id}');
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onPressed,
  ) {
    return Expanded(
      child: Material(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacityValue(0.5),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, String status) {
    final (bgColor, textColor, label) = switch (status) {
      'collected' => (
        Theme.of(context).colorScheme.primary.withOpacityValue(0.2),
        Theme.of(context).colorScheme.primary,
        'Collected',
      ),
      'partially_collected' => (
        Theme.of(context).colorScheme.tertiary.withOpacityValue(0.2),
        Theme.of(context).colorScheme.tertiary,
        'Partial',
      ),
      _ => (
        Theme.of(context).colorScheme.outline.withOpacityValue(0.2),
        Theme.of(context).colorScheme.onSurfaceVariant,
        'Pending',
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
      ),
    );
  }

  Color _getAvatarColor(String customerId) {
    final hash = customerId.hashCode;
    final colors = [
      const Color(0xFF6C5CE7),
      const Color(0xFF00B894),
      const Color(0xFFFF6B9D),
      const Color(0xFFC44569),
      const Color(0xFF74B9FF),
      const Color(0xFFFDCB6E),
    ];
    return colors[hash.abs() % colors.length];
  }

  String _formatAmount(int amount) {
    if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    }
    return amount.toString();
  }
}
