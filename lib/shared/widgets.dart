import 'package:flutter/material.dart';

import '../domain/brand.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 28});
  final double size;

  @override
  Widget build(BuildContext context) {
    final scale = size / AppBrand.markViewBox;
    final stroke = (AppBrand.markStrokeWidth * scale).clamp(1.0, 2.5);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          _MarkFrame(rect: AppBrand.markBack, scale: scale, fill: AppBrand.ink, stroke: stroke),
          _MarkFrame(rect: AppBrand.markFront, scale: scale, fill: AppBrand.sky, stroke: stroke),
        ],
      ),
    );
  }
}

class _MarkFrame extends StatelessWidget {
  const _MarkFrame({
    required this.rect,
    required this.scale,
    required this.fill,
    required this.stroke,
  });

  final Rect rect;
  final double scale;
  final Color fill;
  final double stroke;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: rect.left * scale,
      top: rect.top * scale,
      width: rect.width * scale,
      height: rect.height * scale,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(AppBrand.markRadius * scale),
          border: Border.all(color: AppBrand.slate, width: stroke),
        ),
      ),
    );
  }
}

/// Mark + product name, matching the web top-bar lockup.
class BrandLockup extends StatelessWidget {
  const BrandLockup({super.key, this.pageTitle, this.markSize = 28});

  final String? pageTitle;
  final double markSize;

  @override
  Widget build(BuildContext context) {
    final page = pageTitle?.trim();
    final showPage =
        page != null && page.isNotEmpty && page != AppBrand.name;
    return Row(
      children: [
        BrandMark(size: markSize),
        const SizedBox(width: 10),
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppBrand.name.toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      letterSpacing: 1.6,
                      fontWeight: FontWeight.w700,
                      color: AppBrand.slate,
                    ),
              ),
              if (showPage)
                Text(
                  page,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class ShotKitAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ShotKitAppBar({
    super.key,
    this.title,
    this.actions,
    this.automaticallyImplyLeading = true,
  });

  final String? title;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: automaticallyImplyLeading,
      titleSpacing: 16,
      title: BrandLockup(pageTitle: title),
      actions: actions,
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BrandMark(size: 48),
            const SizedBox(height: 20),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppBrand.slate,
                  ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

class ErrorBanner extends StatelessWidget {
  const ErrorBanner(this.message, {super.key});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      ),
    );
  }
}

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: AppBrand.slate,
            letterSpacing: 0.6,
          ),
    );
  }
}
