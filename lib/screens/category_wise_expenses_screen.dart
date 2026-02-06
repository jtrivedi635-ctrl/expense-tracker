import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../models/expense_model.dart';
import '../providers/theme_provider.dart';

class CategoryWiseExpensesScreen extends StatefulWidget {
  const CategoryWiseExpensesScreen({super.key});

  @override
  State<CategoryWiseExpensesScreen> createState() => _CategoryWiseExpensesScreenState();
}

class _CategoryWiseExpensesScreenState extends State<CategoryWiseExpensesScreen> {
  final Map<String, bool> _isExpanded = {};

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      body: Stack(
        children: [
          _buildAnimatedBackground(themeProvider),
          SafeArea(
            child: CustomScrollView(
              slivers: [
                _buildSliverAppBar(),
                _buildBody(themeProvider),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground(ThemeProvider theme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: theme.backgroundGradient,
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }

  SliverAppBar _buildSliverAppBar() {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      title: const Text(
        'Category-wise Expenses',
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildBody(ThemeProvider themeProvider) {
    return ValueListenableBuilder<Box<ExpenseModel>>(
      valueListenable: Hive.box<ExpenseModel>('expenses').listenable(),
      builder: (context, box, _) {
        if (box.values.isEmpty) {
          return SliverFillRemaining(
            child: Center(
              child: Text(
                'No expenses yet.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          );
        }

        final expensesByCategory = <String, List<ExpenseModel>>{};
        for (var expense in box.values) {
          if (expensesByCategory.containsKey(expense.category)) {
            expensesByCategory[expense.category]!.add(expense);
          } else {
            expensesByCategory[expense.category] = [expense];
          }
        }

        final sortedCategories = expensesByCategory.keys.toList()..sort();

        return SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final category = sortedCategories[index];
                final expenses = expensesByCategory[category]!;
                final total = expenses.fold(0.0, (sum, item) => sum + item.amount);
                final isExpanded = _isExpanded[category] ?? false;

                return _buildCategoryCard(themeProvider, category, total, expenses, isExpanded);
              },
              childCount: sortedCategories.length,
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryCard(ThemeProvider themeProvider, String category, double total, List<ExpenseModel> expenses, bool isExpanded) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          margin: const EdgeInsets.only(bottom: 15),
          decoration: BoxDecoration(
            color: themeProvider.glassmorphicColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: themeProvider.borderColor, width: 1.5),
          ),
          child: ExpansionTile(
            key: Key(category), // Ensure the state is preserved
            onExpansionChanged: (expanding) {
              setState(() {
                _isExpanded[category] = expanding;
              });
            },
            initiallyExpanded: isExpanded,
            title: Text(
              '$category - ₹${total.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            leading: _getCategoryIcon(category),
            trailing: Icon(
              isExpanded ? Icons.expand_less : Icons.expand_more,
              color: themeProvider.textColor,
            ),
            children: expenses.map((expense) => _buildTransactionItem(expense, themeProvider)).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionItem(ExpenseModel e, ThemeProvider theme) {
    final categoryStyle = _getCategoryStyle(context, e.category);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.glassmorphicColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  (categoryStyle['color'] as Color).withOpacity(0.4),
                  (categoryStyle['color'] as Color).withOpacity(0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              categoryStyle['text'],
              style: const TextStyle(fontSize: 22),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e.title,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat.yMMMd().format(e.date),
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: theme.secondaryTextColor,
                      ),
                ),
              ],
            ),
          ),
          Text(
            '-₹${e.amount.abs().toStringAsFixed(2)}',
            style: TextStyle(
              color: e.isExpense ? Colors.redAccent : Colors.greenAccent,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
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

  Map<String, dynamic> _getCategoryStyle(BuildContext context, String category) {
    final scheme = Theme.of(context).colorScheme;
    switch (category) {
      case 'Food':
        return {'text': '🍔', 'color': scheme.error};
      case 'Transport':
        return {'text': '🚗', 'color': scheme.primary};
      case 'Shopping':
        return {'text': '🛍️', 'color': scheme.secondary};
      case 'Bills':
        return {'text': '📝', 'color': scheme.tertiary};
      case 'Entertainment':
        return {'text': '🎮', 'color': scheme.secondaryContainer};
      case 'Health':
        return {'text': '💊', 'color': scheme.errorContainer};
      case 'Education':
        return {'text': '📚', 'color': scheme.primaryContainer};
      default:
        return {'text': '💰', 'color': scheme.primary};
    }
  }
}
