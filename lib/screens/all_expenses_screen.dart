import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../models/expense_model.dart';
import '../providers/theme_provider.dart';

class AllExpensesScreen extends StatelessWidget {
  const AllExpensesScreen({super.key});

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
              physics: const BouncingScrollPhysics(),
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
        'All Transactions',
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
                'No transactions yet.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          );
        }

        final sortedExpenses = box.values.toList()
          ..sort((a, b) => b.date.compareTo(a.date));

        return SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final expense = sortedExpenses[index];
                return _buildTransactionCard(context, expense, themeProvider);
              },
              childCount: sortedExpenses.length,
            ),
          ),
        );
      },
    );
  }

  Widget _buildTransactionCard(
      BuildContext context, ExpenseModel e, ThemeProvider theme) {
    final categoryStyle = _getCategoryStyle(context, e.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: theme.glassmorphicColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: theme.borderColor, width: 1),
            ),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.all(16),
              title: Row(
                children: [
                  _buildCategoryIcon(categoryStyle),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          e.title,
                          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                fontSize: 16,
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
                    '${e.isExpense ? '-' : '+'}₹${e.amount.abs().toStringAsFixed(2)}',
                    style: TextStyle(
                      color: e.isExpense ? Colors.redAccent : Colors.greenAccent,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Text(
                    e.notes ?? 'No description provided.',
                    style: TextStyle(
                      color: theme.secondaryTextColor,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryIcon(Map<String, dynamic> categoryStyle) {
    return Container(
      width: 52,
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            (categoryStyle['color'] as Color).withOpacity(0.3),
            (categoryStyle['color'] as Color).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        categoryStyle['text'],
        style: const TextStyle(fontSize: 24),
      ),
    );
  }

  Map<String, dynamic> _getCategoryStyle(
    BuildContext context,
    String category,
  ) {
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
