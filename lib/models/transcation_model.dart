import 'package:hive/hive.dart';

// This line is critical! It allows the generator to create the adapter.
part 'transcation_model.g.dart';

@HiveType(typeId: 0) // Unique ID for this class
class Transaction extends HiveObject {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final DateTime date;

  @HiveField(3)
  final String category; // e.g., 'Food', 'Transport'

  String get categoryEmoji {
    switch (category) {
      case 'Food':
        return '🍔';
      case 'Transport':
        return '🚗';
      case 'Shopping':
        return '🛍️';
      case 'Bills':
        return '💡';
      case 'Entertainment':
        return '🎮';
      case 'Health':
        return '💊';
      case 'Education':
        return '📚';
      default:
        return '📦';
    }
  }

  Transaction({
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
  });
}
