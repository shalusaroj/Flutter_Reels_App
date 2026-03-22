import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reels_assignment/core/constants/app_constants.dart';
import 'package:reels_assignment/core/data/base_data_source.dart';
import 'package:reels_assignment/core/data/firebase_data_client.dart';
import 'package:reels_assignment/core/error/exceptions.dart';
import 'package:reels_assignment/features/reels/data/datasources/reels_data_source.dart';
import 'package:reels_assignment/features/reels/data/models/reel_model.dart';

class ReelsRemoteDataSourceImpl extends BaseDataSource<FirebaseDataClient>
    implements ReelsRemoteDataSource {
  const ReelsRemoteDataSourceImpl({required FirebaseDataClient client})
    : super(client);

  @override
  Future<List<ReelModel>> getReelsPage({
    required int pageSize,
    DateTime? cursorCreatedAt,
  }) async {
    final safeLimit = pageSize.clamp(1, AppConstants.reelsFetchLimit);

    Query<Map<String, dynamic>> query = client.firestore
        .collection(AppConstants.reelsCollection)
        .orderBy('createdAt', descending: true)
        .limit(safeLimit);

    if (cursorCreatedAt != null) {
      query = query.startAfter([Timestamp.fromDate(cursorCreatedAt.toUtc())]);
    }

    final snapshot = await query.get();
    final items =
        snapshot.docs
            .map((doc) => <String, dynamic>{...doc.data(), 'id': doc.id})
            .toList();

    final models =
        items
            .map(ReelModel.fromMap)
            .where((reel) => reel.videoUrl.isNotEmpty)
            .where((reel) => reel.isActive)
            .toList()
          ..sort((a, b) {
            final aTime = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            final bTime = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            return bTime.compareTo(aTime);
          });

    return models;
  }

  @override
  Future<void> seedDemoReels() async {
    final now = DateTime.now().toUtc();
    const videoUrls = <String>[
      'https://samplelib.com/lib/preview/mp4/sample-5s.mp4',
      'https://samplelib.com/lib/preview/mp4/sample-10s.mp4',
      'https://samplelib.com/lib/preview/mp4/sample-15s.mp4',
      'https://samplelib.com/lib/preview/mp4/sample-20s.mp4',
      'https://samplelib.com/lib/preview/mp4/sample-30s.mp4',
      'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
      'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
      'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4',
      'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
      'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
      'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4',
      'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4',
    ];

    const usernames = <String>[
      'nature.loop',
      'travel.bits',
      'city.frames',
      'open.video',
      'demo.story',
      'motion.lab',
      'clip.stream',
      'frame.factory',
      'shorts.deck',
      'daily.reels',
    ];

    const captions = <String>[
      'Calm ocean scene for demo playback',
      'Short travel cut with smooth motion',
      'Urban vibe sample reel',
      'Public sample from media bucket',
      'Pagination flow testing reel',
      'Motion-heavy clip for smooth scrolling',
      'Quick visual loop for autoplay checks',
      'Feed continuity sample',
      'Gesture test reel for interactions',
      'Like animation and progress bar demo',
    ];

    final demoReels = List<Map<String, dynamic>>.generate(50, (index) {
      final ordinal = index + 1;
      return <String, dynamic>{
        'id': 'demo_reel_$ordinal',
        'username': usernames[index % usernames.length],
        'caption': '${captions[index % captions.length]} #$ordinal',
        'videoUrl': videoUrls[index % videoUrls.length],
        'likes': 40 + ((index * 17) % 900),
        'isActive': true,
        'createdAt': now.subtract(Duration(minutes: index)),
      };
    });

    final collection = client.firestore.collection(
      AppConstants.reelsCollection,
    );
    final batch = client.firestore.batch();

    for (final reel in demoReels) {
      final reelId = reel['id'] as String;
      final payload = Map<String, dynamic>.from(reel)..remove('id');

      batch.set(collection.doc(reelId), payload, SetOptions(merge: true));
    }

    await batch.commit();
  }

  @override
  Future<int> adjustLike({required String reelId, required int delta}) async {
    if (delta == 0) {
      final snapshot =
          await client.firestore
              .collection(AppConstants.reelsCollection)
              .doc(reelId)
              .get();
      if (!snapshot.exists) {
        throw const ServerException('Reel not found in Firestore.');
      }
      return _asInt(snapshot.data()?['likes']);
    }

    final document = client.firestore
        .collection(AppConstants.reelsCollection)
        .doc(reelId);

    try {
      return await client.firestore.runTransaction<int>((transaction) async {
        final snapshot = await transaction.get(document);
        if (!snapshot.exists) {
          throw const ServerException('Reel not found in Firestore.');
        }

        final payload = snapshot.data() ?? <String, dynamic>{};
        final currentLikes = _asInt(payload['likes']);
        final nextLikes = (currentLikes + delta).clamp(0, 1 << 31);

        transaction.set(document, {
          'likes': nextLikes,
        }, SetOptions(merge: true));
        return nextLikes;
      });
    } on ServerException {
      rethrow;
    } catch (error) {
      throw ServerException('Unable to update reel likes: $error');
    }
  }

  int _asInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
