import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/access_repository.dart';
import '../../domain/access_profile.dart';

part 'access_state.dart';

class AccessCubit extends Cubit<AccessState> {
  AccessCubit({required AccessRepository repository})
      : _repository = repository,
        super(const AccessState.initial());

  final AccessRepository _repository;

  Future<void> refresh() async {
    emit(state.copyWith(isLoading: true, clearMessage: true));
    try {
      final profile = await _repository.resolve();
      emit(
        state.copyWith(
          isLoading: false,
          profile: profile,
          clearMessage: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: error.toString(),
        ),
      );
    }
  }
}
