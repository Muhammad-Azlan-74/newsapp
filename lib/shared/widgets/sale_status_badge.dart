import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Sale Status Badge Widget
///
/// Displays a diagonal ribbon showing sale status:
/// - Red "NOT FOR SALE" ribbon if not for sale
/// - Green price badge if for sale
class SaleStatusBadge extends StatelessWidget {
  final bool isForSale;
  final double? saleAmount;

  const SaleStatusBadge({
    super.key,
    required this.isForSale,
    this.saleAmount,
  });

  @override
  Widget build(BuildContext context) {
    if (isForSale && saleAmount != null) {
      // Show green price badge for items for sale
      return Positioned(
        top: 10,
        right: -35,
        child: Transform.rotate(
          angle: math.pi / 4, // 45 degrees
          child: Container(
            width: 150,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.green.shade600,
                  Colors.green.shade700,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              '\$${saleAmount!.toStringAsFixed(0)}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                shadows: [
                  Shadow(
                    color: Colors.black45,
                    offset: Offset(1, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      // Show red "NOT FOR SALE" ribbon
      return Positioned(
        top: 10,
        right: -35,
        child: Transform.rotate(
          angle: math.pi / 4, // 45 degrees
          child: Container(
            width: 150,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.red.shade600,
                  Colors.red.shade700,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Text(
              'NOT FOR SALE',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
                shadows: [
                  Shadow(
                    color: Colors.black45,
                    offset: Offset(1, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }
}
