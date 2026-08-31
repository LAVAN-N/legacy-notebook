import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/avatar.dart';
import '../../../core/router/routes.dart';
import '../../../data/models/customer.dart';
import '../../../data/models/id_proof.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/customer_controller.dart';
import '../../dashboard/controllers/dashboard_controller.dart';

class CustomerContextCard extends ConsumerWidget {
  const CustomerContextCard({
    super.key,
    required this.customer,
    this.createdDate,
  });

  final Customer customer;
  final DateTime? createdDate;

  void _callPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');
    try {
      await launchUrl(uri);
    } catch (_) {}
  }

  String _calculateAge(String? dob) {
    if (dob == null || dob.isEmpty) return 'Not Provided';
    try {
      final normalized = dob.replaceAll('-', '/');
      final parts = normalized.split('/');
      if (parts.length == 3) {
        final day = int.tryParse(parts[0]);
        final month = int.tryParse(parts[1]);
        final year = int.tryParse(parts[2]);
        if (day != null && month != null && year != null) {
          final dobDate = DateTime(year, month, day);
          final today = DateTime.now();
          int age = today.year - dobDate.year;
          if (today.month < dobDate.month || (today.month == dobDate.month && today.day < dobDate.day)) {
            age--;
          }
          return '$age years';
        }
      }
    } catch (_) {}
    return dob;
  }



  void _openMap(double lat, double lng) async {
    final uri = Uri.parse('https://www.google.com/maps?q=$lat,$lng');
    try {
      await launchUrl(uri);
    } catch (_) {}
  }

  Color _getStatusColor(String status, AppColors colors) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return colors.success;
      case 'INACTIVE':
      case 'DO_NOT_VISIT':
        return colors.danger;
      default:
        return colors.mutedFg;
    }
  }

  String _getWeekdayNameById(String id) {
    final map = {
      'w-1': 'Monday',
      'w-2': 'Tuesday',
      'w-3': 'Wednesday',
      'w-4': 'Thursday',
      'w-5': 'Friday',
      'w-6': 'Saturday',
      'w-7': 'Sunday',
    };
    return map[id] ?? 'Monday';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final statusColor = _getStatusColor(customer.status, colors);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(color: colors.border.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header Section with Accent Background
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppRadius.lg),
                topRight: Radius.circular(AppRadius.lg),
              ),
            ),
            child: Row(
              children: [
                Avatar(name: customer.name, profileUrl: customer.profileUrl, size: 60),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.name,
                        style: AppTypography.titleLarge.copyWith(
                          color: colors.foreground,
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Text(
                            customer.customerCode,
                            style: AppTypography.bodySmall.copyWith(
                              color: colors.mutedFg,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '•',
                                style: TextStyle(color: colors.border),
                              ),
                              const SizedBox(width: 8),
                              Icon(Icons.calendar_today, size: 12, color: colors.mutedFg),
                              const SizedBox(width: 4),
                              Text(
                                _getWeekdayNameById(customer.weekdayId),
                                style: AppTypography.labelSmall.copyWith(color: colors.mutedFg),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '•',
                                style: TextStyle(color: colors.border),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                                ),
                                child: Text(
                                  customer.status.replaceAll('_', ' '),
                                  style: AppTypography.labelSmall.copyWith(
                                    color: statusColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 9,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(Icons.edit, size: 20, color: colors.primary),
                  onPressed: () async {
                    await context.push('${Routes.newClient}?source=client_card', extra: customer);
                    if (context.mounted) {
                      ref.invalidate(customerDetailControllerProvider(customer.id));
                      ref.invalidate(dashboardControllerProvider);
                    }
                  },
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 2. Personal Information Grid (Aligns with Form Data)
                _buildSectionHeader(context, 'Personal Details', Icons.person_outline),
                const SizedBox(height: AppSpacing.md),
                
                _buildInfoGrid([
                  _InfoItem(
                    label: 'Client Created Date',
                    value: createdDate != null
                        ? "${createdDate!.day.toString().padLeft(2, '0')}-${createdDate!.month.toString().padLeft(2, '0')}-${createdDate!.year}"
                        : 'Not Available',
                    icon: Icons.calendar_today_outlined,
                  ),
                  _InfoItem(
                    label: 'Age',
                    value: _calculateAge(customer.dob),
                    icon: Icons.cake_outlined,
                  ),
                  _InfoItem(
                    label: 'Occupation',
                    value: customer.occupation ?? 'Not Provided',
                    icon: Icons.work_outline,
                  ),
                  _InfoItem(
                    label: 'Route Code',
                    value: '${customer.placeId} / ${customer.areaId}',
                    icon: Icons.alt_route,
                  ),
                ], colors),
                
                const SizedBox(height: AppSpacing.lg),
                const Divider(),
                const SizedBox(height: AppSpacing.md),

                // 3. Contact & Notes Section
                _buildSectionHeader(context, 'Contact & Notes', Icons.contact_phone_outlined),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: _buildContactTile(
                        label: 'Primary Phone',
                        phone: customer.phone,
                        icon: Icons.call,
                        colors: colors,
                      ),
                    ),
                    if (customer.alternatePhone != null && customer.alternatePhone!.isNotEmpty) ...[
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _buildContactTile(
                          label: 'Alternate Phone',
                          phone: customer.alternatePhone!,
                          icon: Icons.phone_android,
                          colors: colors,
                        ),
                      ),
                    ],
                  ],
                ),
                
                if (customer.notes != null && customer.notes!.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: colors.muted.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: colors.border.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Notes',
                          style: AppTypography.labelSmall.copyWith(color: colors.mutedFg, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          customer.notes!,
                          style: AppTypography.bodySmall.copyWith(color: colors.foreground),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: AppSpacing.lg),
                const Divider(),
                const SizedBox(height: AppSpacing.md),

                // 4. Address & Geolocation Map Preview
                _buildSectionHeader(context, 'Location details', Icons.location_on_outlined),
                const SizedBox(height: AppSpacing.md),
                Text(
                  customer.address,
                  style: AppTypography.bodyMedium.copyWith(color: colors.foreground, fontWeight: FontWeight.w500),
                ),
                if (customer.landmark != null && customer.landmark!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Landmark: ${customer.landmark}',
                    style: AppTypography.bodySmall.copyWith(color: colors.mutedFg, fontStyle: FontStyle.italic),
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                
                // Map box
                if (customer.location != null)
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: colors.border.withValues(alpha: 0.5)),
                      boxShadow: [
                        BoxShadow(
                          color: colors.border.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.md)),
                          child: SizedBox(
                            width: double.infinity,
                            height: 180,
                            child: GoogleMap(
                              liteModeEnabled: true,
                              initialCameraPosition: CameraPosition(
                                target: LatLng(customer.location!.lat, customer.location!.lng),
                                zoom: 15.0,
                              ),
                              mapType: MapType.normal,
                              myLocationEnabled: false,
                              myLocationButtonEnabled: false,
                              zoomControlsEnabled: false,
                              mapToolbarEnabled: false,
                              markers: {
                                Marker(
                                  markerId: MarkerId(customer.id),
                                  position: LatLng(customer.location!.lat, customer.location!.lng),
                                  infoWindow: InfoWindow(title: customer.name),
                                ),
                              },
                              onTap: (_) => _openMap(customer.location!.lat, customer.location!.lng),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'Coordinates: ${customer.location!.lat.toStringAsFixed(5)}, ${customer.location!.lng.toStringAsFixed(5)}',
                                  style: AppTypography.labelSmall.copyWith(color: colors.mutedFg),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              TextButton.icon(
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                onPressed: () => _openMap(customer.location!.lat, customer.location!.lng),
                                icon: const Icon(Icons.directions, size: 14),
                                label: const Text('Open Maps', style: TextStyle(fontSize: 12)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: colors.muted.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: colors.border.withValues(alpha: 0.3)),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_off_outlined, size: 18, color: colors.mutedFg),
                        const SizedBox(width: 8),
                        Text(
                          'No location pinned',
                          style: AppTypography.labelMedium.copyWith(color: colors.mutedFg),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: AppSpacing.lg),
                const Divider(),
                const SizedBox(height: AppSpacing.md),

                // 5. Nominees List
                if (customer.nominees.isNotEmpty) ...[
                  _buildSectionHeader(context, 'Nominee details', Icons.people_outline),
                  const SizedBox(height: AppSpacing.md),
                  ...customer.nominees.map((n) => Card(
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                    elevation: 0,
                    color: colors.muted.withValues(alpha: 0.25),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      side: BorderSide(color: colors.border.withValues(alpha: 0.3)),
                    ),
                    child: ListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
                      leading: CircleAvatar(
                        backgroundColor: colors.primary.withValues(alpha: 0.1),
                        radius: 16,
                        child: Icon(Icons.person, size: 16, color: colors.primary),
                      ),
                      title: Text(n.name, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                      subtitle: Text('${n.relation ?? 'Nominee'}${n.phone.isNotEmpty ? ' · ${n.phone}' : ''}', style: AppTypography.labelSmall),
                      trailing: n.phone.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.phone_in_talk, size: 16),
                              onPressed: () => _callPhone(n.phone),
                              color: colors.primary,
                            )
                          : null,
                    ),
                  )),
                  const SizedBox(height: AppSpacing.md),
                ],

                // 6. ID Proofs List
                if (customer.idProofs.isNotEmpty) ...[
                  _buildSectionHeader(context, 'ID Proofs details', Icons.badge_outlined),
                  const SizedBox(height: AppSpacing.md),
                  Column(
                    children: customer.idProofs.map((p) {
                      final hasDoc = p.document != null;
                      final isImage = hasDoc && p.document!.mimeType.startsWith('image/');
                      final docUri = p.document?.localUri;
                      final String filePath = (docUri != null && docUri.startsWith('file://'))
                          ? Uri.parse(docUri).toFilePath()
                          : (docUri ?? '');

                      return Card(
                        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                        elevation: 0,
                        color: colors.muted.withValues(alpha: 0.15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          side: BorderSide(color: colors.border.withValues(alpha: 0.3)),
                        ),
                        child: Theme(
                          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            leading: Icon(
                              isImage ? Icons.image : (p.document?.mimeType == 'application/pdf' ? Icons.picture_as_pdf : Icons.badge),
                              color: colors.primary,
                            ),
                            title: Text(
                              p.type,
                              style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              hasDoc ? p.document!.filename : 'No document uploaded',
                              style: AppTypography.bodySmall.copyWith(color: colors.mutedFg),
                            ),
                            children: [
                              if (hasDoc && docUri != null)
                                Padding(
                                  padding: const EdgeInsets.all(AppSpacing.md),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [

                                      if (isImage)
                                        Container(
                                          height: 180,
                                          width: double.infinity,
                                          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                                          decoration: BoxDecoration(
                                            color: colors.muted.withValues(alpha: 0.05),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: colors.border.withValues(alpha: 0.5)),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: docUri.startsWith('http')
                                                ? Image.network(
                                                    docUri,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context, error, stackTrace) =>
                                                        _buildFilePlaceholder(colors, p.type),
                                                  )
                                                : (filePath.isNotEmpty && File(filePath).existsSync()
                                                    ? Image.file(
                                                        File(filePath),
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (context, error, stackTrace) =>
                                                            _buildFilePlaceholder(colors, p.type),
                                                      )
                                                    : _buildFilePlaceholder(colors, p.type)),
                                          ),
                                        ),
                                      if (!isImage)
                                        Row(
                                          children: [
                                            Icon(Icons.insert_drive_file, size: 36, color: colors.mutedFg),
                                            const SizedBox(width: AppSpacing.sm),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(p.document!.filename, style: AppTypography.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                                                  Text('${(p.document!.sizeBytes / 1024).toStringAsFixed(1)} KB', style: AppTypography.labelSmall.copyWith(color: colors.mutedFg)),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      const SizedBox(height: AppSpacing.sm),
                                      ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          minimumSize: const Size(double.infinity, 36),
                                          backgroundColor: colors.primary,
                                          foregroundColor: colors.primaryFg,
                                        ),
                                        onPressed: () async {
                                          try {
                                            String targetPath = filePath;
                                            if (docUri.startsWith('http')) {
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: Text('Downloading document...'),
                                                    duration: Duration(milliseconds: 800),
                                                    behavior: SnackBarBehavior.floating,
                                                  ),
                                                );
                                              }
                                              final extension = docUri.split('.').last.split('?').first;
                                              final client = HttpClient();
                                              final request = await client.getUrl(Uri.parse(docUri));
                                              final response = await request.close();
                                              if (response.statusCode != 200) {
                                                throw 'Download failed (status ${response.statusCode})';
                                              }
                                              final tempDir = await getTemporaryDirectory();
                                              final downloadedFile = File('${tempDir.path}/proof_${p.id}_temp.$extension');
                                              await response.pipe(downloadedFile.openWrite());
                                              targetPath = downloadedFile.path;
                                            }

                                            if (targetPath.isNotEmpty && File(targetPath).existsSync()) {
                                              if (Platform.isWindows) {
                                                await Process.run('explorer.exe', [targetPath]);
                                              } else if (Platform.isMacOS) {
                                                await Process.run('open', [targetPath]);
                                              } else if (Platform.isLinux) {
                                                await Process.run('xdg-open', [targetPath]);
                                              } else {
                                                final result = await OpenFilex.open(targetPath);
                                                if (result.type != ResultType.done) {
                                                  throw result.message;
                                                }
                                              }
                                            } else {
                                              if (context.mounted) {
                                                _showMockDocumentDialog(context, p);
                                              }
                                            }
                                          } catch (e) {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('Could not open document: $e'),
                                                  behavior: SnackBarBehavior.fixed,
                                                ),
                                              );
                                            }
                                          }
                                        },
                                        icon: const Icon(Icons.open_in_new, size: 14),
                                        label: const Text('Open Document', style: TextStyle(fontSize: 12)),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    final colors = context.colors;
    return Row(
      children: [
        Icon(icon, size: 18, color: colors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTypography.titleSmall.copyWith(
            color: colors.foreground,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoGrid(List<_InfoItem> items, AppColors colors) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = (constraints.maxWidth - AppSpacing.md) / 2;
        return Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: items.map((item) => SizedBox(
            width: width,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(item.icon, size: 16, color: colors.mutedFg.withValues(alpha: 0.8)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.label,
                        style: AppTypography.labelSmall.copyWith(color: colors.mutedFg, fontSize: 10),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.value,
                        style: AppTypography.bodySmall.copyWith(
                          color: colors.foreground,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )).toList(),
        );
      },
    );
  }

  Widget _buildContactTile({
    required String label,
    required String phone,
    required IconData icon,
    required AppColors colors,
  }) {
    return InkWell(
      onTap: () => _callPhone(phone),
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: colors.primary.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: colors.primary.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: colors.primary.withValues(alpha: 0.1),
              radius: 14,
              child: Icon(icon, size: 14, color: colors.primary),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTypography.labelSmall.copyWith(color: colors.mutedFg, fontSize: 9),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    phone,
                    style: AppTypography.bodySmall.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilePlaceholder(AppColors colors, String type) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.badge, size: 40, color: colors.mutedFg.withValues(alpha: 0.6)),
          const SizedBox(height: 8),
          Text(
            'Offline Mock $type Card',
            style: AppTypography.bodySmall.copyWith(
              color: colors.mutedFg,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Tap Open Document to view card details',
            style: AppTypography.labelSmall.copyWith(color: colors.mutedFg, fontSize: 10),
          ),
        ],
      ),
    );
  }

  void _showMockDocumentDialog(BuildContext context, IdProof proof) {
    final colors = context.colors;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: colors.surface,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.badge, color: colors.primary),
                      const SizedBox(width: 8),
                      Text(
                        '${proof.type} Document',
                        style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: AppSpacing.md),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colors.primary.withValues(alpha: 0.1), colors.primary.withValues(alpha: 0.02)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.primary.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'GOVERNMENT OF INDIA',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: colors.primary,
                            letterSpacing: 1.0,
                          ),
                        ),
                        Icon(Icons.shield, size: 16, color: colors.primary),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Document Type: ${proof.type}',
                      style: AppTypography.bodySmall.copyWith(color: colors.mutedFg),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      proof.proofUrl.split('/').last,
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: colors.foreground,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'HOLDER NAME',
                              style: TextStyle(fontSize: 8, color: colors.mutedFg),
                            ),
                            Text(
                              customer.name.toUpperCase(),
                              style: AppTypography.bodySmall.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colors.foreground,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: colors.success.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'VERIFIED',
                            style: TextStyle(
                              color: colors.success,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Note: This is an offline mock view of the ID proof document.',
                style: AppTypography.labelSmall.copyWith(color: colors.mutedFg),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoItem {
  final String label;
  final String value;
  final IconData icon;

  _InfoItem({
    required this.label,
    required this.value,
    required this.icon,
  });
}
