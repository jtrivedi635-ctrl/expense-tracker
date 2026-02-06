import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/expense_model.dart';
import '../providers/theme_provider.dart';

class AllExpensesScreen extends StatelessWidget {
  const AllExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        title: const Text('All Expenses'),
        backgroundColor: themeProvider.backgroundColor,
        elevation: 0,
      ),
      body: ValueListenableBuilder<Box<ExpenseModel>>(
        valueListenable: Hive.box<ExpenseModel>('expenses').listenable(),
        builder: (context, box, _) {
          if (box.values.isEmpty) {
            return Center(
              child: Text(
                'No expenses yet.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            );
          }

          final sortedExpenses = box.values.toList()
            ..sort((a, b) => b.date.compareTo(a.date));

          return ListView.builder(
            itemCount: sortedExpenses.length,
            itemBuilder: (context, index) {
              final expense = sortedExpenses[index];
              return ListTile(
                leading: _getCategoryIcon(expense.category),
                title: Text(expense.title),
                subtitle: Text(DateFormat.yMMMd().format(expense.date)),
                trailing: Text(
                  '-₹${expense.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: expense.isExpense ? Colors.red : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _getCategoryIcon(String category) {
    switch (category) {
      case 'Food':
        return const Icon(Icons.fastfood);
      case 'Transport':
        return const Icon(Icons.directions_car);
      case 'Shopping':
        return const Icon(Icons.shopping_bag);
      case 'Bills':
        return const Icon(Icons.receipt);
      case 'Entertainment':
        return const Icon(Icons.movie);
      case 'Health':
        return const Icon(Icons.local_hospital);
      case 'Education':
        return const Icon(Icons.school);
      default:
        return const Icon(Icons.category);
    }
  }
}
