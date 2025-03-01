import 'package:flutter/material.dart';
import 'package:image_manager/config/theme.config.dart';

class Avatar extends StatelessWidget {
  final String? avatarId;
  final double size;
  final Color? borderColor;
  final double borderWidth;
  final List<Color>? gradientColors;
  final bool isOnline;

  const Avatar({
    Key? key,
    this.avatarId,
    this.size = 40.0,
    this.borderColor,
    this.borderWidth = 1,
    this.gradientColors,
    this.isOnline = false,
  }) : super(key: key);

  String _getAvatarPath() {
    if (avatarId == null || avatarId!.isEmpty) {
      return 'assets/avatars/default.png';
    }
    return 'assets/avatars/$avatarId.png';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: gradientColors != null
                ? LinearGradient(
                    colors: gradientColors!,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            border: Border.all(
              color: borderColor ?? AppTheme.primaryLight,
              width: borderWidth,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              _getAvatarPath(),
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Image.asset(
                'assets/avatars/default.png',
                width: size,
                height: size,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        if (isOnline)
          Positioned(
            right: 2,
            bottom: 2,
            child: Container(
              width: size * 0.2,
              height: size * 0.2,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
