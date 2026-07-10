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

/// Customers list screen - shows all customers for a selected area
class CustomersScreen extends ConsumerWidget {
  final String weekdayId;
  final String placeId;
  final String areaId;

  const CustomersScreen({
    required this.weekdayId,
    required this.placeId,
    required this.areaId,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customersAsync = ref.watch(mockCustomersByAreaProvider(areaId));
    final areasAsync = ref.watch(mockAreasProvider);

    // Get the area name for the app bar
    final areaName = areasAsync.whenData((areas) {
      try {
        return areas.firstWhere((a) => a.id == areaId).name;
      } catch (e) {
        return 'Customers';
      }
    }).value ?? 'Customers';

    return Scaffold(
      appBar: AppBar(
        title: Text('$areaName - Customers'),
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
            onRetryPressed: () => ref.refresh(mockCustomersByAreaProvider(areaId)),
          ),
        ),
        data: (customers) {
          if (customers.isEmpty) {
            return const Center(
              child: EmptyState(
                headline: 'No customers found',
                subtext: 'This area has no customers assigned.',
                icon: Icons.person_outline,
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await Future.delayed(const Duration(milliseconds: 400));
              return ref.refresh(mockCustomersByAreaProvider(areaId).future);
            },
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: customers.length,
              separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                final customer = customers[index];
                return _buildSwipeableCustomerCard(context, customer);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildSwipeableCustomerCard(BuildContext context, CustomerModel customer) {
    return Dismissible(
      key: ValueKey(customer.id),
      background: _buildSwipeBackground(context, 'Call', Icons.call, Colors.blue, false),
      secondaryBackground: _buildSwipeBackground(context, 'Collect', Icons.check_circle, Colors.green, true),
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          // Call action
          _handleCallAction(customer);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Opening phone...'),
              duration: const Duration(milliseconds: 800),
              backgroundColor: Colors.blue,
            ),
          );
        } else if (direction == DismissDirection.endToStart) {
          // Collect action
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Opening collection form...'),
              duration: const Duration(milliseconds: 800),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
      child: _buildCustomerCard(context, customer),
    );
  }

  Widget _buildSwipeBackground(BuildContext context, String label, IconData icon, Color color, bool isSecondary) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: isSecondary ? Alignment.centerRight : Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleCallAction(CustomerModel customer) async {
    final phoneUrl = Uri(scheme: 'tel', path: customer.phone);
    try {
      if (await canLaunchUrl(phoneUrl)) {
        await launchUrl(phoneUrl);
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Widget _buildCustomerCard(BuildContext context, CustomerModel customer) {
    return GestureDetector(
      onTap: () {
        // Navigate to customer details screen
        context.push('/routes/weekdays/$weekdayId/places/$placeId/areas/$areaId/customers/${customer.id}');
      },
      child: Container(
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
              context.push('/routes/weekdays/$weekdayId/places/$placeId/areas/$areaId/customers/${customer.id}');
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
                                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        customer.code,
                                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                              color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  customer.maskedPhone,
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                                Text(
                                  '₹${_formatAmount(customer.outstanding)}',
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                        color: customer.outstanding > 0
                                            ? Theme.of(context).colorScheme.error
                                            : Theme.of(context).colorScheme.primary,
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
                          context.push('/routes/weekdays/$weekdayId/places/$placeId/areas/$areaId/customers/${customer.id}');
                        },
                      ),
                    ],
                  ),
                ],
              ),
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
