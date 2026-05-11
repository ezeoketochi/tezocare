import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../config/themes/app_colors.dart';

enum AvatarSize { small, medium, large, xlarge }

class AppAvatar extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final AvatarSize size;

  const AppAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.size = AvatarSize.medium,
  });

  @override
  Widget build(BuildContext context) {
    final diameter = _diameter;
    final initials = _getInitials(name);
    final colorIndex = name.hashCode.abs() % AppColors.avatarGradients.length;
    final gradientColor = AppColors.avatarGradients[colorIndex];

    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            gradientColor,
            Color.lerp(gradientColor, Colors.white, 0.3)!,
          ],
        ),
      ),
      child: ClipOval(
        child: imageUrl != null
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _buildInitials(initials),
              )
            : _buildInitials(initials),
      ),
    );
  }

  Widget _buildInitials(String initials) {
    return Center(
      child: Text(
        initials,
        style: TextStyle(
          fontSize: _fontSize,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  double get _diameter {
    switch (size) {
      case AvatarSize.small:
        return 32.r;
      case AvatarSize.medium:
        return 44.r;
      case AvatarSize.large:
        return 56.r;
      case AvatarSize.xlarge:
        return 80.r;
    }
  }

  double get _fontSize {
    switch (size) {
      case AvatarSize.small:
        return 12.sp;
      case AvatarSize.medium:
        return 16.sp;
      case AvatarSize.large:
        return 20.sp;
      case AvatarSize.xlarge:
        return 28.sp;
    }
  }
}
