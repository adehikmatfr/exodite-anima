import 'package:flutter/material.dart';

import '../data/entry_repository.dart';
import '../l10n/strings.dart';
import '../theme/app_icons.dart';
import '../theme/tokens.dart';

/// The mood picker (FEAT-010 AC-1, AC-2). Tapping the selected mood again
/// clears it: the icon alone never carries the meaning, so every option
/// always shows its text label too (accessibility NFR, `ux-design` F8).
class MoodPicker extends StatelessWidget {
  const MoodPicker({super.key, required this.selected, required this.onChanged});
  final Mood? selected;
  final ValueChanged<Mood?> onChanged;

  @override
  Widget build(BuildContext context) {
    // Each option takes an equal share of the width: five fixed 64 dp columns
    // (320 dp) overflowed a 360 dp phone's 312 dp of content.
    return Row(
      children: [
        for (final mood in Mood.values)
          Expanded(child: _MoodOption(mood: mood, selected: mood == selected, onChanged: onChanged)),
      ],
    );
  }
}

class _MoodOption extends StatelessWidget {
  const _MoodOption({required this.mood, required this.selected, required this.onChanged});
  final Mood mood;
  final bool selected;
  final ValueChanged<Mood?> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final label = S.moodLabel(mood);
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      hint: selected ? S.clearMood : null,
      excludeSemantics: true,
      child: InkWell(
        onTap: () => onChanged(selected ? null : mood),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: SizedBox(
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? c.actionBg : Colors.transparent,
                  border: selected ? null : Border.all(color: c.borderStrong),
                ),
                child: Icon(
                  AppIcons.moods[mood.index],
                  color: selected ? c.actionFg : c.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpace.s4),
              Text(
                label,
                style: AppType.caption.copyWith(color: selected ? c.actionBg : c.textSecondary),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The tag input (FEAT-010 AC-3, AC-4): preset chips the writer can toggle,
/// plus free text. Both kinds are plain strings once saved; nothing tells
/// them apart (ADR-002 update 2026-09-23).
class TagInput extends StatelessWidget {
  const TagInput({super.key, required this.tags, required this.onChanged});
  final List<String> tags;
  final ValueChanged<List<String>> onChanged;

  Future<void> _addFreeTag(BuildContext context) async {
    final controller = TextEditingController();
    final typed = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(S.addTag),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(hintText: S.addTagHint),
          onSubmitted: (v) => Navigator.of(dialogContext).pop(v),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: Text(S.cancel)),
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(controller.text), child: Text(S.done)),
        ],
      ),
    );
    final name = typed?.trim();
    if (name == null || name.isEmpty || tags.contains(name)) return;
    onChanged([...tags, name]);
  }

  void _toggle(String tag) {
    onChanged(tags.contains(tag) ? (tags.where((t) => t != tag).toList()) : [...tags, tag]);
  }

  @override
  Widget build(BuildContext context) {
    final freeTags = tags.where((t) => !presetTags.contains(t));
    return Wrap(
      spacing: AppSpace.s8,
      runSpacing: AppSpace.s8,
      children: [
        for (final preset in presetTags) _TagChip(label: S.presetTagLabel(preset), selected: tags.contains(preset), onTap: () => _toggle(preset)),
        for (final free in freeTags) _TagChip(label: free, selected: true, onTap: () => _toggle(free)),
        _TagChip(label: S.addTag, selected: false, leading: AppIcons.add, onTap: () => _addFreeTag(context)),
      ],
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label, required this.selected, required this.onTap, this.leading});
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? leading;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppSpace.touchMin),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.s12),
            decoration: BoxDecoration(
              color: selected ? c.actionBg : Colors.transparent,
              borderRadius: BorderRadius.circular(999),
              border: selected ? null : Border.all(color: c.borderStrong),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (leading != null) ...[
                  Icon(leading, size: 16, color: selected ? c.actionFg : c.textPrimary),
                  const SizedBox(width: AppSpace.s4),
                ],
                Text(label, style: AppType.caption.copyWith(color: selected ? c.actionFg : c.textPrimary)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
