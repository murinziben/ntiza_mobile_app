import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../providers/data_providers.dart';

export '../../core/utils/formatters.dart';

/// "N" logo tile used in headers.
class LogoMark extends StatelessWidget {
  const LogoMark({super.key, this.size = 36});
  final double size;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(size * 0.28),
        ),
        child: Text('N',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: size * 0.5)),
      );
}

/// Logo + wordmark + tagline.
class LogoLockup extends StatelessWidget {
  const LogoLockup({super.key, this.light = false, this.size = 36});
  final bool light;
  final double size;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          LogoMark(size: size),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('NTIZA',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: light ? Colors.white : AppColors.ink)),
              Text('Digital Agriculture Platform',
                  style: TextStyle(
                      fontSize: 11.5,
                      color: light ? Colors.white : AppColors.muted)),
            ],
          ),
        ],
      );
}

/// Local asset image with a neutral fallback.
class AssetPhoto extends StatelessWidget {
  const AssetPhoto(this.name, {super.key, this.height, this.width, this.radius = 0});
  final String name;
  final double? height;
  final double? width;
  final double radius;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: name.isEmpty
            ? Container(height: height, width: width, color: AppColors.neutral)
            : name.startsWith('http')
                ? Image.network(
                    name,
                    height: height,
                    width: width ?? double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Container(height: height, width: width, color: AppColors.neutral),
                  )
                : Image.asset(
                    'assets/images/$name',
                    height: height,
                    width: width ?? double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Container(height: height, width: width, color: AppColors.neutral),
                  ),
      );
}

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color = AppColors.white,
    this.onTap,
    this.borderColor = AppColors.border,
    this.radius = AppRadius.card,
  });
  final Widget child;
  final EdgeInsets padding;
  final Color color;
  final Color borderColor;
  final double radius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: BorderSide(color: borderColor),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      );
}

class Pill extends StatelessWidget {
  const Pill(this.label,
      {super.key,
      this.bg = AppColors.green100,
      this.fg = AppColors.primaryDark,
      this.big = false});
  final String label;
  final Color bg;
  final Color fg;
  final bool big;

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.symmetric(horizontal: big ? 14 : 11, vertical: big ? 7 : 5),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(99)),
        child: Text(label,
            style: TextStyle(
                color: fg, fontSize: big ? 13 : 12, fontWeight: FontWeight.w600)),
      );
}

/// Status chip mapped from a status keyword.
class StatusChip extends StatelessWidget {
  const StatusChip(this.status, {super.key});
  final String status;

  @override
  Widget build(BuildContext context) {
    final s = status.toLowerCase();
    Color bg = AppColors.neutral, fg = AppColors.body;
    if (['available', 'completed', 'paid', 'active', 'approved', 'verified', 'online']
        .contains(s)) {
      bg = AppColors.green100;
      fg = AppColors.primaryDark;
    } else if (['confirmed', 'in progress', 'info', 'open'].contains(s)) {
      bg = AppColors.blueBg;
      fg = AppColors.blue;
    } else if (['pending', 'booked', 'review', 'maintenance', 'under review'].contains(s)) {
      bg = AppColors.amberBg;
      fg = AppColors.amberText;
    } else if (s == 'expert') {
      bg = AppColors.purpleBg;
      fg = AppColors.purple;
    } else if (['cancelled', 'rejected', 'suspended', 'disputed', 'overdue'].contains(s)) {
      bg = AppColors.dangerBg;
      fg = AppColors.danger;
    }
    return Pill(status, bg: bg, fg: fg);
  }
}

class IconTile extends StatelessWidget {
  const IconTile(this.icon,
      {super.key,
      this.bg = AppColors.green100,
      this.fg = AppColors.primaryDark,
      this.size = 52,
      this.radius = 16});
  final IconData icon;
  final Color bg;
  final Color fg;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(radius)),
        child: Icon(icon, color: fg, size: size * 0.46),
      );
}

class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar(this.initials,
      {super.key,
      this.size = 52,
      this.bg = AppColors.green100,
      this.fg = AppColors.primaryDark});
  final String initials;
  final double size;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        child: Text(initials,
            style: TextStyle(
                color: fg, fontWeight: FontWeight.w700, fontSize: size * 0.3)),
      );
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton(this.label,
      {super.key, this.onPressed, this.height = 50, this.icon, this.expand = true});
  final String label;
  final VoidCallback? onPressed;
  final double height;
  final IconData? icon;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final btn = FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: Size(expand ? double.infinity : 0, height < 48 ? 48 : height),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
        textStyle: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w600),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
          Text(label),
        ],
      ),
    );
    return expand ? SizedBox(width: double.infinity, child: btn) : btn;
  }
}

class OutlineButtonX extends StatelessWidget {
  const OutlineButtonX(this.label,
      {super.key, this.onPressed, this.height = 50, this.expand = true, this.color});
  final String label;
  final VoidCallback? onPressed;
  final double height;
  final bool expand;
  final Color? color;

  @override
  Widget build(BuildContext context) => OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: color ?? AppColors.ink,
          side: const BorderSide(color: AppColors.border),
          minimumSize: Size(expand ? double.infinity : 0, height < 48 ? 48 : height),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
          textStyle: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w600),
        ),
        child: Text(label),
      );
}

/// Small green-tinted action button ("Book", "Approve" …).
class SoftButton extends StatelessWidget {
  const SoftButton(this.label,
      {super.key,
      this.onPressed,
      this.bg = AppColors.green100,
      this.fg = AppColors.primaryDark});
  final String label;
  final VoidCallback? onPressed;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) => Material(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onPressed,
          child: Container(
            constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: fg, fontWeight: FontWeight.w700, fontSize: 14.5)),
          ),
        ),
      );
}

/// White app bar with circular back button, bold title and optional bell.
class TopBar extends StatelessWidget implements PreferredSizeWidget {
  const TopBar(this.title, {super.key, this.back = true, this.bell = false, this.actions});
  final String title;
  final bool back;
  final bool bell;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            height: 64,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  if (back)
                    _Circle(
                      icon: Icons.chevron_left,
                      onTap: () =>
                          context.canPop() ? context.pop() : context.go('/home'),
                    )
                  else
                    const SizedBox(width: 8),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 19, fontWeight: FontWeight.w700, color: AppColors.ink)),
                  ),
                  ...?actions,
                  if (bell) const BellIcon(),
                ],
              ),
            ),
          ),
        ),
      );
}

class _Circle extends StatelessWidget {
  const _Circle({required this.icon, this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: AppColors.neutral,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(width: 48, height: 48, child: Icon(icon, color: AppColors.ink)),
        ),
      );
}

class BellIcon extends ConsumerWidget {
  const BellIcon({super.key, this.light = false});
  final bool light;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(unreadCountProvider);
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(Icons.notifications_none, size: 26, color: light ? Colors.white : AppColors.ink),
          if (unread > 0)
            Positioned(
              right: 2,
              top: 1,
              child: Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: AppColors.danger,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.action, this.onAction});
  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 19, fontWeight: FontWeight.w700, color: AppColors.ink)),
          if (action != null)
            GestureDetector(
              onTap: onAction,
              child: Text(action!,
                  style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary)),
            ),
        ],
      );
}

/// Horizontal scrolling pill filter.
class ChipRow extends StatelessWidget {
  const ChipRow(
      {super.key,
      required this.labels,
      required this.selected,
      required this.onSelected,
      this.padding = const EdgeInsets.symmetric(horizontal: 16)});
  final List<String> labels;
  final String selected;
  final ValueChanged<String> onSelected;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 48,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: padding,
          itemCount: labels.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (_, i) {
            final on = labels[i] == selected;
            return GestureDetector(
              onTap: () => onSelected(labels[i]),
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  color: on ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(color: on ? AppColors.primary : AppColors.border),
                ),
                child: Text(labels[i],
                    style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: on ? Colors.white : AppColors.ink)),
              ),
            );
          },
        ),
      );
}

class SearchField extends StatelessWidget {
  const SearchField({super.key, required this.hint, this.onChanged, this.filter = true});
  final String hint;
  final ValueChanged<String>? onChanged;
  final bool filter;

  @override
  Widget build(BuildContext context) => Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.input),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: AppColors.muted),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                onChanged: onChanged,
                style: const TextStyle(fontSize: 15),
                decoration: InputDecoration.collapsed(
                  hintText: hint,
                  hintStyle: const TextStyle(color: AppColors.faint),
                ),
              ),
            ),
            if (filter) const Icon(Icons.filter_alt_outlined, color: AppColors.primary),
          ],
        ),
      );
}

class RatingLine extends StatelessWidget {
  const RatingLine(this.rating, this.suffix, {super.key});
  final double rating;
  final String suffix;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 16, color: AppColors.amber),
          const SizedBox(width: 4),
          Text('${rating.toStringAsFixed(1)} · $suffix',
              style: const TextStyle(fontSize: 13.5, color: AppColors.muted)),
        ],
      );
}

class StatTile extends StatelessWidget {
  const StatTile(this.value, this.label,
      {super.key, this.icon, this.bg = AppColors.green100, this.fg = AppColors.primaryDark});
  final String value;
  final String label;
  final IconData? icon;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null) ...[Icon(icon, color: fg, size: 20), const SizedBox(height: 8)],
            Text(value,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: fg)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 12.5, color: fg)),
          ],
        ),
      );
}

/// Labelled text field used by auth/forms.
/// Whether a password field currently hides its text (keyed by field label).
final _hidePasswordProvider =
    StateProvider.autoDispose.family<bool, String>((ref, label) => true);

/// A labelled text input with inline validation. Use inside a `Form` and call
/// `formKey.currentState!.validate()` to show every error at once.
class LabeledField extends ConsumerWidget {
  const LabeledField(this.label,
      {super.key,
      required this.hint,
      this.icon,
      this.obscure = false,
      this.controller,
      this.keyboard,
      this.validator,
      this.textInputAction,
      this.autofillHints,
      this.maxLines = 1,
      this.enabled = true,
      this.onChanged,
      this.onSubmitted});
  final String label;
  final String hint;
  final IconData? icon;
  final bool obscure;
  final TextEditingController? controller;
  final TextInputType? keyboard;
  final FormFieldValidator<String>? validator;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final int maxLines;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hidden = obscure && ref.watch(_hidePasswordProvider(label));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.body)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: hidden,
          keyboardType: keyboard,
          validator: validator,
          enabled: enabled,
          maxLines: obscure ? 1 : maxLines,
          textInputAction: textInputAction,
          autofillHints: autofillHints,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.faint),
            prefixIcon: icon == null ? null : Icon(icon, color: AppColors.muted),
            suffixIcon: obscure
                ? IconButton(
                    tooltip: hidden ? 'Show password' : 'Hide password',
                    icon: Icon(hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: AppColors.muted),
                    onPressed: () =>
                        ref.read(_hidePasswordProvider(label).notifier).state = !hidden,
                  )
                : null,
          ),
        ),
      ],
    );
  }
}

void showToast(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
