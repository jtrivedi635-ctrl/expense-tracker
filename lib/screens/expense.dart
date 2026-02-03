import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../services/pdf_service.dart';
import '../models/expense_model.dart';
import 'add_expense.dart';
import '../providers/theme_provider.dart';

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
                          DateFormat.yMMMM().format(DateTime.now()),
                          style: TextStyle(
                            color: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .color!
                                .withOpacity(0.5),
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
                          style: Theme.of(context).textTheme.displayLarge!.copyWith(
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
                      _buildIconButton(
                        context.watch<ThemeProvider>().isDarkMode
                            ? Icons.light_mode_rounded
                            : Icons.dark_mode_rounded,
                        () {
                          context.read<ThemeProvider>().toggleTheme();
                          _triggerHaptic();
                        },
                      ),
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
                            ).colorScheme.error.withOpacity(0.5),
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
                        color: Colors.black.withOpacity(0.1),
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
                                          percentageUsed / 100 * _fadeAnimation.value,
                                      backgroundColor:
                                          theme.borderColor.withOpacity(0.5),
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
                          Expanded(
                            child: _buildStatColumn(
                              'Monthly Budget',
                              '₹${expenseProvider.monthlyBudget.toStringAsFixed(0)}',
                              Icons.account_balance_wallet_outlined,
                            ),
                          ),
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
        'icon': Icons.add_circle_outline,
        'label': 'Add',
        'color': scheme.primary,
        'onTap': () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AddExpenseScreen()));
        }
      },
      {
        'icon': Icons.download,
        'label': 'Download',
        'color': scheme.secondary,
        'onTap': () async {
          final expenses = Hive.box<ExpenseModel>('expenses').values.toList();
          await PdfService.generateAndOpenPdf(expenses);
        }
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

  Widget _buildQuickActionChip(IconData icon, String label, Color color, VoidCallback onTap) {
    return Builder(
      builder: (context) {
        final theme = context.read<ThemeProvider>();

        return GestureDetector(
          onTap: () {
            onTap();
            _triggerHaptic();
          },
          child: Container(
            width: 80,
            decoration: BoxDecoration(
              color: theme.glassmorphicColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  child: Icon(icon, color: color, size: 35),
                ),
                const SizedBox(height: 6),
                Text(
                  label,
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
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ValueListenableBuilder<Box<ExpenseModel>>(
          valueListenable: Hive.box<ExpenseModel>('expenses').listenable(),
          builder: (context, box, _) {
            if (box.values.isEmpty) {
              return Center(
                child: Text(
                  "No recent transactions",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              );
            }
            final sortedExpenses = box.values.toList()
              ..sort((a, b) => b.date.compareTo(a.date));
            final recent = sortedExpenses.take(5).toList();

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recent.length,
              itemBuilder: (context, index) => _buildTransactionItem(recent[index]),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTransactionItem(ExpenseModel e) {
    final categoryStyle = _getCategoryStyle(context, e.category);

    return Builder(
      builder: (context) {
        final theme = context.read<ThemeProvider>();
        final scheme = Theme.of(context).colorScheme;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.glassmorphicColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: theme.borderColor, width: 1),
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
              ),
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
                      _formatDate(e.date),
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
                  color: scheme.error,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        );
      },
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
    return Positioned(
      bottom: 30,
      right: 20,
      left: 20,
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
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + (_pulseController.value * 0.02),
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [scheme.primary, scheme.primaryContainer],
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: scheme.primary.withOpacity(0.4),
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
                            color: scheme.onPrimary.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.add,
                            color: scheme.onPrimary,
                            size: 20,
                          ),
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
