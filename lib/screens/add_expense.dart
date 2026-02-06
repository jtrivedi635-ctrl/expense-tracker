import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../models/expense_model.dart';
import '../providers/expense_provider.dart';
import '../providers/theme_provider.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen>
    with TickerProviderStateMixin {
  late AnimationController _formController;
  late Animation<double> _formFadeAnimation;
  late Animation<Offset> _formSlideAnimation;

  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedCategory = 'Food';
  DateTime _selectedDate = DateTime.now();
  bool _isExpense = true;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Food', 'icon': '🍔', 'color': const Color(0xFFff6b6b)},
    {'name': 'Transport', 'icon': '🚗', 'color': const Color(0xFF4ecdc4)},
    {'name': 'Shopping', 'icon': '🛍️', 'color': const Color(0xFFffd93d)},
    {'name': 'Bills', 'icon': '💡', 'color': const Color(0xFFa78bfa)},
    {'name': 'Entertainment', 'icon': '🎮', 'color': const Color(0xFFff9ff3)},
    {'name': 'Health', 'icon': '💊', 'color': const Color(0xFF54a0ff)},
    {'name': 'Education', 'icon': '📚', 'color': const Color(0xFFfeca57)},
    {'name': 'Other', 'icon': '📦', 'color': const Color(0xFF95afc0)},
  ];

  @override
  void initState() {
    super.initState();
    _formController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _formFadeAnimation = CurvedAnimation(
      parent: _formController,
      curve: Curves.easeOut,
    );
    _formSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _formController, curve: Curves.easeOutCubic),
    );
    _formController.forward();
  }

  @override
  void dispose() {
    _formController.dispose();
    _amountController.dispose();
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _triggerHaptic() {
    HapticFeedback.lightImpact();
  }

  Future<void> _selectDate() async {
    _triggerHaptic();
    final themeProvider = context.read<ThemeProvider>();
    final baseTheme = Theme.of(context);
    final scheme = baseTheme.colorScheme;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: baseTheme.copyWith(
            colorScheme: scheme.copyWith(
              primary: themeProvider.primaryColor,
              onPrimary: Colors.white,
              surface: themeProvider.cardColor,
              onSurface: themeProvider.textColor,
            ),
            dialogBackgroundColor: themeProvider.cardColor,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: themeProvider.primaryColor,
              ),
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: themeProvider.cardColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveExpense() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      _triggerHaptic();

      final expense = ExpenseModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        amount: double.parse(_amountController.text),
        category: _selectedCategory,
        date: _selectedDate,
        isExpense: _isExpense,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      await context.read<ExpenseProvider>().addExpense(expense);
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        setState(() => _isLoading = false);
        _showSuccessDialog();
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _SuccessDialog(
        amount: _amountController.text,
        isExpense: _isExpense,
        onDismiss: () {
          Navigator.pop(context);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✅ FIXED: Use watch instead of read
    final theme = context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: theme.backgroundGradient,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(theme),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: FadeTransition(
                      opacity: _formFadeAnimation,
                      child: SlideTransition(
                        position: _formSlideAnimation,
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 32),
                              _buildAmountInput(theme),
                              const SizedBox(height: 32),
                              _buildTitleInput(theme),
                              const SizedBox(height: 24),
                              _buildCategorySection(theme),
                              const SizedBox(height: 24),
                              _buildDateSelector(theme),
                              const SizedBox(height: 24),
                              _buildNotesInput(theme),
                              const SizedBox(height: 32),
                              _buildSaveButton(theme),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(ThemeProvider theme) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          _buildIconButton(Icons.arrow_back, () => Navigator.pop(context), theme),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add Transaction',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 24,
                    letterSpacing: -0.5,
                    color: theme.textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Track your finances',
                  style: TextStyle(
                    color: theme.secondaryTextColor,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _buildIconButton(
            theme.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            () => context.read<ThemeProvider>().toggleTheme(),
            theme,
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap, ThemeProvider theme) {
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

  Widget _buildAmountInput(ThemeProvider theme) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Amount', style: TextStyle(color: theme.secondaryTextColor, fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: theme.glassmorphicColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: theme.borderColor, width: 1),
          ),
          child: TextFormField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, letterSpacing: -2, color: theme.textColor),
            decoration: InputDecoration(
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 24),
                child: Text('₹', style: TextStyle(color: _isExpense ? scheme.error : scheme.primary, fontSize: 48, fontWeight: FontWeight.w900)),
              ),
              hintText: '0',
              hintStyle: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: theme.secondaryTextColor.withValues(alpha: 0.4)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Please enter an amount';
              if (double.tryParse(value) == null) return 'Please enter a valid number';
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTitleInput(ThemeProvider theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Description', style: TextStyle(color: theme.secondaryTextColor, fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: theme.glassmorphicColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: theme.borderColor, width: 1),
          ),
          child: TextFormField(
            controller: _titleController,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: theme.textColor),
            decoration: InputDecoration(
              hintText: 'e.g., Coffee at Starbucks',
              hintStyle: TextStyle(color: theme.secondaryTextColor.withValues(alpha: 0.6)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              prefixIcon: Icon(Icons.edit_outlined, color: theme.secondaryTextColor.withValues(alpha: 0.6), size: 20),
            ),
            validator: (value) => (value == null || value.isEmpty) ? 'Please enter a description' : null,
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySection(ThemeProvider theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Category', style: TextStyle(color: theme.secondaryTextColor, fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
        const SizedBox(height: 12),
        Wrap(spacing: 12, runSpacing: 12, children: _categories.map((cat) => _buildCategoryChip(cat, theme)).toList()),
      ],
    );
  }

  Widget _buildCategoryChip(Map<String, dynamic> category, ThemeProvider theme) {
    final isSelected = _selectedCategory == category['name'];
    final Color accent = category['color'] as Color;
    return GestureDetector(
      onTap: () {
        _triggerHaptic();
        setState(() => _selectedCategory = category['name'] as String);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected ? LinearGradient(colors: [accent, accent.withValues(alpha: 0.8)]) : null,
          color: isSelected ? null : theme.glassmorphicColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? accent.withValues(alpha: 0.5) : theme.borderColor, width: isSelected ? 2 : 1),
          boxShadow: isSelected ? [BoxShadow(color: accent.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(category['icon'] as String, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(category['name'] as String, style: TextStyle(color: isSelected ? Colors.white : theme.textColor, fontSize: 14, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector(ThemeProvider theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Date', style: TextStyle(color: theme.secondaryTextColor, fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _selectDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              color: theme.glassmorphicColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: theme.borderColor, width: 1),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_outlined, color: theme.secondaryTextColor, size: 20),
                const SizedBox(width: 16),
                Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: theme.textColor)),
                const Spacer(),
                Icon(Icons.arrow_forward_ios, color: theme.secondaryTextColor.withValues(alpha: 0.6), size: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesInput(ThemeProvider theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Notes (Optional)', style: TextStyle(color: theme.secondaryTextColor, fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: theme.glassmorphicColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: theme.borderColor, width: 1),
          ),
          child: TextFormField(
            controller: _notesController,
            maxLines: 4,
            style: TextStyle(fontSize: 14, color: theme.textColor),
            decoration: InputDecoration(
              hintText: 'Add additional details...',
              hintStyle: TextStyle(color: theme.secondaryTextColor.withValues(alpha: 0.6)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(ThemeProvider theme) {
    final scheme = Theme.of(context).colorScheme;
    final Color primaryColor = _isExpense ? scheme.error : scheme.primary;
    final Color secondaryColor = _isExpense ? scheme.error.withValues(alpha: 0.85) : scheme.primaryContainer;

    return GestureDetector(
      onTap: _isLoading ? null : _saveExpense,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [primaryColor, secondaryColor]),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: primaryColor.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 10))],
        ),
        child: Center(
          child: _isLoading
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                      child: const Icon(Icons.check, color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 12),
                    const Text('Save Transaction', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                  ],
                ),
        ),
      ),
    );
  }
}

class _SuccessDialog extends StatefulWidget {
  final String amount;
  final bool isExpense;
  final VoidCallback onDismiss;

  const _SuccessDialog({required this.amount, required this.isExpense, required this.onDismiss});

  @override
  State<_SuccessDialog> createState() => _SuccessDialogState();
}

class _SuccessDialogState extends State<_SuccessDialog> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5)));
    _controller.forward();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ FIXED: Use watch
    final theme = context.watch<ThemeProvider>();
    final isDark = theme.isDarkMode;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark ? [Colors.white.withValues(alpha: 0.1), Colors.white.withValues(alpha: 0.05)] : [Colors.white.withValues(alpha: 0.95), Colors.white.withValues(alpha: 0.90)],
                  ),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.05), width: 1.5),
                  boxShadow: isDark ? null : [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 30, offset: const Offset(0, 10))],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: widget.isExpense ? [const Color(0xFFff6b6b), const Color(0xFFee5a6f)] : [const Color(0xFF4ecdc4), const Color(0xFF44a4a1)]),
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: (widget.isExpense ? const Color(0xFFff6b6b) : const Color(0xFF4ecdc4)).withValues(alpha: 0.4), blurRadius: 20, spreadRadius: 5)],
                      ),
                      child: const Icon(Icons.check_rounded, color: Colors.white, size: 48),
                    ),
                    const SizedBox(height: 24),
                    Text('Success!', style: TextStyle(color: theme.textColor, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -1)),
                    const SizedBox(height: 8),
                    Text('${widget.isExpense ? 'Expense' : 'Income'} of ₹${widget.amount}', style: TextStyle(color: theme.secondaryTextColor, fontSize: 16, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    Text('has been added successfully', style: TextStyle(color: theme.secondaryTextColor, fontSize: 16, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}