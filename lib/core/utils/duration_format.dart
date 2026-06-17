/// Millisekundlarni "MM:SS" yoki (1 soatdan oshsa) "HH:MM:SS" ko'rinishiga aylantiradi.
String formatDuration(int milliseconds, {bool roundUp = false}) {
  final ms = milliseconds < 0 ? 0 : milliseconds;
  // roundUp=true -> qolgan vaqt uchun yuqoriga yaxlitlaymiz (o'tgan + qolgan = maqsad).
  final totalSeconds = roundUp ? ((ms + 999) ~/ 1000) : (ms ~/ 1000);
  final hours = totalSeconds ~/ 3600;
  final minutes = (totalSeconds % 3600) ~/ 60;
  final seconds = totalSeconds % 60;
  String two(int n) => n.toString().padLeft(2, '0');
  if (hours > 0) return '${two(hours)}:${two(minutes)}:${two(seconds)}';
  return '${two(minutes)}:${two(seconds)}';
}
