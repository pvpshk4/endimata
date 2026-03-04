import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:endimata/common/AppData/presentation/bloc/app_data_bloc.dart';
import 'package:endimata/common/AppData/presentation/bloc/app_data_state.dart';

class BackgroundPhoto extends StatelessWidget {
  const BackgroundPhoto({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppDataBloc, AppDataState>(
      buildWhen:
          (previous, current) =>
              previous.humanPhotos != current.humanPhotos ||
              previous.selectedHumanPhoto != current.selectedHumanPhoto,
      builder: (context, state) {
        if (state.selectedHumanPhoto == null) {
          return const SizedBox.shrink();
        }
        return Positioned.fill(
          child: Image.memory(
            base64Decode(
              state.selectedHumanPhoto!.contains(',')
                  ? state.selectedHumanPhoto!.split(',').last
                  : state.selectedHumanPhoto!,
            ),
            fit: BoxFit.cover,
            gaplessPlayback: true,
            errorBuilder: (context, error, stackTrace) {
              return const Center(child: Text('Ошибка загрузки фона'));
            },
          ),
        );
      },
    );
  }
}
