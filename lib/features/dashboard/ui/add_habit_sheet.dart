import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/state/app_settings.dart';
import '../../../core/theme/app_colors.dart';
import '../../habits/state/habits_notifier.dart';

/// Yangi odat qo'shish oynasi (pastdan chiqadigan sheet).
Future<void> showAddHabitSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => const _AddHabitSheet(),
  );
}

class _AddHabitSheet extends ConsumerStatefulWidget {
  const _AddHabitSheet();

  @override
  ConsumerState<_AddHabitSheet> createState() => _AddHabitSheetState();
}

class _AddHabitSheetState extends ConsumerState<_AddHabitSheet> {
  final _controller = TextEditingController();
  final _customController = TextEditingController();
  int _goalMinutes = 25;
  int _colorIndex = 0;
  String _emoji = '🎯';

  static const _presetMinutes = [1, 15, 25, 45, 60];
  static const _emojis = <String>[
    '🎯', '📚', '💪', '🧠', '🏃', '🧘', '✍️', '💧',
    '🎨', '🎸', '💻', '🌙', '☀️', '🔥', '🌱', '⭐', //
  ];

  @override
  void dispose() {
    _controller.dispose();
    _customController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    ref.read(habitsProvider.notifier).addHabit(
          name: name,
          goalMs: _goalMinutes * 60 * 1000,
          colorValue: AppColors.habitColors[_colorIndex].toARGB32(),
          emoji: _emoji,
        );
    Navigator.of(context).pop();
  }

  void _selectPreset(int m) {
    setState(() {
      _goalMinutes = m;
      _customController.clear();
    });
  }

  void _onCustom(String v) {
    final n = int.tryParse(v.trim());
    if (n != null && n > 0 && n <= 600) {
      setState(() => _goalMinutes = n);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(l10nProvider);
    final scheme = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isPreset = _presetMinutes.contains(_goalMinutes);

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 8, 20, 20 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.newHabit, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            // Emoji (belgi) tanlagich
            Text(t.avatarLabel,
                style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13)),
            const SizedBox(height: 8),
            SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _emojis.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final e = _emojis[i];
                  final sel = _emoji == e;
                  return GestureDetector(
                    onTap: () => setState(() => _emoji = e),
                    child: Container(
                      width: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: sel
                            ? scheme.primaryContainer
                            : scheme.surfaceContainerHighest
                                .withValues(alpha: 0.4),
                        border: Border.all(
                          color: sel ? scheme.primary : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Text(e, style: const TextStyle(fontSize: 22)),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: t.habitNameLabel,
                hintText: t.habitNameExample,
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (_) => _save(),
            ),
            const SizedBox(height: 20),
            Text(t.goalMinutesLabel),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                for (final m in _presetMinutes)
                  ChoiceChip(
                    label: Text('$m'),
                    selected: isPreset && _goalMinutes == m,
                    onSelected: (_) => _selectPreset(m),
                  ),
                // Qo'lda vaqt kiritish
                SizedBox(
                  width: 104,
                  child: TextField(
                    controller: _customController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: t.customMinutes,
                      isDense: true,
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: _onCustom,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(t.colorLabel),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (int i = 0; i < AppColors.habitColors.length; i++)
                  GestureDetector(
                    onTap: () => setState(() => _colorIndex = i),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.habitColors[i],
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _colorIndex == i
                              ? Colors.white
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _save,
                child: Text(t.add),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
