import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import '../domain/conversation.dart';

/// Saqlangan suhbatlar ro'yxati — Hive 'conversations' box'idan o'qiydi/yozadi.
/// Eng oxirgi yangilangani birinchi (updatedAt bo'yicha).
final conversationsProvider =
    NotifierProvider<ConversationsNotifier, List<Conversation>>(
      ConversationsNotifier.new,
    );

class ConversationsNotifier extends Notifier<List<Conversation>> {
  Box? get _box {
    try {
      return Hive.box('conversations');
    } catch (_) {
      return null;
    }
  }

  @override
  List<Conversation> build() {
    final box = _box;
    if (box == null) return const [];
    final list = <Conversation>[];
    for (final v in box.values) {
      if (v is Map) {
        try {
          list.add(Conversation.fromMap(v));
        } catch (_) {}
      }
    }
    list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return list;
  }

  /// Yangi bo'sh suhbat yaratadi va uni qaytaradi.
  Conversation create({String category = 'chat'}) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final c = Conversation(
      id: 'c$now',
      title: '',
      category: category,
      updatedAt: now,
      messages: [],
    );
    _box?.put(c.id, c.toMap());
    state = [c, ...state];
    return c;
  }

  /// Suhbat xabarlarini saqlaydi (almashuvdan keyin chaqiriladi).
  void save(String id, List<ChatMessage> messages, {String? title}) {
    final box = _box;
    if (box == null) return;
    final idx = state.indexWhere((c) => c.id == id);
    if (idx < 0) return;
    final c = state[idx];
    c.messages
      ..clear()
      ..addAll(messages);
    c.updatedAt = DateTime.now().millisecondsSinceEpoch;
    if (title != null && title.trim().isNotEmpty && c.title.isEmpty) {
      final tt = title.trim();
      c.title = tt.length > 42 ? '${tt.substring(0, 42)}…' : tt;
    }
    box.put(c.id, c.toMap());
    state = [...state]..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  void delete(String id) {
    _box?.delete(id);
    state = state.where((c) => c.id != id).toList();
  }
}
