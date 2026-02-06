import 'package:flutter/foundation.dart';
import '../models/expense_model.dart';
import '../services/database_service.dart';

class ExpenseProvider extends ChangeNotifier {
  List<ExpenseModel> _expenses = [];
  double _monthlyBudget = 50000.0;
  Map<String, double> _categoryBudgets = {};

  // Getters
  List<ExpenseModel> get expenses => _expenses;
  List<ExpenseModel> get sortedExpenses {
    final sorted = List<ExpenseModel>.from(_expenses);
    sorted.sort((a, b) => b.date.compareTo(a.date));
    return sorted;
  }

  double get monthlyBudget => _monthlyBudget;
  Map<String, double> get categoryBudgets => _categoryBudgets;

  // Calculate totals
  double get totalExpenses {
    return _expenses
        .where((e) => e.isExpense)
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

  double get totalIncome {
    return _expenses
        .where((e) => !e.isExpense)
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

  double get remaining => monthlyBudget + totalIncome - totalExpenses;

  double get percentageUsed {
    if (monthlyBudget == 0) return 0;
    return (totalExpenses / (monthlyBudget + totalIncome) * 100).clamp(0.0, 100.0);
  }

  bool get isWarning => percentageUsed >= 80;
  bool get isCritical => percentageUsed >= 90;

  // Get expenses by category
  Map<String, double> get expensesByCategory {
    final Map<String, double> categoryTotals = {};

    for (var expense in _expenses) {
      if (expense.isExpense) {
        categoryTotals[expense.category] =
            (categoryTotals[expense.category] ?? 0) + expense.amount;
      }
    }

    return categoryTotals;
  }

  // Days remaining in month
  int get daysRemaining {
    final now = DateTime.now();
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    return lastDayOfMonth.day - now.day;
  }

  // Daily average
  double get dailyAverage {
    final now = DateTime.now();
    final daysElapsed = now.day;
    if (daysElapsed == 0) return 0;
    return totalExpenses / daysElapsed;
  }

  // Projected total
  double get projectedTotal {
    final daysInMonth = DateTime(DateTime.now().year, DateTime.now().month + 1, 0).day;
    return dailyAverage * daysInMonth;
  }

  bool get willExceedBudget => projectedTotal > monthlyBudget;

  // Initialize - Load data from database
  Future<void> initialize() async {
    _expenses = DatabaseService.getCurrentMonthExpenses();
    _monthlyBudget = DatabaseService.getMonthlyBudget();
    _categoryBudgets = DatabaseService.getCategoryBudgets();
    notifyListeners();
  }

  // Add expense
  Future<bool> addExpense(ExpenseModel expense, {bool force = false}) async {
    if (expense.isExpense && totalExpenses + expense.amount > monthlyBudget + totalIncome && !force) {
      return false; // Indicates that the budget will be exceeded
    }
    await DatabaseService.addExpense(expense);
    _expenses.add(expense);
    notifyListeners();
    return true;
  }

  // Delete expense
  Future<void> deleteExpense(String id) async {
    await DatabaseService.deleteExpense(id);
    _expenses.removeWhere((expense) => expense.id == id);
    notifyListeners();
  }

  // Update expense
  Future<void> updateExpense(ExpenseModel expense) async {
    await DatabaseService.updateExpense(expense);
    final index = _expenses.indexWhere((e) => e.id == expense.id);
    if (index != -1) {
      _expenses[index] = expense;
      notifyListeners();
    }
  }

  // Update budget
  Future<void> updateMonthlyBudget(double budget) async {
    await DatabaseService.setMonthlyBudget(budget);
    _monthlyBudget = budget;
    notifyListeners();
  }

  // --- ADDED THIS METHOD TO FIX THE ERROR ---
  Future<void> setBudget(double budget) async {
    await updateMonthlyBudget(budget);
  }
  // ------------------------------------------

  // Update category budget
  Future<void> updateCategoryBudget(String category, double budget) async {
    await DatabaseService.setCategoryBudget(category, budget);
    _categoryBudgets[category] = budget;
    notifyListeners();
  }

  // Get recent transactions (last 5)
  List<ExpenseModel> get recentTransactions {
    final sorted = sortedExpenses;
    return sorted.take(5).toList();
  }

  // Get category data for UI
  List<Map<String, dynamic>> get categoryData {
    final categories = [
      {'name': 'Food', 'icon': '🍔', 'color': 0xFFff6b6b},
      {'name': 'Transport', 'icon': '🚗', 'color': 0xFF4ecdc4},
      {'name': 'Shopping', 'icon': '🛍️', 'color': 0xFFffd93d},
      {'name': 'Bills', 'icon': '💡', 'color': 0xFFa78bfa},
      {'name': 'Entertainment', 'icon': '🎮', 'color': 0xFFff9ff3},
      {'name': 'Health', 'icon': '💊', 'color': 0xFF54a0ff},
      {'name': 'Education', 'icon': '📚', 'color': 0xFFfeca57},
      {'name': 'Other', 'icon': '📦', 'color': 0xFF95afc0},
    ];

    return categories.map((category) {
      final spent = expensesByCategory[category['name']] ?? 0.0;
      final budget = _categoryBudgets[category['name']] ?? 0.0;

      return {
        'name': category['name'],
        'icon': category['icon'],
        'color': category['color'],
        'spent': spent,
        'budget': budget,
      };
    }).toList();
  }
}