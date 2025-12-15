import 'package:flutter/material.dart';

class CertivaLogo extends StatelessWidget {
  final double? size;
  final Color? textColor;
  final Color? iconColor;

  const CertivaLogo({
    Key? key,
    this.size,
    this.textColor,
    this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final logoSize = size ?? 120.0;
    final textColorValue = textColor ?? const Color(0xFF09D5D6);
    final iconColorValue = iconColor ?? const Color(0xFFB47EDB);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo principal "Certiva"
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Letras antes de la 'i'
            Text(
              'Cert',
              style: TextStyle(
                fontSize: logoSize * 0.3,
                fontWeight: FontWeight.bold,
                color: textColorValue,
              ),
            ),
            // Icono de tubo de ensayo sobre la 'i'
            Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  'i',
                  style: TextStyle(
                    fontSize: logoSize * 0.3,
                    fontWeight: FontWeight.bold,
                    color: textColorValue,
                  ),
                ),
                Positioned(
                  top: -logoSize * 0.05,
                  child: Container(
                    width: logoSize * 0.15,
                    height: logoSize * 0.2,
                    decoration: BoxDecoration(
                      color: iconColorValue,
                      borderRadius: BorderRadius.circular(logoSize * 0.075),
                    ),
                    child: Center(
                      child: Container(
                        width: logoSize * 0.08,
                        height: logoSize * 0.12,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(logoSize * 0.04),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Letras después de la 'i'
            Text(
              'va',
              style: TextStyle(
                fontSize: logoSize * 0.3,
                fontWeight: FontWeight.bold,
                color: textColorValue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        // Texto "LABORATORIOS"
        Text(
          'LABORATORIOS',
          style: TextStyle(
            fontSize: logoSize * 0.12,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
} 