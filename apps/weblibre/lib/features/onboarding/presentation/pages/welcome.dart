/*
 * Copyright (c) 2024-2026 Fabian Freund.
 *
 * This file is part of WebLibre
 * (see https://weblibre.eu).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
import 'package:fading_scroll/fading_scroll.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/design/app_colors.dart';
import 'package:weblibre/features/onboarding/domain/entities/onboarding_mode.dart';
import 'package:weblibre/features/onboarding/domain/providers.dart';
import 'package:weblibre/presentation/widgets/browser_page.dart';
import 'package:weblibre/presentation/widgets/pointer_scrollable_sheet.dart';

class WelcomePage extends ConsumerWidget {
  final bool isReturningUser;

  const WelcomePage({super.key, this.isReturningUser = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final selectedMode = ref.watch(onboardingModeProvider);
    final accepted = ref.watch(eulaAcceptedProvider);

    return BrowserPage(
      child: BrowserPageContent(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            BrandHeader(colorScheme: colorScheme),
            const SizedBox(height: 24),
            Text(
              isReturningUser ? 'Welcome back!' : 'WebLibre is ready',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            if (isReturningUser) ...[
              const SizedBox(height: 16),
              _UpdateNotice(colorScheme: colorScheme, theme: theme),
            ],
            if (!isReturningUser) ...[
              const SizedBox(height: 40),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Choose your onboarding experience:',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _ModeOption(
                mode: OnboardingMode.express,
                title: 'Quick Start',
                subtitle: 'Use recommended defaults and get browsing.',
                icon: Icons.bolt,
                selected: selectedMode == OnboardingMode.express,
                onTap: () => ref
                    .read(onboardingModeProvider.notifier)
                    .select(OnboardingMode.express),
              ),
              const SizedBox(height: 12),
              _ModeOption(
                mode: OnboardingMode.detailed,
                title: 'Custom Setup',
                subtitle: 'Configure DNS, toolbar, extensions, and more.',
                icon: Icons.tune,
                selected: selectedMode == OnboardingMode.detailed,
                onTap: () => ref
                    .read(onboardingModeProvider.notifier)
                    .select(OnboardingMode.detailed),
              ),
              const SizedBox(height: 12),
              _ModeOption(
                mode: OnboardingMode.restore,
                title: 'Restore from Backup',
                subtitle: 'Import a profile from an encrypted backup file.',
                icon: Icons.settings_backup_restore,
                selected: selectedMode == OnboardingMode.restore,
                onTap: () => ref
                    .read(onboardingModeProvider.notifier)
                    .select(OnboardingMode.restore),
              ),
            ],
            const SizedBox(height: 40),
            _EulaCheckbox(
              accepted: accepted,
              onAcceptedChanged: (value) =>
                  ref.read(eulaAcceptedProvider.notifier).accept(value),
            ),
          ],
        ),
      ),
    );
  }
}

class _UpdateNotice extends StatelessWidget {
  final ColorScheme colorScheme;
  final ThemeData theme;

  const _UpdateNotice({required this.colorScheme, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    color: AppColors.of(context).brandLink,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'A lot has changed!',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'This update includes significant changes that require '
                'you to review your settings. Please walk through the '
                'following pages to revalidate your configuration.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.extension,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Please re-check your extensions after this update '
                      'due to known migration issues.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.shield_outlined,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your existing settings will not be overridden '
                      'unless you explicitly change them during this setup.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ModeOption extends StatelessWidget {
  final OnboardingMode mode;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ModeOption({
    required this.mode,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: selected
              ? colorScheme.primaryContainer.withValues(alpha: 0.4)
              : colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? colorScheme.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected
                  ? AppColors.of(context).brandLink
                  : colorScheme.onSurfaceVariant,
              size: 28,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: selected
                          ? colorScheme.onSurface
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: selected
                          ? colorScheme.onSurfaceVariant
                          : colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
            if (selected) Icon(Icons.check_circle, color: colorScheme.primary),
          ],
        ),
      ),
    );
  }
}

class _EulaCheckbox extends StatelessWidget {
  final bool accepted;
  final ValueChanged<bool> onAcceptedChanged;

  const _EulaCheckbox({
    required this.accepted,
    required this.onAcceptedChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return CheckboxListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      value: accepted,
      controlAffinity: ListTileControlAffinity.leading,
      onChanged: (value) => onAcceptedChanged(value ?? false),
      title: Wrap(
        children: [
          Text(
            'I have read and accept the ',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          GestureDetector(
            onTap: () => _showLegalDocument(
              context,
              title: 'End User License Agreement',
              assetPath: 'assets/legal/EULA.md',
            ),
            child: Text(
              'EULA',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.of(context).brandLink,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.of(context).brandLink,
              ),
            ),
          ),
          Text(
            ' and ',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          GestureDetector(
            onTap: () => _showLegalDocument(
              context,
              title: 'Privacy Policy',
              assetPath: 'assets/legal/PRIVACY_POLICY.md',
            ),
            child: Text(
              'Privacy Policy',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.of(context).brandLink,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.of(context).brandLink,
              ),
            ),
          ),
          Text(
            '.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showLegalDocument(
    BuildContext context, {
    required String title,
    required String assetPath,
  }) async {
    final content = await rootBundle.loadString(assetPath);

    if (!context.mounted) return;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => PointerScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: FadingScroll(
                controller: scrollController,
                fadingSize: 25,
                builder: (context, controller) {
                  return Markdown(controller: controller, data: content);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
