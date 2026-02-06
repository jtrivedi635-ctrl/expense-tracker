import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../services/pdf_service.dart';
import '../models/expense_model.dart';
import 'add_expense.dart';
import '../providers/theme_provider.dart';
import 'settings_screen.dart';
import '../screens/all_transactions_screen.dart';

class PremiumExpenseTracker extends StatefulWidget {
  const PremiumExpenseTracker({super.key});

  @override
  State<PremiumExpenseTracker> createState() => _PremiumExpenseTrackerState();
}

class _PremiumExpenseTrackerState extends State<PremiumExpenseTracker>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _mainController,
      curve: Curves.easeOutCubic,
    );
    _slideAnimation = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.easeOutCubic),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _mainController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkFirstLaunch();
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _triggerHaptic() {
    // Implement haptic feedback if needed
  }

  Future<void> _checkFirstLaunch() async {
    final box = Hive.box('settings_box');
    // await box.put('isFirstTime', true);

    bool isFirstTime = box.get('isFirstTime', defaultValue: true);

    if (isFirstTime) {
    
      _showSetBudgetDialog();

     
      await box.put('isFirstTime', false);
    }
  }

  void _showSetBudgetDialog() {
    final TextEditingController budgetController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        final theme = ctx.read<ThemeProvider>();
        return AlertDialog(
          backgroundColor: theme.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            'Set Monthly Budget',
            style: TextStyle(
              color: theme.textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Enter your budget goal for this month.',
                style: TextStyle(color: theme.secondaryTextColor),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: budgetController,
                keyboardType: TextInputType.number,
                style: TextStyle(
                  color: theme.textColor,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  prefixText: '₹ ',
                  hintText: 'e.g. 20000',
                  filled: true,
                  fillColor: theme.glassmorphicColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Cancel',
                style: TextStyle(color: theme.secondaryTextColor),
              ),
            ),
            TextButton(
              onPressed: () {
                final value = double.tryParse(budgetController.text);
                if (value != null && value > 0) {
                  // Save the new budget
                  context.read<ExpenseProvider>().setBudget(value);
                  Navigator.pop(ctx);
                }
              },
              child: Text(
                'Save',
                style: TextStyle(
                  color: theme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final theme = context.watch<ThemeProvider>();

    final remaining = expenseProvider.remaining;
    final percentageUsed = expenseProvider.percentageUsed;
    final isWarning = expenseProvider.isWarning;
    final isCritical = expenseProvider.isCritical;

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      body: Stack(
        children: [
          // Animated background gradient
          _buildAnimatedBackground(),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // Static App Bar
                _buildHomeAppBar(),

                // Scrollable content
                Expanded(
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.all(20),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            // Budget Overview Card
                            _buildGlassmorphicBudgetCard(
                              remaining,
                              percentageUsed,
                              isWarning,
                              isCritical,
                            ),
                            const SizedBox(height: 20),

                            // Quick Action Chips
                            _buildQuickActions(expenseProvider),
                            const SizedBox(height: 24),

                            // Recent Transactions
                            _buildEnhancedTransactions(),
                            const SizedBox(height: 100),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _mainController,
      builder: (context, child) {
        final theme = context.watch<ThemeProvider>();

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
      },
    );
  }

  Widget _buildHomeAppBar() {
    return Builder(
      builder: (context) {
        final theme = context.watch<ThemeProvider>();

        // Reuse the styled button helper for consistency
        Widget _buildStyledIconButton(IconData icon, VoidCallback onTap) {
          return GestureDetector(
            onTap: () {
              onTap();
              _triggerHaptic();
            },
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.glassmorphicColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.borderColor, width: 1),
              ),
              child: Icon(icon, color: theme.textColor, size: 22),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // 1. Left Side: Date and Title (Expanded to push buttons right)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Text(
                        DateFormat.yMMMM().format(DateTime.now()),
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).textTheme.bodyMedium!.color!.withValues(alpha: 0.5),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(-0.2, 0),
                        end: Offset.zero,
                      ).animate(_fadeAnimation),
                      child: Text(
                        'My Wallet',
                        style: Theme.of(context).textTheme.displayLarge!
                            .copyWith(
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1.5,
                              height: 1.1,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // 2. Theme Toggle Button
              _buildStyledIconButton(
                theme.isDarkMode
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded,
                () {
                  context.read<ThemeProvider>().toggleTheme();
                },
              ),

              const SizedBox(width: 8),

              // 3. Settings Button
              _buildStyledIconButton(Icons.settings_outlined, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIconButton(
    IconData icon,
    VoidCallback onTap, {
    bool hasNotification = false,
  }) {
    return Builder(
      builder: (context) {
        final theme = context.read<ThemeProvider>();

        return GestureDetector(
          onTap: onTap,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: theme.glassmorphicColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.borderColor, width: 1),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(icon, color: theme.textColor, size: 22),
                if (hasNotification)
                  Positioned(
                    right: 10,
                    top: 10,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.error, // 🔥 accent-safe
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(
                              context,
                            ).colorScheme.error.withValues(alpha: 0.5),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGlassmorphicBudgetCard(
    double remaining,
    double percentageUsed,
    bool isWarning,
    bool isCritical,
  ) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: AnimatedBuilder(
        animation: _slideAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: child,
          );
        },
        child: Builder(
          builder: (context) {
            final theme = context.read<ThemeProvider>();
            final scheme = Theme.of(context).colorScheme;

            final Color statusColor = isCritical
                ? scheme.error
                : isWarning
                ? Colors.orangeAccent
                : scheme.primary;

            return ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: theme.glassmorphicGradient,
                    ),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: theme.borderColor, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 200,
                            height: 200,
                            child: AnimatedBuilder(
                              animation: _pulseController,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: isWarning
                                      ? 1 + _pulseController.value * 0.05
                                      : 1.0,
                                  child: CustomPaint(
                                    painter: CircularProgressPainter(
                                      progress:
                                          percentageUsed /
                                          100 *
                                          _fadeAnimation.value,
                                      backgroundColor: theme.borderColor
                                          .withValues(alpha: 0.5),
                                      progressColor: statusColor,
                                      strokeWidth: 14,
                                    ),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            '₹${remaining.toStringAsFixed(0)}',
                                            style: TextStyle(
                                              color: statusColor,
                                              fontSize: 38,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: -2,
                                              height: 1,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Remaining',
                                            style: TextStyle(
                                              color: theme.secondaryTextColor,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 1,
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
                        ],
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          // --- CHANGE START: Made this section tappable ---
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                // Trigger the edit dialog on tap
                                _showSetBudgetDialog();
                              },
                              child: Container(
                                color: Colors
                                    .transparent, // Ensures hit test works
                                child: _buildStatColumn(
                                  'Monthly Budget',
                                  '₹${expenseProvider.monthlyBudget.toStringAsFixed(0)}',
                                  Icons
                                      .edit_outlined, // Changed icon to indicate editing
                                ),
                              ),
                            ),
                          ),

                          // --- CHANGE END ---
                          Container(
                            width: 1,
                            height: 50,
                            color: theme.borderColor,
                          ),
                          Expanded(
                            child: _buildStatColumn(
                              'Total Spent',
                              '₹${expenseProvider.totalExpenses.toStringAsFixed(0)}',
                              Icons.shopping_bag_outlined,
                            ),
                          ),
                        ],
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

  Widget _buildStatColumn(String label, String value, IconData icon) {
    return Builder(
      builder: (context) {
        final theme = context.read<ThemeProvider>();

        return Column(
          children: [
            Icon(icon, size: 24, color: theme.secondaryTextColor),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickActions(ExpenseProvider provider) {
    final scheme = Theme.of(context).colorScheme;

    final actions = [
      {
        'icon': Icons.add,
        'label': 'Add',
        'color': scheme.primary,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
          );
        },
      },
      {
        'icon': Icons.download,
        'label': 'Download',
        'color': scheme.secondary,
        'onTap': () async {
          final expenses = Hive.box<ExpenseModel>(
            'expense_box',
          ).values.toList();
          await PdfService.generateAndOpenPdf(expenses);
        },
      },
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: actions.map((action) {
        return _buildQuickActionChip(
          action['icon'] as IconData,
          action['label'] as String,
          action['color'] as Color,
          action['onTap'] as VoidCallback,
        );
      }).toList(),
    );
  }

  Widget _buildQuickActionChip(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return Builder(
      builder: (context) {
        final theme = context.read<ThemeProvider>();

        return GestureDetector(
          onTap: () {
            onTap();
            _triggerHaptic();
          },
          // 1. The outer container now only defines the "touch area" width
          child: Container(
            width: 80,
            color: Colors.transparent, // Ensures the empty space is tappable
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 2. The Visual "Button" is now this fixed-size square
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: theme.glassmorphicColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 30, // Adjusted size to fit the 60x60 box perfectly
                  ),
                ),
                const SizedBox(
                  height: 8,
                ), // Consistent spacing between box and text
                // 3. Text sits outside the colored box
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedTransactions() {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                'Recent Activity',
                style: TextStyle(
                  color: themeProvider.textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                _triggerHaptic();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AllTransactionsScreen(),
                  ),
                );
              },
              child: const Text(
                'View All',
                style: TextStyle(
                  color: Color(0xFF4ecdc4),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ValueListenableBuilder<Box<ExpenseModel>>(
          valueListenable: Hive.box<ExpenseModel>('expense_box').listenable(),
          builder: (context, box, _) {
            if (box.values.isEmpty) {
              return _buildEmptyState(themeProvider);
            }

            // Sort by date and take only top 5
            final sortedExpenses = box.values.toList()
              ..sort((a, b) => b.date.compareTo(a.date));
            final recent = sortedExpenses.take(5).toList();

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recent.length,
              itemBuilder: (context, index) =>
                  _buildTransactionItem(recent[index]),
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmptyState(ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: themeProvider.secondaryTextColor.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No transactions yet',
            style: TextStyle(
              color: themeProvider.textColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first expense or income',
            style: TextStyle(
              color: themeProvider.secondaryTextColor,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(ExpenseModel e) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final categoryStyle = _getCategoryStyle(context, e.category);
    final isExpense = e.isExpense;

    return Dismissible(
      key: Key(e.id),
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFff6b6b),
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.centerRight,
        child: const Icon(Icons.delete, color: Colors.white),
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
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Color(0xFFff6b6b)),
                ),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        final box = Hive.box<ExpenseModel>('expenses');
        box.delete(e.id);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: themeProvider.glassmorphicColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: themeProvider.borderColor, width: 1),
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
                categoryStyle['text'],
                style: const TextStyle(fontSize: 24),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    e.title,
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
                        e.category,
                        style: TextStyle(
                          color: themeProvider.secondaryTextColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: themeProvider.secondaryTextColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Text(
                        _formatDate(e.date),
                        style: TextStyle(
                          color: themeProvider.secondaryTextColor,
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
              '-₹${e.amount.toStringAsFixed(0)}',
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

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    return '${date.day}/${date.month}';
  }

  Widget _buildFloatingActionButton() {
    return SizedBox(
      width: 342,
      height: 60,
      child: Builder(
        builder: (context) {
          final scheme = Theme.of(context).colorScheme;

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddExpenseScreen(),
                ),
              );
              _triggerHaptic();
            },
            // Animation widgets removed, Container is now the direct child
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [scheme.primary, scheme.primaryContainer],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: scheme.primary.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: scheme.onPrimary.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.add, color: scheme.onPrimary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Add Expense',
                    style: TextStyle(
                      color: scheme.onPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;
  final double strokeWidth;

  CircularProgressPainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, backgroundPaint);

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CircularProgressPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
