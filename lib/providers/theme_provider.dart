import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeBox = 'theme_settings';
  static const String _themeKey = 'isDarkMode';

  bool _isDarkMode = true;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadTheme();
  }

  // Load theme preference from storage
  Future<void> _loadTheme() async {
    final box = await Hive.openBox(_themeBox);
    _isDarkMode = box.get(_themeKey, defaultValue: true);
    notifyListeners();
  }

  // Toggle theme
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final box = await Hive.openBox(_themeBox);
    await box.put(_themeKey, _isDarkMode);
    notifyListeners();
  }

  // Set specific theme
  Future<void> setTheme(bool isDark) async {
    _isDarkMode = isDark;
    final box = await Hive.openBox(_themeBox);
    await box.put(_themeKey, _isDarkMode);
    notifyListeners();
  }

  // Get current theme data
  ThemeData get currentTheme => _isDarkMode ? darkTheme : mintlightTheme;

  // Dark Theme (unchanged)
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0f1419),
    primaryColor: const Color(0xFF4ecdc4),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF4ecdc4),
      secondary: Color(0xFFffd93d),
      surface: Color(0xFF1a1f2e),
      error: Color(0xFFff6b6b),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
      onError: Colors.white,
    ),
    cardColor: const Color(0xFF1a1f2e),
    dividerColor: Colors.white12,
    iconTheme: const IconThemeData(color: Colors.white70),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: Colors.white,
        fontSize: 36,
        fontWeight: FontWeight.w900,
        letterSpacing: -1.5,
      ),
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
    ),
  );

  // Mint Light Theme (from your color palette)
  static final ThemeData mintlightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color.fromARGB(255, 168, 203, 225), // Background
    primaryColor: const Color(0xFF3ecfc0), // Primary
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF3ecfc0), // Primary
      onPrimary: Colors.white, // Primary Foreground
      secondary: Color.fromARGB(255, 244, 206, 124), // Secondary
      onSecondary: Color(0xFF4b4f54), // Secondary Foreground
      surface: Colors.white, // Card
      onSurface: Color(0xFF0f1720), // Foreground
      error: Color.fromARGB(255, 241, 99, 120), // Destructive
      onError: Color(0xFF9b2a2a), // Destructive Foreground
    ),
    cardColor: const Color(0xFFffffff), // Card
    dividerColor: const Color(0x14000000), // Border: #00000014
    iconTheme: const IconThemeData(color: Color(0xFF4b4f54)), // Secondary Foreground
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: Color(0xFF0f1720), // Foreground
        fontSize: 36,
        fontWeight: FontWeight.w900,
        letterSpacing: -1.5,
      ),
      titleLarge: TextStyle(
        color: Color(0xFF0f1720), // Foreground
        fontSize: 24,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: TextStyle(
        color: Color(0xFF0f1720), // Foreground
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        color: Color(0xFF0f1720), // Foreground
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      bodyMedium: TextStyle(
        color: Color(0xFF9aa0a6), // Muted Foreground
        fontSize: 14,
      ),
      labelLarge: TextStyle(
        color: Colors.white, // Primary Foreground
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF3ecfc0), // Primary
        foregroundColor: Colors.white, // Primary Foreground
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      ),
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFFffffff), // Card
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50),
        side: const BorderSide(
          color: Color(0x14000000), // Border
          width: 1,
        ),
      ),
      shadowColor: Colors.black.withValues(alpha:  0.05),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFffffff), // Input
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),  
        borderSide: const BorderSide(
          color: Color(0x14000000), // Border
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0x14000000), // Border
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFF3ecfc0), // Primary
          width: 2,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: const TextStyle(
        color: Color(0xFF9aa0a6), // Muted Foreground
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFf3f6f8), // Background
      foregroundColor: Color(0xFF0f1720), // Foreground
      elevation: 0,
      centerTitle: true,
    ),
  );

  // Helper methods for colors based on theme
  Color get backgroundColor => _isDarkMode
      ? const Color(0xFF0f1419)
      : const Color(0xFFf3f6f8); // Background

  Color get cardColor => _isDarkMode
      ? const Color(0xFF1a1f2e)
      : const Color(0xFFffffff); // Card

  Color get textColor => _isDarkMode
      ? Colors.white
      : const Color(0xFF0f1720); // Foreground

  Color get secondaryTextColor => _isDarkMode
      ? Colors.white70
      : const Color(0xFF9aa0a6); // Muted Foreground

  Color get accentColor => _isDarkMode
      ? const Color(0xFF4ecdc4)
      : const Color(0xFF3ecfc0); // Primary

  Color get successColor => _isDarkMode
      ? const Color(0xFF4ecdc4)
      : const Color(0xFF0b6b5b); // Success Foreground

  Color get successBackgroundColor => _isDarkMode
      ? const Color(0xFF1a2e2a)
      : const Color(0xFFe6fff9); // Success

  Color get warningColor => _isDarkMode
      ? const Color(0xFFffd93d)
      :  const Color(0xFFffd93d); // Warning Foreground

  Color get warningBackgroundColor => _isDarkMode
      ? const Color(0xFF2e2a1a)
      : const Color(0xFFfff3e6); // Warning

  Color get borderColor => _isDarkMode
      ? Colors.white.withValues(alpha:  0.1)
      : const Color(0x14000000); // Border: #00000014

  Color get glassmorphicColor => _isDarkMode
      ? Colors.white.withValues(alpha:  0.05)
      : Colors.white.withValues(alpha:  0.7);

  // Gradient colors
  List<Color> get backgroundGradient => _isDarkMode
      ? [
          const Color(0xFF0f1419),
          const Color(0xFF1a1f2e),
          const Color(0xFF0f1419),
        ]
      : [
          const Color(0xFFf3f6f8), // Background
          const Color(0xFFf0f2f4), // Muted
          const Color(0xFFf3f6f8), // Background
        ];

  List<Color> get glassmorphicGradient => _isDarkMode
      ? [
          Colors.white.withValues(alpha:  0.08),
          Colors.white.withValues(alpha:  0.03),
        ]
      : [
          Colors.white.withValues(alpha:  0.9),
          Colors.white.withValues(alpha:  0.6),
        ];

  // New helper methods for specific colors from your palette
  Color get primaryColor => _isDarkMode
      ? const Color(0xFF4ecdc4)
      : const Color(0xFF3ecfc0); // Primary

  Color get primaryForegroundColor => _isDarkMode
      ? Colors.white
      : Colors.white; // Primary Foreground

  Color get secondaryColor => _isDarkMode
      ? const Color(0xFFffd93d)
      : const Color(0xFFfff7e6); // Secondary

  Color get secondaryForegroundColor => _isDarkMode
      ? Colors.white
      : const Color(0xFF4b4f54); // Secondary Foreground

  Color get mutedColor => _isDarkMode
      ? const Color(0xFF1a1f2e)
      : const Color(0xFFf0f2f4); // Muted

  Color get mutedForegroundColor => _isDarkMode
      ? Colors.white70
      : const Color(0xFF9aa0a6); // Muted Foreground

  Color get destructiveColor => _isDarkMode
      ? const Color(0xFFff6b6b)
      : const Color(0xFFffecef); // Destructive

  Color get destructiveForegroundColor => _isDarkMode
      ? Colors.white
      : const Color(0xFF9b2a2a); // Destructive Foreground

  Color get accentBackgroundColor => _isDarkMode
      ? const Color(0xFFffd93d)
      : const Color(0xFFffd966); // Accent

  Color get accentForegroundColor => _isDarkMode
      ? Colors.white
      : const Color(0xFF3b2f00); // Accent Foreground

  Color get cardForegroundColor => _isDarkMode
      ? Colors.white
      : const Color(0xFF0f1720); // Card Foreground

  Color get sidebarColor => _isDarkMode
      ? const Color(0xFF1a1f2e)
      : const Color(0xFFf7fafc); // Sidebar

  Color get sidebarForegroundColor => _isDarkMode
      ? Colors.white70
      : const Color(0xFF394047); // Sidebar Foreground

  Color get sidebarPrimaryColor => _isDarkMode
      ? const Color(0xFF4ecdc4)
      : const Color(0xFFeaf9f6); // Sidebar Primary

  Color get sidebarPrimaryForegroundColor => _isDarkMode
      ? Colors.white
      : const Color(0xFF0f6b63); // Sidebar Primary Foreground

  // UI specific colors
  Color get budgetCardColor => _isDarkMode
      ? const Color(0xFF1a1f2e)
      : const Color(0xFFffffff); // Card

  Color get progressBarBackground => _isDarkMode
      ? Colors.white.withValues(alpha:  0.1)
      : const Color(0xFFf0f2f4); // Muted

  Color get progressBarFill => _isDarkMode
      ? const Color(0xFF4ecdc4)
      : const Color(0xFF3ecfc0); // Primary

  Color get alertCardColor => _isDarkMode
      ? const Color(0xFF2D3748)
      : const Color(0xFFfff3e6); // Warning

  Color get alertTextColor => _isDarkMode
      ? const Color(0xFFffd93d)
      : const Color(0xFF6b4a00); // Warning Foreground

  Color get buttonColor => _isDarkMode
      ? const Color(0xFF4ecdc4)
      : const Color(0xFF3ecfc0); // Primary

  Color get categoryCardColor => _isDarkMode
      ? const Color(0xFF2D3748)
      : const Color(0xFFffffff); // Card

  Color get dividerColor => _isDarkMode
      ? Colors.white.withValues(alpha:  0.1)
      : const Color(0x14000000); // Border

  Color get inputColor => _isDarkMode
      ? const Color(0xFF1a1f2e)
      : const Color(0xFFffffff); // Input
}