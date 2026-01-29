import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'dart:ui';
import 'add_expense.dart';
import '../models/expense_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0f1419),
        primaryColor: const Color(0xFF4ecdc4),
      ),
    );
  }
}

// ============================================================================
// SPLASH SCREEN
// ============================================================================

// ============================================================================
// MAIN EXPENSE TRACKER SCREEN
// ============================================================================

class PremiumExpenseTracker extends StatefulWidget {
  const PremiumExpenseTracker({super.key});

  @override
  State<PremiumExpenseTracker> createState() => _PremiumExpenseTrackerState();
}

class _PremiumExpenseTrackerState extends State<PremiumExpenseTracker>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pulseController;
  late AnimationController _shimmerController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _pulseAnimation;

  // Sample data
  final double totalBudget = 50000;
  final double totalExpenses = 32450;
  final int daysRemaining = 12;
  bool isDarkMode = true;

  final List<Map<String, dynamic>> categories = [
    {
      'name': 'Food',
      'spent': 8500.0,
      'budget': 15000.0,
      'icon': '🍔',
      'color': const Color(0xFFff6b6b),
    },
    {
      'name': 'Transport',
      'spent': 5200.0,
      'budget': 8000.0,
      'icon': '🚗',
      'color': const Color(0xFF4ecdc4),
    },
    {
      'name': 'Shopping',
      'spent': 12450.0,
      'budget': 15000.0,
      'icon': '🛍️',
      'color': const Color(0xFFffd93d),
    },
    {
      'name': 'Bills',
      'spent': 6300.0,
      'budget': 10000.0,
      'icon': '💡',
      'color': const Color(0xFFa78bfa),
    },
  ];

  @override
  void initState() {
    super.initState();
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat();

    _fadeAnimation = CurvedAnimation(
      parent: _mainController,
      curve: Curves.easeOutCubic,
    );
    _slideAnimation = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.easeOutCubic),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _mainController.forward();
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  void _triggerHaptic() {
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final remaining = totalBudget - totalExpenses;
    final percentageUsed = (totalExpenses / totalBudget * 100).clamp(
      0.0,
      100.0,
    );
    final isWarning = percentageUsed >= 80;
    final isCritical = percentageUsed >= 90;

    return Scaffold(
      backgroundColor: isDarkMode
          ? const Color(0xFF0f1419)
          : const Color(0xFFf5f7fa),
      body: Stack(
        children: [
          // Animated background gradient
          _buildAnimatedBackground(),

          // Main content
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Custom App Bar
                _buildSliverAppBar(),

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
                      _buildQuickActions(),
                      const SizedBox(height: 24),

                      // Insights Card
                      _buildInsightsCard(),
                      const SizedBox(height: 24),

                      // Category Breakdown
                      _buildCategoryBreakdown(),
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

          // Floating Action Button
          _buildFloatingActionButton(),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDarkMode
                  ? const [
                      Color(0xFF0f1419),
                      Color(0xFF1a1f2e),
                      Color(0xFF0f1419),
                    ]
                  : const [
                      Color(0xFFf5f7fa),
                      Color(0xFFe8ecf3),
                      Color(0xFFf5f7fa),
                    ],
              stops: [0.0, _shimmerController.value, 1.0],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Text(
                          'January 2026',
                          style: TextStyle(
                            color: isDarkMode
                                ? Colors.white.withValues(alpha: 0.5)
                                : Colors.black.withValues(alpha: 0.5),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1,
                          ),
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
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1.5,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _buildIconButton(Icons.search, () {
                        _triggerHaptic();
                      }),
                      const SizedBox(width: 12),
                      _buildIconButton(Icons.notifications_outlined, () {
                        _triggerHaptic();
                      }, hasNotification: true),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton(
    IconData icon,
    VoidCallback onTap, {
    bool hasNotification = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDarkMode
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              icon,
              color: isDarkMode ? Colors.white : Colors.black,
              size: 22,
            ),
            if (hasNotification)
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: const Color(0xFFff6b6b),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFff6b6b).withValues(alpha: 0.5),
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
  }

  Widget _buildGlassmorphicBudgetCard(
    double remaining,
    double percentageUsed,
    bool isWarning,
    bool isCritical,
  ) {
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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDarkMode
                      ? [
                          Colors.white.withValues(alpha: 0.08),
                          Colors.white.withValues(alpha: 0.03),
                        ]
                      : [
                          Colors.white.withValues(alpha: 0.9),
                          Colors.white.withValues(alpha: 0.6),
                        ],
                ),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: isDarkMode
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.white.withValues(alpha: 0.5),
                  width: 1.5,
                ),
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
                  // Circular Progress with center text
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color:
                                  (isCritical
                                          ? const Color(0xFFff6b6b)
                                          : isWarning
                                          ? const Color(0xFFffd93d)
                                          : const Color(0xFF4ecdc4))
                                      .withValues(alpha: 0.3),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 200,
                        height: 200,
                        child: AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: isWarning ? _pulseAnimation.value : 1.0,
                              child: CustomPaint(
                                painter: CircularProgressPainter(
                                  progress:
                                      percentageUsed /
                                      100 *
                                      _fadeAnimation.value,
                                  backgroundColor: isDarkMode
                                      ? Colors.white.withValues(alpha: 0.1)
                                      : Colors.black.withValues(alpha: 0.1),
                                  progressColor: isCritical
                                      ? const Color(0xFFff6b6b)
                                      : isWarning
                                      ? const Color(0xFFffd93d)
                                      : const Color(0xFF4ecdc4),
                                  strokeWidth: 14,
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '₹${remaining.toStringAsFixed(0)}',
                                        style: TextStyle(
                                          color: isCritical
                                              ? const Color(0xFFff6b6b)
                                              : isWarning
                                              ? const Color(0xFFffd93d)
                                              : const Color(0xFF4ecdc4),
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
                                          color: isDarkMode
                                              ? Colors.white.withValues(
                                                  alpha: 0.5,
                                                )
                                              : Colors.black.withValues(
                                                  alpha: 0.5,
                                                ),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              (isCritical
                                                      ? const Color(0xFFff6b6b)
                                                      : isWarning
                                                      ? const Color(0xFFffd93d)
                                                      : const Color(0xFF4ecdc4))
                                                  .withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Text(
                                          '${percentageUsed.toStringAsFixed(1)}% Used',
                                          style: TextStyle(
                                            color: isCritical
                                                ? const Color(0xFFff6b6b)
                                                : isWarning
                                                ? const Color(0xFFffd93d)
                                                : const Color(0xFF4ecdc4),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                          ),
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
                  // Budget Stats
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatColumn(
                          'Monthly Budget',
                          '₹${totalBudget.toStringAsFixed(0)}',
                          Icons.account_balance_wallet_outlined,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 50,
                        color: isDarkMode
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.black.withValues(alpha: 0.1),
                      ),
                      Expanded(
                        child: _buildStatColumn(
                          'Total Spent',
                          '₹${totalExpenses.toStringAsFixed(0)}',
                          Icons.shopping_bag_outlined,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          size: 24,
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.4)
              : Colors.black.withValues(alpha: 0.4),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isDarkMode
                ? Colors.white.withValues(alpha: 0.5)
                : Colors.black.withValues(alpha: 0.5),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {
        'icon': Icons.add_circle_outline,
        'label': 'Add',
        'color': const Color(0xFF4ecdc4),
      },
      {
        'icon': Icons.bar_chart_rounded,
        'label': 'Stats',
        'color': const Color(0xFFa78bfa),
      },
      {
        'icon': Icons.category_outlined,
        'label': 'Categories',
        'color': const Color(0xFFffd93d),
      },
      {
        'icon': Icons.settings_outlined,
        'label': 'Settings',
        'color': const Color(0xFFff6b6b),
      },
    ];

    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: actions.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(
              right: index < actions.length - 1 ? 16 : 0,
            ),
            child: _buildQuickActionChip(
              actions[index]['icon'] as IconData,
              actions[index]['label'] as String,
              actions[index]['color'] as Color,
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickActionChip(IconData icon, String label, Color color) {
    return GestureDetector(
      onTap: _triggerHaptic,
      child: Container(
        width: 80,
        decoration: BoxDecoration(
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsCard() {
    final dailyAvg = totalExpenses / (30 - daysRemaining);
    final projectedTotal = dailyAvg * 30;
    final willExceed = projectedTotal > totalBudget;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: willExceed
              ? [
                  const Color(0xFFff6b6b).withValues(alpha: 0.15),
                  const Color(0xFFff6b6b).withValues(alpha: 0.05),
                ]
              : [
                  const Color(0xFF4ecdc4).withValues(alpha: 0.15),
                  const Color(0xFF4ecdc4).withValues(alpha: 0.05),
                ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: willExceed
              ? const Color(0xFFff6b6b).withValues(alpha: 0.3)
              : const Color(0xFF4ecdc4).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: willExceed
                  ? const Color(0xFFff6b6b).withValues(alpha: 0.2)
                  : const Color(0xFF4ecdc4).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              willExceed
                  ? Icons.warning_amber_rounded
                  : Icons.lightbulb_outline,
              color: willExceed
                  ? const Color(0xFFff6b6b)
                  : const Color(0xFF4ecdc4),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  willExceed ? 'Budget Alert!' : 'Smart Insight',
                  style: TextStyle(
                    color: willExceed
                        ? const Color(0xFFff6b6b)
                        : const Color(0xFF4ecdc4),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  willExceed
                      ? 'At this rate, you\'ll exceed budget by ₹${(projectedTotal - totalBudget).toStringAsFixed(0)}'
                      : 'Great job! You\'re on track to save ₹${(totalBudget - projectedTotal).toStringAsFixed(0)}',
                  style: TextStyle(
                    color: isDarkMode
                        ? Colors.white.withValues(alpha: 0.7)
                        : Colors.black.withValues(alpha: 0.7),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Spending by Category',
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...categories.map((category) => _buildCategoryItem(category)).toList(),
      ],
    );
  }

  Widget _buildCategoryItem(Map<String, dynamic> category) {
    final double spent = category['spent'] as double;
    final double budget = category['budget'] as double;
    final percentage = (spent / budget * 100).clamp(0.0, 100.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: (category['color'] as Color).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    category['icon'] as String,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category['name'] as String,
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹${spent.toStringAsFixed(0)} of ₹${budget.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: isDarkMode
                            ? Colors.white.withValues(alpha: 0.5)
                            : Colors.black.withValues(alpha: 0.5),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${percentage.toStringAsFixed(0)}%',
                style: TextStyle(
                  color: category['color'] as Color,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: isDarkMode
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(
                category['color'] as Color,
              ),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedTransactions() {
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
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            TextButton(
              onPressed: _triggerHaptic,
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
          valueListenable: Hive.box<ExpenseModel>('expenses').listenable(),
          builder: (context, box, _) {
            final expenses = box.values.toList().cast<ExpenseModel>();

            if (expenses.isEmpty) {
              return const Center(child: Text("No recent transactions"));
            }

            // Sort by date (newest first) and take top 5
            expenses.sort((a, b) => b.date.compareTo(a.date));
            final recentExpenses = expenses.take(5).toList();

            return Column(
              children: recentExpenses
                  .map((t) => _buildTransactionItem(t))
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTransactionItem(ExpenseModel e) {
    // final int amount = transaction['amount'] as int;
    // final isExpense = amount < 0;
    final categoryStyle = _getCategoryStyle(e.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.1),
          width: 1,
        ),
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
                style:const TextStyle(fontSize: 24), 
              )
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e.title,
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(e.date),
                  style: TextStyle(
                    color: isDarkMode
                        ? Colors.white.withValues(alpha: 0.5)
                        : Colors.black.withValues(alpha: 0.5),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '-\₹${e.amount.abs().toStringAsFixed(2)}',
            style: TextStyle(
              color: const Color(0xFFff6b6b),
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getCategoryStyle(String category) {
    switch (category) {
      case 'Food':
        return {'text': '🍔', 'color': const Color(0xFFff6b6b)};
      case 'Transport':
        return {'text': '🚗', 'color': const Color(0xFF4ecdc4)};
      case 'Shopping':
        return {'text': '🛍️', 'color': Colors.orange};
      case 'Bills':
        return {'text': '📝', 'color': Colors.yellow};
      case 'Entertainment':
        return {'text': '🎮', 'color': Colors.purple};
      case 'Health':
        return {'text': '💊', 'color': Colors.red};
      case 'Education':
        return {'text': '📚', 'color': Colors.green};
      default:
        return {'text': '💰', 'color': Colors.blue};
    }
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    return '${date.day}/${date.month}';
  }

  Widget _buildFloatingActionButton() {
    return Positioned(
      bottom: 30,
      right: 20,
      left: 20,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddExpenseScreen()),
          );
          _triggerHaptic();
        },
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0 + (_pulseController.value * 0.02),
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF4ecdc4), Color(0xFF44a4a1)],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4ecdc4).withValues(alpha: 0.4),
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
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Add Expense',
                      style: TextStyle(
                        color: Colors.white,
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
      ),
    );
  }
}

// Custom painter for circular progress
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

    // Background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          progressColor,
          progressColor.withValues(alpha: 0.6),
          progressColor,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
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
  bool shouldRepaint(CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
