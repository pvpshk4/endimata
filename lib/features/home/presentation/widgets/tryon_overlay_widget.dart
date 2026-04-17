import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:endimata/config/theme/app_colors.dart';
import 'package:endimata/features/home/presentation/bloc/home_bloc.dart';
import 'package:endimata/features/home/presentation/bloc/home_event.dart';
import 'package:endimata/features/home/presentation/bloc/home_state.dart';

/// Overlay поверх фона — показывает статус и результат примерки
class TryOnOverlayWidget extends StatelessWidget {
  const TryOnOverlayWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      buildWhen:
          (previous, current) =>
              previous.tryOnStatus != current.tryOnStatus ||
              previous.tryOnResultBase64 != current.tryOnResultBase64 ||
              previous.tryOnError != current.tryOnError,
      builder: (context, state) {
        // Ничего не показываем в idle
        if (state.tryOnStatus == TryOnStatus.idle) {
          return const SizedBox.shrink();
        }

        return Positioned.fill(
          child: Stack(
            children: [
              // Результат примерки поверх фото человека
              if (state.tryOnStatus == TryOnStatus.done &&
                  state.tryOnResultBase64 != null)
                Positioned.fill(
                  child: Image.memory(
                    base64Decode(state.tryOnResultBase64!),
                    fit: BoxFit.cover,
                    gaplessPlayback: true,
                  ),
                ),

              // Индикатор загрузки
              if (state.tryOnStatus == TryOnStatus.loading)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.3),
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            color: AppColors.primaryColor,
                            strokeWidth: 3,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Примеряем...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'SFPro-Medium',
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Это займёт около минуты',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              fontFamily: 'SFPro-Light',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Ошибка
              if (state.tryOnStatus == TryOnStatus.error)
                Positioned(
                  bottom: 120,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.shade900.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      state.tryOnError ?? 'Ошибка примерки',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

              // Кнопка закрыть (крестик) — справа вверху
              if (state.tryOnStatus != TryOnStatus.idle)
                Positioned(
                  top: 40,
                  right: 16,
                  child: GestureDetector(
                    onTap:
                        () => context.read<HomeBloc>().add(
                          const ClearTryOnEvent(),
                        ),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
