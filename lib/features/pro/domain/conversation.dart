/// Saqlangan suhbat xabari — matn (rasm tarixda saqlanmaydi, faqat matn).
class ChatMessage {
  ChatMessage(this.fromUser, this.text);
  final bool fromUser;
  final String text;

  Map<String, dynamic> toMap() => {'u': fromUser, 't': text};

  factory ChatMessage.fromMap(Map map) =>
      ChatMessage(map['u'] == true, (map['t'] ?? '').toString());
}

/// Bitta saqlangan suhbat — sarlavha + xabarlar. Hive 'conversations' box'ida,
/// shuning uchun ilova yopilsa ham yo'qolmaydi (ChatGPT/Claude kabi tarix).
class Conversation {
  Conversation({
    required this.id,
    required this.title,
    required this.category,
    required this.updatedAt,
    required this.messages,
  });

  final String id;
  String title;
  final String category; // 'chat' | 'analysis' | (kelajakda boshqalar)
  int updatedAt;
  final List<ChatMessage> messages;

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'category': category,
    'updatedAt': updatedAt,
    'messages': messages.map((m) => m.toMap()).toList(),
  };

  factory Conversation.fromMap(Map map) => Conversation(
    id: (map['id'] ?? '').toString(),
    title: (map['title'] ?? '').toString(),
    category: (map['category'] ?? 'chat').toString(),
    updatedAt: (map['updatedAt'] as int?) ?? 0,
    messages: ((map['messages'] as List?) ?? const [])
        .whereType<Map>()
        .map(ChatMessage.fromMap)
        .toList(),
  );
}
