import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../providers/expense_provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _budgetController = TextEditingController();

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  void _showBudgetDialog(ExpenseProvider expenseProvider) {
    _budgetController.text = expenseProvider.monthlyBudget.toStringAsFixed(0);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Set Monthly Budget'),
          content: TextField(
            controller: _budgetController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              prefixText: '₹',
              hintText: 'Enter your budget',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final newBudget = double.tryParse(_budgetController.text);
                if (newBudget != null) {
                  expenseProvider.updateMonthlyBudget(newBudget);
                }
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final expenseProvider = Provider.of<ExpenseProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: themeProvider.backgroundGradient,
              ),
            ),
          ),
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  pinned: true,
                  title: const Text(
                    'Settings',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  centerTitle: true,
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildSettingsGroup(
                        themeProvider,
                        title: 'Appearance',
                        children: [
                          _buildGlassmorphicTile(
                            themeProvider,
                            leading: Icons.palette_outlined,
                            title: 'Dark Mode',
                            trailing: Switch(
                              value: themeProvider.isDarkMode,
                              onChanged: (value) => themeProvider.toggleTheme(),
                              activeColor: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      _buildSettingsGroup(
                        themeProvider,
                        title: 'Budget',
                        children: [
                          _buildGlassmorphicTile(
                            themeProvider,
                            leading: Icons.account_balance_wallet_outlined,
                            title: 'Monthly Budget',
                            trailing: Text(
                              '₹${expenseProvider.monthlyBudget.toStringAsFixed(0)}',
                              style: TextStyle(
                                color: themeProvider.textColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onTap: () => _showBudgetDialog(expenseProvider),
                          ),
                        ],
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsGroup(ThemeProvider themeProvider, {required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
          child: Text(
            title,
            style: TextStyle(
              color: themeProvider.textColor.withOpacity(0.7),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: themeProvider.glassmorphicColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: themeProvider.borderColor, width: 1.5),
              ),
              child: Column(children: children),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildGlassmorphicTile(ThemeProvider themeProvider, {required IconData leading, required String title, Widget? trailing, VoidCallback? onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: ListTile(
          leading: Icon(leading, color: themeProvider.textColor),
          title: Text(title, style: TextStyle(color: themeProvider.textColor)),
          trailing: trailing,
        ),
      ),
    );
  }
}
