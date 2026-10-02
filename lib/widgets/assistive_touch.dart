import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:minimal_music_player/core/theme/theme_provider.dart';
import 'package:minimal_music_player/providers/playlist_provider.dart';
import 'package:minimal_music_player/main.dart'; // for appNavigatorKey
import 'dart:math';
import 'dart:ui';
import 'package:flutter/services.dart';

class AssistiveTouchWidget extends StatefulWidget {
  const AssistiveTouchWidget({super.key});

  @override
  State<AssistiveTouchWidget> createState() => _AssistiveTouchWidgetState();
}

class _AssistiveTouchWidgetState extends State<AssistiveTouchWidget> {
  static const platform = MethodChannel(
    'com.example.minimal_music_player/system',
  );
  Offset position = const Offset(20, 100);
  bool isDragging = false;

  void _snapToEdge(Size screenSize) {
    double newX = position.dx < screenSize.width / 2
        ? 10
        : screenSize.width - 70;
    double newY = max(50.0, min(position.dy, screenSize.height - 120.0));

    setState(() {
      position = Offset(newX, newY);
      isDragging = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    if (!themeProvider.isAssistiveTouchEnabled) {
      return const SizedBox.shrink();
    }

    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final musicProvider = context.read<MusicProvider>();

    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        onPanStart: (_) {
          setState(() => isDragging = true);
        },
        onPanUpdate: (details) {
          setState(() {
            position += details.delta;
          });
        },
        onPanEnd: (details) {
          _snapToEdge(size);
        },
        onTap: () {
          if (appNavigatorKey.currentContext != null) {
            _showActionMenu(
              appNavigatorKey.currentContext!,
              musicProvider,
              theme,
            );
          }
        },
        child: AnimatedOpacity(
          opacity: isDragging ? 1.0 : 0.6,
          duration: const Duration(milliseconds: 200),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.2),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary.withValues(alpha: 0.4),
                          theme.colorScheme.primary.withValues(alpha: 0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.adjust_rounded,
                      color: theme.colorScheme.primary,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showActionMenu(
    BuildContext context,
    MusicProvider provider,
    ThemeData theme,
  ) {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (ctx) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(45),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  width: 260,
                  height: 90,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(45),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.2),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildIphoneBtn(
                        Icons.volume_down_rounded,
                        () async {
                          try {
                            await platform.invokeMethod('volDown');
                          } catch (e) {
                            provider.setVolume(provider.volume - 0.1);
                          }
                        },
                        theme,
                        extraText: "-",
                      ),

                      _buildIphoneBtn(Icons.home_rounded, () {
                        Navigator.pop(ctx);
                        SystemNavigator.pop();
                      }, theme),

                      _buildIphoneBtn(
                        Icons.volume_up_rounded,
                        () async {
                          try {
                            await platform.invokeMethod('volUp');
                          } catch (e) {
                            provider.setVolume(provider.volume + 0.1);
                          }
                        },
                        theme,
                        extraText: "+",
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildIphoneBtn(
    IconData icon,
    VoidCallback onTap,
    ThemeData theme, {
    String? extraText,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: theme.colorScheme.primary,
                  size: extraText != null ? 24 : 30,
                ),
                if (extraText != null) ...[
                  Text(
                    extraText,
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
