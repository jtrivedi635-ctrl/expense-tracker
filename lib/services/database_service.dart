import 'package:hive_flutter/hive_flutter.dart';
import '../models/expense_model.dart';

class DatabaseService {
  static const String _expensesBox = 'expenses';
  static const String _budgetBox = 'budget';

  // Initialize Hive
  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ExpenseModelAdapter());
    }
    
    // Open boxes
    await Hive.openBox<ExpenseModel>(_expensesBox);
    await Hive.openBox(_budgetBox);
  }

  // Get expenses box
  static Box<ExpenseModel> get expensesBox => Hive.box<ExpenseModel>(_expensesBox);
  
  // Get budget box
  static Box get budgetBox => Hive.box(_budgetBox);

  // Add expense
  static Future<void> addExpense(ExpenseModel expense) async {
    await expensesBox.put(expense.id, expense);
  }

  // Get all expenses
  static List<ExpenseModel> getAllExpenses() {
    return expensesBox.values.toList();
  }

  // Get expenses sorted by date (newest first)
  static List<ExpenseModel> getExpensesSorted() {
    final expenses = getAllExpenses();
    expenses.sort((a, b) => b.date.compareTo(a.date));
    return expenses;
  }

  // Get expenses for current month
  static List<ExpenseModel> getCurrentMonthExpenses() {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    return expensesBox.values.where((expense) {
      return expense.date.isAfter(firstDayOfMonth.subtract(const Duration(days: 1))) &&
          expense.date.isBefore(lastDayOfMonth.add(const Duration(days: 1)));
    }).toList();
  }

  // Delete expense
  static Future<void> deleteExpense(String id) async {
    await expensesBox.delete(id);
  }

  // Update expense
  static Future<void> updateExpense(ExpenseModel expense) async {
    await expensesBox.put(expense.id, expense);
  }

  // Get total expenses for current month
  static double getTotalExpenses() {
    final currentMonthExpenses = getCurrentMonthExpenses();
    return currentMonthExpenses
        .where((e) => e.isExpense)
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

  // Get total income for current month
  static double getTotalIncome() {
    final currentMonthExpenses = getCurrentMonthExpenses();
    return currentMonthExpenses
        .where((e) => !e.isExpense)
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

  // Get expenses by category
  static Map<String, double> getExpensesByCategory() {
    final currentMonthExpenses = getCurrentMonthExpenses();
    final Map<String, double> categoryTotals = {};

    for (var expense in currentMonthExpenses) {
      if (expense.isExpense) {
        categoryTotals[expense.category] = 
            (categoryTotals[expense.category] ?? 0) + expense.amount;
      }
    }

    return categoryTotals;
  }

  // Budget methods
  static Future<void> setMonthlyBudget(double budget) async {
    await budgetBox.put('monthlyBudget', budget);
  }

  static double getMonthlyBudget() {
    return budgetBox.get('monthlyBudget', defaultValue: 50000.0);
  }

  static Future<void> setCategoryBudget(String category, double budget) async {
    final categoryBudgets = getCategoryBudgets();
    categoryBudgets[category] = budget;
    await budgetBox.put('categoryBudgets', categoryBudgets);
  }

  static Map<String, double> getCategoryBudgets() {
    final budgets = budgetBox.get('categoryBudgets', defaultValue: <String, double>{
      'Food': 15000.0,
      'Transport': 8000.0,
      'Shopping': 15000.0,
      'Bills': 10000.0,
      'Entertainment': 5000.0,
      'Health': 5000.0,
      'Education': 10000.0,
      'Other': 5000.0,
    });
    
    return Map<String, double>.from(budgets);
  }

  // Clear all data (for testing)
  static Future<void> clearAllData() async {
    await expensesBox.clear();
    await budgetBox.clear();
  }
}