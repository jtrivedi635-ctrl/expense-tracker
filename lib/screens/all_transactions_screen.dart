import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import '../models/expense_model.dart';
import '../providers/theme_provider.dart';

class AllTransactionsScreen extends StatefulWidget {
  const AllTransactionsScreen({super.key});

  @override
  State<AllTransactionsScreen> createState() => _AllTransactionsScreenState();
}

class _AllTransactionsScreenState extends State<AllTransactionsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  String _selectedFilter = 'All'; // All, Expense, Income
  String _selectedCategory = 'All';
  String _searchQuery = '';

  final List<String> _filters = ['All', 'Expense', 'Income'];
  final List<String> _categories = [
    'All',
    'Food',
    'Transport',
    'Shopping',
    'Bills',
    'Entertainment',
    'Health',
    'Education',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _triggerHaptic() {
    HapticFeedback.lightImpact();
  }

  List<ExpenseModel> _filterTransactions(List<ExpenseModel> transactions) {
    return transactions.where((transaction) {
      // Filter by type
      bool matchesType =
          _selectedFilter == 'All' ||
          (_selectedFilter == 'Expense' && transaction.isExpense) ||
          (_selectedFilter == 'Income' && !transaction.isExpense);

      // Filter by category
      bool matchesCategory =
          _selectedCategory == 'All' ||
          transaction.category == _selectedCategory;

      // Filter by search query
      bool matchesSearch =
          _searchQuery.isEmpty ||
          transaction.title.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          transaction.category.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );

      return matchesType && matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: themeProvider.backgroundGradient,
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // Custom App Bar
                _buildAppBar(themeProvider),

                // Search Bar
                _buildSearchBar(themeProvider),

                // Filter Chips

                // Category Filter
                _buildCategoryFilter(themeProvider),

                // Transactions List
                Expanded(child: _buildTransactionsList(themeProvider)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(ThemeProvider themeProvider) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              _triggerHaptic();
              Navigator.pop(context);
            },
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: themeProvider.glassmorphicColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: themeProvider.borderColor, width: 1),
              ),
              child: Icon(
                Icons.arrow_back,
                color: themeProvider.textColor,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'All Transactions',
                  style: TextStyle(
                    color: themeProvider.textColor,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                ValueListenableBuilder<Box<ExpenseModel>>(
                  valueListenable: Hive.box<ExpenseModel>(
                    'expense_box',
                  ).listenable(),
                  builder: (context, box, _) {
                    return Text(
                      '${box.values.length} transactions',
                      style: TextStyle(
                        color: themeProvider.secondaryTextColor,
                        fontSize: 14,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ThemeProvider themeProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: themeProvider.inputColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: themeProvider.borderColor, width: 1),
        ),
        child: TextField(
          style: TextStyle(color: themeProvider.textColor),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          decoration: InputDecoration(
            hintText: 'Search transactions...',
            hintStyle: TextStyle(color: themeProvider.mutedForegroundColor),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: themeProvider.mutedForegroundColor,
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: themeProvider.mutedForegroundColor,
                    ),
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                  )
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter(ThemeProvider themeProvider) {
    return Padding(
      // Added margin from top
      padding: const EdgeInsets.only(top: 20),
      child: SizedBox(
        height: 50,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final category = _categories[index];
            final isSelected = _selectedCategory == category;

            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: () {
                  _triggerHaptic();
                  setState(() {
                    _selectedCategory = category;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? themeProvider.primaryColor
                        : themeProvider.glassmorphicColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? themeProvider.primaryColor.withValues(alpha: 0.5)
                          : themeProvider.borderColor,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      if (category != 'All')
                        Text(
                          _getCategoryEmoji(category),
                          style: const TextStyle(fontSize: 18),
                        ),
                      if (category != 'All') const SizedBox(width: 6),
                      Text(
                        category,
                        style: TextStyle(
                          color: isSelected
                              ? themeProvider.primaryForegroundColor
                              : themeProvider.textColor,
                          fontSize: 14,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTransactionsList(ThemeProvider themeProvider) {
    return ValueListenableBuilder<Box<ExpenseModel>>(
      valueListenable: Hive.box<ExpenseModel>('expense_box').listenable(),
      builder: (context, box, _) {
        if (box.values.isEmpty) {
          return _buildEmptyState(themeProvider);
        }

        final sortedExpenses = box.values.toList()
          ..sort((a, b) => b.date.compareTo(a.date));

        final filteredExpenses = _filterTransactions(sortedExpenses);

        if (filteredExpenses.isEmpty) {
          return _buildNoResultsState(themeProvider);
        }

        return FadeTransition(
          opacity: _fadeAnimation,
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            itemCount: filteredExpenses.length,
            itemBuilder: (context, index) {
              return _buildTransactionItem(
                filteredExpenses[index],
                themeProvider,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(ThemeProvider themeProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: themeProvider.mutedForegroundColor,
          ),
          const SizedBox(height: 16),
          Text(
            'No Transactions Yet',
            style: TextStyle(
              color: themeProvider.textColor,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first transaction to get started',
            style: TextStyle(
              color: themeProvider.secondaryTextColor,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState(ThemeProvider themeProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: themeProvider.mutedForegroundColor,
          ),
          const SizedBox(height: 16),
          Text(
            'No Results Found',
            style: TextStyle(
              color: themeProvider.textColor,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters',
            style: TextStyle(
              color: themeProvider.secondaryTextColor,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(
    ExpenseModel transaction,
    ThemeProvider themeProvider,
  ) {
    final categoryStyle = _getCategoryStyle(transaction.category);
    final isExpense = transaction.isExpense;

    return Dismissible(
      key: Key(transaction.id),
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: themeProvider.destructiveColor,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.centerRight,
        child: Icon(Icons.delete, color: themeProvider.primaryForegroundColor),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        _triggerHaptic();
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: themeProvider.cardColor,
            title: Text(
              'Delete Transaction',
              style: TextStyle(color: themeProvider.textColor),
            ),
            content: Text(
              'Are you sure you want to delete this transaction?',
              style: TextStyle(color: themeProvider.secondaryTextColor),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: themeProvider.textColor),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  'Delete',
                  style: TextStyle(color: themeProvider.destructiveColor),
                ),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        final box = Hive.box<ExpenseModel>('expense_box');
        box.delete(transaction.id);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: themeProvider.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: themeProvider.borderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: themeProvider.isDarkMode
                  ? Colors.black.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    (categoryStyle['color'] as Color).withValues(alpha: 0.3),
                    (categoryStyle['color'] as Color).withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                categoryStyle['emoji'] as String,
                style: const TextStyle(fontSize: 24),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.title,
                    style: TextStyle(
                      color: themeProvider.textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        transaction.category,
                        style: TextStyle(
                          color: themeProvider.mutedForegroundColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: themeProvider.mutedForegroundColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Text(
                        _formatDate(transaction.date),
                        style: TextStyle(
                          color: themeProvider.mutedForegroundColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Text(
               '-₹${transaction.amount.toStringAsFixed(0)}',
              style: TextStyle(
                color: themeProvider.destructiveColor,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getCategoryStyle(String category) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    switch (category) {
      case 'Food':
        return {'emoji': '🍔', 'color': themeProvider.destructiveColor};
      case 'Transport':
        return {'emoji': '🚗', 'color': themeProvider.primaryColor};
      case 'Shopping':
        return {'emoji': '🛍️', 'color': themeProvider.warningColor};
      case 'Bills':
        return {'emoji': '💡', 'color': themeProvider.accentBackgroundColor};
      case 'Entertainment':
        return {'emoji': '🎮', 'color': themeProvider.secondaryColor};
      case 'Health':
        return {'emoji': '💊', 'color': themeProvider.successColor};
      case 'Education':
        return {'emoji': '📚', 'color': themeProvider.primaryColor};
      default:
        return {'emoji': '📦', 'color': themeProvider.mutedColor};
    }
  }

  String _getCategoryEmoji(String category) {
    final style = _getCategoryStyle(category);
    return style['emoji'] as String;
  }

  String _formatDate(DateTime date) {
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
}
