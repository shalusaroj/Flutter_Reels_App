import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reels_assignment/features/reels/domain/entities/reel.dart';

class ReelModel extends Reel {
  const ReelModel({
    required super.id,
    required super.username,
    required super.caption,
    required super.videoUrl,
    required super.likes,
    required super.isActive,
    super.createdAt,
  });

  factory ReelModel.fromMap(Map<String, dynamic> map) {
    final username = _readFirstString(map, ['username', 'userName', 'user']);

    return ReelModel(
      id: (map['id'] ?? '').toString(),
      username: username.isNotEmpty ? username : 'unknown_user',
      caption: _readFirstString(map, ['caption', 'description', 'desc']),
      videoUrl: _readFirstString(map, [
        'videoUrl',
        'videoURL',
        'video_url',
        'url',
      ]),
      likes: _asInt(map['likes']),
      isActive: map.containsKey('isActive') ? _asBool(map['isActive']) : true,
      createdAt: _asDateTime(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'caption': caption,
      'videoUrl': videoUrl,
      'likes': likes,
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toLocalMap() {
    return {
      'id': id,
      'username': username,
      'caption': caption,
      'videoUrl': videoUrl,
      'likes': likes,
      'isActive': isActive ? 1 : 0,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  static int _asInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static bool _asBool(dynamic value) {
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }
    final normalized = (value?.toString() ?? '').trim().toLowerCase();
    return normalized == 'true' || normalized == '1';
  }

  static DateTime? _asDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  static String _readFirstString(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final value = map[key];
      if (value == null) {
        continue;
      }
      final parsed = value.toString().trim();
      if (parsed.isNotEmpty) {
        return parsed;
      }
    }
    return '';
  }
}
