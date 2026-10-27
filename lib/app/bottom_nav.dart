import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../widgets/pressable_3d.dart';
import '../theme/app_sizes.dart';
import '../theme/app_text.dart';
import '../art/icons/kid_icon.dart';

class _Tab {
  const _Tab(this.label, this.icon, this.color, this.ledge);
  final String label;
  final KidIcon icon;
  final Color color;
  final Color ledge;
}

/// Home · Plants · Quiz · Shop · Profile. The selected tab sits on a
/// colored chunky pill; every tab is a full-height tap target.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key, required this.currentIndex, required this.onTap, this.dotIndex});

  static const shopIndex = 3;

  final int currentIndex;
  final ValueChanged<int> onTap;

  /// A tab with news (the Shop when something new is affordable).
  final int? dotIndex;

  static const _tabs = [
    _Tab('Home', KidIcon.home, AppColors.leaf, AppColors.leafDark),
    _Tab('Plants', KidIcon.plants, AppColors.teal, AppColors.tealDark),
    _Tab('Quiz', KidIcon.quiz, AppColors.grape, AppColors.grapeDark),
    _Tab('Shop', KidIcon.shop, AppColors.sunshine, AppColors.sunshineDark),
    _Tab('Profile', KidIcon.profile, AppColors.coral, AppColors.coralDark),
  ];

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(
          top: BorderSide(color: AppColors.border, width: AppSizes.borderWidth),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          // Grows with the phone's text size so the labels never squeeze.
          height: 58 + MediaQuery.textScalerOf(context).scale(18),
          child: Row(
            children: [
              for (final (i, tab) in _tabs.indexed)
                Expanded(
                  child: Semantics(
                    selected: i == currentIndex,
                    button: true,
                    label: i == dotIndex ? '${tab.label}, something new' : tab.label,
                    excludeSemantics: true,
                    child: InkResponse(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        PressFeedback.onPress?.call();
                        onTap(i);
                      },
                      highlightShape: BoxShape.rectangle,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                width: 54,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: i == currentIndex
                                      ? Color.lerp(tab.color, AppColors.card, 0.55)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(AppSizes.radiusS),
                                  boxShadow: i == currentIndex
                                      ? [BoxShadow(color: tab.ledge, offset: const Offset(0, 3))]
                                      : null,
                                ),
                                child: KidIconView(tab.icon, size: AppSizes.iconMedium, muted: i != currentIndex),
                              ),
                              if (i == dotIndex)
                                Positioned(
                                  right: 2,
                                  top: -3,
                                  child: Container(
                                    width: 14,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      color: AppColors.coral,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: AppColors.card, width: 2),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            tab.label,
                            style: AppText.label.copyWith(
                              fontSize: 13,
                              color: i == currentIndex ? AppColors.text : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
