import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  int _goalMinutes = 25;
  int _colorIndex = 0;

  static const _presetMinutes = [1, 15, 25, 45, 60];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    ref.read(habitsProvider.notifier).addHabit(
          name: name,
          goalMs: _goalMinutes * 60 * 1000,
          colorValue: AppColors.habitColors[_colorIndex].toARGB32(),
        );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 8, 20, 20 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Yangi odat', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Nomi',
              hintText: "Masalan: Kitob o'qish",
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => _save(),
          ),
          const SizedBox(height: 20),
          const Text('Maqsad (daqiqa)'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final m in _presetMinutes)
                ChoiceChip(
                  label: Text('$m'),
                  selected: _goalMinutes == m,
                  onSelected: (_) => setState(() => _goalMinutes = m),
                ),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Rang'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
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
                        color: _colorIndex == i ? Colors.white : Colors.transparent,
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
              child: const Text("Qo'shish"),
            ),
          ),
        ],
      ),
    );
  }
}
