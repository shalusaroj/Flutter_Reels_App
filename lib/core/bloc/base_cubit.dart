import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reels_assignment/core/bloc/base_state.dart';

abstract class BaseCubit<S extends BaseState> extends Cubit<S> {
  BaseCubit(super.initialState);

  @override
  void onChange(Change<S> change) {
    super.onChange(change);
    if (kDebugMode) {
      debugPrint('[${runtimeType.toString()}] $change');
    }
  }
}
