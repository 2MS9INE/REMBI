import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ── Model ─────────────────────────────────────────────────────────────────────

class NotificationEntry {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool isRead;

  const NotificationEntry({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    this.isRead = false,
  });

  NotificationEntry copyWith({bool? isRead}) => NotificationEntry(
    id: id,
    title: title,
    body: body,
    timestamp: timestamp,
    isRead: isRead ?? this.isRead,
  );

  factory NotificationEntry.fromJson(Map<String, dynamic> j) =>
      NotificationEntry(
        id: j['id'] as String,
        title: j['title'] as String,
        body: j['message'] as String, // ← DB column is "message"
        timestamp: DateTime.parse(j['created_at'] as String),
        isRead: j['is_read'] as bool? ?? false,
      );
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class NotificationLogNotifier extends Notifier<List<NotificationEntry>> {
  final _supabase = Supabase.instance.client;

  @override
  List<NotificationEntry> build() {
    _load();
    return [];
  }

  Future<void> _load() async {
    final uid = _supabase.auth.currentUser?.id;
    if (uid == null) return;

    final data = await _supabase
        .from('notifications')
        .select()
        .eq('user_id', uid)
        .order('created_at', ascending: false)
        .limit(30);

    state = (data as List)
        .map((e) => NotificationEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> markAllRead() async {
    final uid = _supabase.auth.currentUser?.id;
    if (uid == null) return;

    await _supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('user_id', uid)
        .eq('is_read', false);

    state = state.map((n) => n.copyWith(isRead: true)).toList();
  }

  Future<void> clearAll() async {
    final uid = _supabase.auth.currentUser?.id;
    if (uid == null) return;

    await _supabase.from('notifications').delete().eq('user_id', uid);

    state = [];
  }

  Future<void> refresh() => _load();

  bool get hasUnread => state.any((n) => !n.isRead);
}

final notificationLogProvider =
    NotifierProvider<NotificationLogNotifier, List<NotificationEntry>>(
      NotificationLogNotifier.new,
    );
