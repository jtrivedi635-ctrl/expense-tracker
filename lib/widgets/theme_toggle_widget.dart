
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return GestureDetector(
          onTap: () {
            themeProvider.toggleTheme();
          },
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: themeProvider.glassmorphicColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: themeProvider.borderColor,
                width: 1,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedOpacity(
                  opacity: themeProvider.isDarkMode ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: const Icon(
                    Icons.dark_mode_rounded,
                    color: Color(0xFF4ecdc4),
                    size: 22,
                  ),
                ),
                AnimatedOpacity(
                  opacity: themeProvider.isDarkMode ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: const Icon(
                    Icons.light_mode_rounded,
                    color: Color(0xFFffd93d),
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Alternative: Animated Switch Style Toggle
class ThemeToggleSwitch extends StatelessWidget {
  const ThemeToggleSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return GestureDetector(
          onTap: () {
            themeProvider.toggleTheme();
          },
          child: Container(
            width: 80,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: themeProvider.isDarkMode
                    ? [
                        const Color(0xFF1a1f2e),
                        const Color(0xFF2a3150),
                      ]
                    : [
                        const Color(0xFFe8ecf3),
                        const Color(0xFFd0d7e3),
                      ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: themeProvider.borderColor,
                width: 1.5,
              ),
            ),
            child: Stack(
              children: [
                // Icons
                Positioned(
                  left: 8,
                  top: 8,
                  child: Icon(
                    Icons.light_mode_rounded,
                    size: 20,
                    color: themeProvider.isDarkMode
                        ? Colors.white.withValues(alpha:  0.3)
                        : const Color(0xFFffd93d),
                  ),
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Icon(
                    Icons.dark_mode_rounded,
                    size: 20,
                    color: themeProvider.isDarkMode
                        ? const Color(0xFF4ecdc4)
                        : Colors.black.withValues(alpha:  0.3),
                  ),
                ),
                // Sliding indicator
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  left: themeProvider.isDarkMode ? 40 : 4,
                  top: 4,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: themeProvider.isDarkMode
                            ? [
                                const Color(0xFF4ecdc4),
                                const Color(0xFF44a4a1),
                              ]
                            : [
                                const Color(0xFFffd93d),
                                const Color(0xFFfeca57),
                              ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (themeProvider.isDarkMode
                                  ? const Color(0xFF4ecdc4)
                                  : const Color(0xFFffd93d))
                              .withValues(alpha:  0.4),
                          blurRadius: 12,
                          spreadRadius: 2,
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
}

// Alternative: Compact Icon Toggle
class ThemeToggleIcon extends StatelessWidget {
  const ThemeToggleIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return IconButton(
          onPressed: () {
            themeProvider.toggleTheme();
          },
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return RotationTransition(
                turns: animation,
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
            child: Icon(
              themeProvider.isDarkMode
                  ? Icons.dark_mode_rounded
                  : Icons.light_mode_rounded,
              key: ValueKey(themeProvider.isDarkMode),
              color: themeProvider.isDarkMode
                  ? const Color(0xFF4ecdc4)
                  : const Color(0xFFffd93d),
              size: 24,
            ),
          ),
        );
      },
    );
  }
}

// Settings Page Toggle with Label
class ThemeToggleWithLabel extends StatelessWidget {
  const ThemeToggleWithLabel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: themeProvider.glassmorphicColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: themeProvider.borderColor,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: themeProvider.isDarkMode
                        ? [
                            const Color(0xFF4ecdc4),
                            const Color(0xFF44a4a1),
                          ]
                        : [
                            const Color(0xFFffd93d),
                            const Color(0xFFfeca57),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  themeProvider.isDarkMode
                      ? Icons.dark_mode_rounded
                      : Icons.light_mode_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      themeProvider.isDarkMode ? 'Dark Mode' : 'Light Mode',
                      style: TextStyle(
                        color: themeProvider.textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap to switch theme',
                      style: TextStyle(
                        color: themeProvider.secondaryTextColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  themeProvider.toggleTheme();
                },
                child: Container(
                  width: 56,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: themeProvider.isDarkMode
                          ? [
                              const Color(0xFF4ecdc4),
                              const Color(0xFF44a4a1),
                            ]
                          : [
                              const Color(0xFFffd93d),
                              const Color(0xFFfeca57),
                            ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: (themeProvider.isDarkMode
                                ? const Color(0xFF4ecdc4)
                                : const Color(0xFFffd93d))
                            .withValues(alpha:  0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        left: themeProvider.isDarkMode ? 26 : 2,
                        top: 2,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha:  0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}