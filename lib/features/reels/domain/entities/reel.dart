import 'package:equatable/equatable.dart';

class Reel extends Equatable {
  const Reel({
    required this.id,
    required this.username,
    required this.caption,
    required this.videoUrl,
    required this.likes,
    required this.isActive,
    this.createdAt,
  });

  final String id;
  final String username;
  final String caption;
  final String videoUrl;
  final int likes;
  final bool isActive;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [
    id,
    username,
    caption,
    videoUrl,
    likes,
    isActive,
    createdAt,
  ];
}
