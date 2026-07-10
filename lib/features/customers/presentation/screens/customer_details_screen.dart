import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:legacy_notebook/core/constants/app_spacing.dart';
import 'package:legacy_notebook/shared/models/customer_model.dart';
import 'package:legacy_notebook/shared/providers/mock_providers.dart';
import 'package:legacy_notebook/shared/widgets/states/error_state.dart';
import 'package:legacy_notebook/shared/widgets/states/loading_state.dart';
import 'package:url_launcher/url_launcher.dart';

extension _ColorExtension on Color {
  Color withOpacityValue(double opacity) {
    return withValues(alpha: opacity);
  }
}

/// Customer details screen with multi-tab interface
class CustomerDetailsScreen extends ConsumerWidget {
  final String? weekdayId;
  final String? placeId;
  final String? areaId;
  final String customerId;

  const CustomerDetailsScreen({
    this.weekdayId,
    this.placeId,
    this.areaId,
    required this.customerId,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customerAsync = ref.watch(mockCustomersProvider).whenData(
          (customers) => customers.firstWhere(
            (c) => c.id == customerId,
            orElse: () => throw Exception('Customer not found'),
          ),
        );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Details'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              showMenu(
                context: context,
                position: const RelativeRect.fromLTRB(100, 80, 0, 0),
                items: [
                  const PopupMenuItem(child: Text('Edit')),
                  const PopupMenuItem(child: Text('Delete')),
                  const PopupMenuItem(child: Text('Share')),
                ],
              );
            },
          ),
        ],
      ),
      body: customerAsync.when(
        loading: () => const Center(
          child: LoadingState(itemCount: 3, isVertical: true),
        ),
        error: (err, stack) => Center(
          child: ErrorState(
            headline: 'Customer not found',
            message: err.toString(),
            onRetryPressed: () {},
          ),
        ),
        data: (customer) => _buildCustomerDetailsView(context, ref, customer),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showQuickCollectDialog(context);
        },
        child: const Icon(Icons.check_circle),
      ),
    );
  }

  Widget _buildCustomerDetailsView(
    BuildContext context,
    WidgetRef ref,
    CustomerModel customer,
  ) {
    return DefaultTabController(
      length: 5,
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  // Header: Identity section
                  _buildIdentityHeader(context, customer),
                  const SizedBox(height: AppSpacing.md),

                  // Outstanding card
                  _buildOutstandingCard(context, customer),
                  const SizedBox(height: AppSpacing.lg),

                  // Tab bar
                  Material(
                    color: Theme.of(context).colorScheme.surface,
                    child: TabBar(
                      tabs: const [
                        Tab(text: 'Personal'),
                        Tab(text: 'Address'),
                        Tab(text: 'GPS'),
                        Tab(text: 'Nominees'),
                        Tab(text: 'Proofs'),
                      ],
                      indicatorColor: Theme.of(context).colorScheme.primary,
                      labelColor: Theme.of(context).colorScheme.primary,
                      unselectedLabelColor:
                          Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          children: [
            _buildPersonalInfoTab(context, customer),
            _buildAddressTab(context, customer),
            _buildGpsTab(context, customer),
            _buildNomineesTab(context, customer),
            _buildProofsTab(context, customer),
          ],
        ),
      ),
    );
  }

  Widget _buildIdentityHeader(BuildContext context, CustomerModel customer) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          // Avatar
          CircleAvatar(
            radius: 40,
            backgroundColor: _getAvatarColor(customer.id),
            child: Text(
              customer.initials,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Name and code
          Text(
            customer.name,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            customer.code,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Status badge
          _buildStatusBadge(context, customer.status),
          const SizedBox(height: AppSpacing.md),

          // Phone
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () async {
                final phoneUrl = Uri(scheme: 'tel', path: customer.phone);
                if (await canLaunchUrl(phoneUrl)) {
                  await launchUrl(phoneUrl);
                }
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.phone,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      customer.phone,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutstandingCard(BuildContext context, CustomerModel customer) {
    final lastVisitDate = customer.lastVisit != null
        ? DateFormat('dd MMM yyyy').format(customer.lastVisit!)
        : 'Never';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer.withOpacityValue(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withOpacityValue(0.2),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            // Outstanding amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Outstanding Amount',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                Text(
                  '₹${_formatAmount(customer.outstanding)}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: customer.outstanding > 0
                            ? Theme.of(context).colorScheme.error
                            : Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Last visit
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Last Visit',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                Text(
                  lastVisitDate,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Collection status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Collection Status',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                _buildStatusBadge(context, customer.status),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoTab(BuildContext context, CustomerModel customer) {
    String dob = 'Not provided';
    if (customer.dob != null) {
      try {
        dob = DateFormat('dd MMM yyyy').format(customer.dob!);
      } catch (e) {
        dob = 'Invalid date';
      }
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        _buildInfoSection(context, 'First Name', customer.firstName),
        _buildInfoSection(context, 'Full Name', customer.name),
        _buildInfoSection(context, 'Code', customer.code),
        _buildInfoSection(context, 'Phone', customer.phone),
        _buildInfoSection(context, 'Alternate Phone', customer.alternatePhone ?? 'N/A'),
        _buildInfoSection(context, 'Date of Birth', dob),
        _buildInfoSection(context, 'Occupation', customer.occupation ?? 'N/A'),
        _buildInfoSection(context, 'Guardian Name', customer.guardianName ?? 'N/A'),
      ],
    );
  }

  Widget _buildAddressTab(BuildContext context, CustomerModel customer) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        _buildInfoSection(context, 'Address', customer.address),
        _buildInfoSection(context, 'Landmark', customer.landmark ?? 'Not provided'),
        const SizedBox(height: AppSpacing.lg),
        ElevatedButton.icon(
          onPressed: () async {
            if (customer.gps.isNotEmpty) {
              final lat = customer.gps['latitude'] ?? 0;
              final lng = customer.gps['longitude'] ?? 0;
              final mapsUrl = 'https://maps.google.com/?q=$lat,$lng';
              if (await canLaunchUrl(Uri.parse(mapsUrl))) {
                await launchUrl(Uri.parse(mapsUrl));
              }
            }
          },
          icon: const Icon(Icons.map),
          label: const Text('Open in Maps'),
        ),
      ],
    );
  }

  Widget _buildGpsTab(BuildContext context, CustomerModel customer) {
    String gpsText = 'Not available';
    if (customer.gps.isNotEmpty) {
      final lat = customer.gps['latitude'] ?? 0;
      final lng = customer.gps['longitude'] ?? 0;
      gpsText = '$lat, $lng';
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'GPS Coordinates',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                gpsText,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontFamily: 'monospace',
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        ElevatedButton.icon(
          onPressed: () async {
            if (customer.gps.isNotEmpty) {
              final lat = customer.gps['latitude'] ?? 0;
              final lng = customer.gps['longitude'] ?? 0;
              final mapsUrl = 'https://maps.google.com/?q=$lat,$lng';
              if (await canLaunchUrl(Uri.parse(mapsUrl))) {
                await launchUrl(Uri.parse(mapsUrl));
              }
            }
          },
          icon: const Icon(Icons.navigation),
          label: const Text('Navigate'),
        ),
      ],
    );
  }

  Widget _buildNomineesTab(BuildContext context, CustomerModel customer) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text(
          'Nominees',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'No nominees added',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildProofsTab(BuildContext context, CustomerModel customer) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text(
          'Proof Documents',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'No proof documents added',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  void _showQuickCollectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quick Collection'),
        content: const Text('Enter collection amount'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Collection saved')),
              );
            },
            child: const Text('Save'),
          ),
        ],
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
