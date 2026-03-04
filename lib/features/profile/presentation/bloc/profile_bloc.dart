import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:endimata/common/AppData/presentation/bloc/app_data_bloc.dart';
import '../../../../common/AppData/presentation/bloc/app_data_event.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final AppDataBloc appDataBloc;

  ProfileBloc(this.appDataBloc) : super(const ProfileState()) {
    on<LoadProfileDataEvent>(_onLoadProfileData);

    add(const LoadProfileDataEvent());
  }

  Future<void> _onLoadProfileData(
    LoadProfileDataEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      appDataBloc.add(const LoadAppDataEvent());
      emit(state.copyWith(isLoading: false));
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Не удалось загрузить данные профиля: $e',
        ),
      );
    }
  }
}
