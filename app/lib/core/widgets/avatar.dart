import 'package:flutter/material.dart';
import '../theme/app_typography.dart';

class Avatar extends StatelessWidget {
  const Avatar({
    super.key,
    required this.name,
    this.photoUrl,
    this.size = 44,
  });

  final String name;
  final String? photoUrl;
  final double size;

  Color _getDeterministicColor(String value) {
    if (value.isEmpty) return const Color(0xFF0F5D6B);
    final hash = value.hashCode;
    final colors = [
      const Color(0xFF0F5D6B), // deep teal
      const Color(0xFF1F8A5B), // currency green
      const Color(0xFFD98A2B), // marigold
      const Color(0xFFC0392B), // vermilion
      const Color(0xFF4A6B82), // slate
      const Color(0xFF7D4E89), // purple
    ];
    return colors[hash.abs() % colors.length];
  }

  String _getInitials(String value) {
    if (value.isEmpty) return '?';
    final parts = value.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoUrl != null && photoUrl!.isNotEmpty;
    final initials = _getInitials(name);
    final bgColor = _getDeterministicColor(name);

    return Semantics(
      label: 'Avatar of $name',
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: bgColor,
          image: hasPhoto
              ? DecorationImage(
                  image: NetworkImage(photoUrl!),
                  fit: BoxFit.cover,
                  onError: (_, __) {},
                )
              : null,
        ),
        alignment: Alignment.center,
        child: hasPhoto
            ? null
            : Text(
                initials,
                style: AppTypography.titleSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: size * 0.4,
                ),
              ),
      ),
    );
  }
}
