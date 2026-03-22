import 'package:reels_assignment/core/bloc/base_state.dart';
import 'package:reels_assignment/core/error/failures.dart';

final class ReelLikesState extends BaseState {
  const ReelLikesState({
    this.likeCounts = const <String, int>{},
    this.likedReelIds = const <String>{},
    this.syncingReelIds = const <String>{},
    this.failuresByReelId = const <String, Failure>{},
  });

  final Map<String, int> likeCounts;
  final Set<String> likedReelIds;
  final Set<String> syncingReelIds;
  final Map<String, Failure> failuresByReelId;

  bool isLiked(String reelId) => likedReelIds.contains(reelId);

  bool isSyncing(String reelId) => syncingReelIds.contains(reelId);

  int likesFor({required String reelId, required int fallbackLikes}) {
    return likeCounts[reelId] ?? fallbackLikes;
  }

  Failure? failureFor(String reelId) => failuresByReelId[reelId];

  ReelLikesState copyWith({
    Map<String, int>? likeCounts,
    Set<String>? likedReelIds,
    Set<String>? syncingReelIds,
    Map<String, Failure>? failuresByReelId,
  }) {
    return ReelLikesState(
      likeCounts: likeCounts ?? this.likeCounts,
      likedReelIds: likedReelIds ?? this.likedReelIds,
      syncingReelIds: syncingReelIds ?? this.syncingReelIds,
      failuresByReelId: failuresByReelId ?? this.failuresByReelId,
    );
  }

  @override
  List<Object?> get props => [
    _mapSignature(
      likeCounts.entries.map((entry) => '${entry.key}:${entry.value}'),
    ),
    _iterableSignature(likedReelIds),
    _iterableSignature(syncingReelIds),
    _mapSignature(
      failuresByReelId.entries.map(
        (entry) => '${entry.key}:${entry.value.message}',
      ),
    ),
  ];

  String _iterableSignature(Iterable<String> values) {
    final sorted = values.toList()..sort();
    return sorted.join('|');
  }

  String _mapSignature(Iterable<String> values) {
    final sorted = values.toList()..sort();
    return sorted.join('|');
  }
}
