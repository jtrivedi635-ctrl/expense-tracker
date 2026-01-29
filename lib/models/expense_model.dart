import 'package:hive/hive.dart';
import 'dart:ui';
part 'expense_model.g.dart';

@HiveType(typeId: 0)
class ExpenseModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  late double amount;

  @HiveField(3)
  late String category;

  @HiveField(4)
  late DateTime date;

  @HiveField(5)
  late bool isExpense;

  @HiveField(6)
  String? notes;

  ExpenseModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    required this.isExpense,
    this.notes,
  });

  // Helper method to get category emoji
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
        return '💰';
    }
  }

  // Helper method to format date
  String get formattedDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final expenseDate = DateTime(date.year, date.month, date.day);

    if (expenseDate == today) {
      return 'Today';
    } else if (expenseDate == yesterday) {
      return 'Yesterday';
    } else {
      final diff = today.difference(expenseDate).inDays;
      if (diff < 7) {
        return '$diff days ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    }
  }

  // Helper method to get time ago
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return formattedDate;
    }
  }
}