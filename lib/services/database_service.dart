import 'package:hive_flutter/hive_flutter.dart';
import '../models/expense_model.dart';

class DatabaseService {

  static const String _expensesBox = 'expense_box';
  static const String _settingsBox = 'settings_box'; 

  
  static Future<void> init() async {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ExpenseModelAdapter());
    }

   
    await Hive.openBox<ExpenseModel>(_expensesBox);
        await Hive.openBox(_settingsBox);
  }


  static Box<ExpenseModel> get expensesBox =>
      Hive.box<ExpenseModel>(_expensesBox);

  // Get settings/budget box
  static Box get settingsBox => Hive.box(_settingsBox);

 
  static Future<void> addExpense(ExpenseModel expense) async {
    await expensesBox.put(expense.id, expense);
  }

  // Get all expenses
  static List<ExpenseModel> getAllExpenses() {
    return expensesBox.values.toList();
  }

 
  static List<ExpenseModel> getExpensesSorted() {
    final expenses = getAllExpenses();
    expenses.sort((a, b) => b.date.compareTo(a.date));
    return expenses;
  }

  static List<ExpenseModel> getCurrentMonthExpenses() {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    return expensesBox.values.where((expense) {
      return expense.date.isAfter(
            firstDayOfMonth.subtract(const Duration(days: 1)),
          ) &&
          expense.date.isBefore(lastDayOfMonth.add(const Duration(days: 1)));
    }).toList();
  }

  
  static Future<void> deleteExpense(String id) async {
    await expensesBox.delete(id);
  }


  static Future<void> updateExpense(ExpenseModel expense) async {
    await expensesBox.put(expense.id, expense);
  }


  static double getTotalExpenses() {
    final currentMonthExpenses = getCurrentMonthExpenses();
    return currentMonthExpenses
        .where((e) => e.isExpense)
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }


  static double getTotalIncome() {
    final currentMonthExpenses = getCurrentMonthExpenses();
    return currentMonthExpenses
        .where((e) => !e.isExpense)
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }


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


  static Future<void> setMonthlyBudget(double budget) async {
    await settingsBox.put('monthly_budget', budget);
  }

  static double getMonthlyBudget() {
    // Default to 50000.0 if not set
    return settingsBox.get('monthly_budget', defaultValue: 50000.0);
  }

  static Future<void> setCategoryBudget(String category, double budget) async {
    final categoryBudgets = getCategoryBudgets();
    categoryBudgets[category] = budget;
    await settingsBox.put('category_budgets', categoryBudgets);
  }

  static Map<String, double> getCategoryBudgets() {
    final budgets = settingsBox.get(
      'category_budgets',
      defaultValue: <String, double>{
        'Food': 15000.0,
        'Transport': 8000.0,
        'Shopping': 15000.0,
        'Bills': 10000.0,
        'Entertainment': 5000.0,
        'Health': 5000.0,
        'Education': 10000.0,
        'Other': 5000.0,
      },
    );


    return Map<String, double>.from(budgets);
  }



  // Clear all data (for testing)
  static Future<void> clearAllData() async {
    await expensesBox.clear();
    await settingsBox.clear();
  }
}
