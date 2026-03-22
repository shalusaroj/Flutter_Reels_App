import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:reels_assignment/features/reels/domain/entities/reel.dart';
import 'package:reels_assignment/features/reels/presentation/cubit/reel_likes_cubit.dart';
import 'package:reels_assignment/features/reels/presentation/cubit/reel_likes_state.dart';
import 'package:reels_assignment/features/reels/presentation/cubit/reels_cubit.dart';
import 'package:reels_assignment/features/reels/presentation/cubit/reels_playback_cubit.dart';
import 'package:reels_assignment/features/reels/presentation/cubit/reels_playback_state.dart';
import 'package:reels_assignment/features/reels/presentation/cubit/reels_state.dart';
import 'package:reels_assignment/features/reels/presentation/widgets/reels_empty_view.dart';
import 'package:reels_assignment/features/reels/presentation/widgets/reels_error_view.dart';
import 'package:reels_assignment/features/reels/presentation/widgets/reels_feed_view.dart';
import 'package:reels_assignment/features/reels/presentation/widgets/reels_seed_action_button.dart';
import 'package:reels_assignment/features/reels/presentation/widgets/reels_shimmer_view.dart';
import 'package:reels_assignment/features/reels/presentation/widgets/reels_top_app_bar.dart';
import 'package:reels_assignment/injection_container.dart';
import 'package:reels_assignment/presentation/theme/app_colors_extension.dart';
import 'package:reels_assignment/presentation/theme/app_palette.dart';

class ReelsPage extends StatelessWidget {
  const ReelsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<ReelsCubit>()..loadReels()),
        BlocProvider(create: (_) => getIt<ReelLikesCubit>()),
        BlocProvider(create: (_) => getIt<ReelsPlaybackCubit>()),
      ],
      child: const _ReelsView(),
    );
  }
}

class _ReelsView extends StatefulWidget {
  const _ReelsView();

  @override
  State<_ReelsView> createState() => _ReelsViewState();
}

class _ReelsViewState extends State<_ReelsView> with WidgetsBindingObserver {
  final PageController _pageController = PageController();
  static const _reelsSystemUiStyle = SystemUiOverlayStyle(
    statusBarColor: AppPalette.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: AppPalette.backgroundDark,
    systemNavigationBarIconBrightness: Brightness.light,
    systemNavigationBarDividerColor: AppPalette.transparent,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) {
      return;
    }
    context.read<ReelsPlaybackCubit>().handleLifecycle(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReelsCubit, ReelsState>(
      listenWhen: (previous, current) => previous.reels != current.reels,
      listener: (context, state) {
        unawaited(context.read<ReelsPlaybackCubit>().syncFeed(state.reels));
        context.read<ReelLikesCubit>().syncReels(state.reels);
      },
      child: BlocBuilder<ReelsCubit, ReelsState>(
        builder: (context, state) {
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: _reelsSystemUiStyle,
            child: BlocBuilder<ReelsPlaybackCubit, ReelsPlaybackState>(
              buildWhen:
                  (previous, current) => previous.isMuted != current.isMuted,
              builder: (context, playbackState) {
                return Scaffold(
                  backgroundColor: context.colors.reelsBackground,
                  extendBodyBehindAppBar: true,
                  appBar: ReelsTopAppBar(
                    isMuted: playbackState.isMuted,
                    onAudioToggle: () {
                      unawaited(
                        context.read<ReelsPlaybackCubit>().toggleMute(),
                      );
                    },
                  ),
                  floatingActionButton: ReelsSeedActionButton(
                    isSeeding: state.isSeeding,
                    onPressed: () => unawaited(_onSeedPressed()),
                  ),
                  body: SafeArea(
                    top: false,
                    bottom: false,
                    child: switch (state) {
                      ReelsInitial() => const ReelsShimmerView(),
                      ReelsLoading(reels: final reels) when reels.isEmpty =>
                        const ReelsShimmerView(),
                      ReelsLoading(reels: final reels) => _buildReels(
                        context,
                        reels,
                        isLoadingMore: true,
                      ),
                      ReelsLoaded(
                        reels: final reels,
                        isLoadingMore: final isLoadingMore,
                      ) =>
                        _buildReels(
                          context,
                          reels,
                          isLoadingMore: isLoadingMore,
                        ),
                      ReelsFailure(failure: final failure, reels: final reels)
                          when reels.isEmpty =>
                        ReelsErrorView(
                          message: failure.message,
                          onRetry: () => context.read<ReelsCubit>().retry(),
                        ),
                      ReelsFailure(
                        reels: final reels,
                        isLoadingMore: final isLoadingMore,
                        failure: final failure,
                      ) =>
                        _buildReels(
                          context,
                          reels,
                          isLoadingMore: isLoadingMore,
                          failureMessage: failure.message,
                        ),
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildReels(
    BuildContext context,
    List<Reel> reels, {
    required bool isLoadingMore,
    String? failureMessage,
  }) {
    if (reels.isEmpty) {
      return const ReelsEmptyView();
    }

    return BlocBuilder<ReelsPlaybackCubit, ReelsPlaybackState>(
      builder: (context, playbackState) {
        return BlocBuilder<ReelLikesCubit, ReelLikesState>(
          builder: (context, likesState) {
            return ReelsFeedView(
              pageController: _pageController,
              reels: reels,
              controllers: playbackState.controllers,
              loadingIndexes: playbackState.loadingIndexes,
              likeAnimationTokens: playbackState.likeAnimationTokens,
              likeCounts: likesState.likeCounts,
              likedReelIds: likesState.likedReelIds,
              syncingReelIds: likesState.syncingReelIds,
              isLoadingMore: isLoadingMore,
              activeIndex: playbackState.activeIndex,
              failureMessage: failureMessage,
              onPageChanged: (index) {
                unawaited(
                  context.read<ReelsPlaybackCubit>().onPageChanged(index),
                );
                unawaited(context.read<ReelsCubit>().loadMoreIfNeeded(index));
              },
              onScrollStart: () {
                unawaited(context.read<ReelsPlaybackCubit>().onScrollStart());
              },
              onScrollEnd: () {
                unawaited(context.read<ReelsPlaybackCubit>().onScrollEnd());
              },
              onReelTap: (index) {
                unawaited(context.read<ReelsPlaybackCubit>().onReelTap(index));
              },
              onReelDoubleTap: (index, reel) {
                context.read<ReelsPlaybackCubit>().triggerLikeAnimation(index);
                unawaited(context.read<ReelLikesCubit>().ensureLiked(reel));
              },
              onReelLikeTap: (reel) {
                unawaited(context.read<ReelLikesCubit>().toggleLike(reel));
              },
              onReelLongPressStart: (index) {
                unawaited(
                  context.read<ReelsPlaybackCubit>().onReelLongPressStart(
                    index,
                  ),
                );
              },
              onReelLongPressEnd: (index) {
                unawaited(
                  context.read<ReelsPlaybackCubit>().onReelLongPressEnd(index),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _onSeedPressed() async {
    final cubit = context.read<ReelsCubit>();
    final error = await cubit.seedDemoData();
    if (!mounted) {
      return;
    }

    final snackBar = SnackBar(
      content: Text(
        error == null
            ? 'Demo reels seeded in Firestore. Feed refreshed.'
            : 'Seed failed: $error',
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
