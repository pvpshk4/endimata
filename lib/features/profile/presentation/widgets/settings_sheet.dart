import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:endimata/config/theme/app_colors.dart';
import 'package:endimata/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:endimata/features/auth/presentation/bloc/auth_event.dart';
import 'package:endimata/features/auth/presentation/bloc/auth_state.dart';

import '../../../../common/theme/theme_bloc.dart';
import '../../../../common/theme/theme_event.dart';
import '../../../../common/theme/theme_state.dart';

class SettingsSheet extends StatelessWidget {
  const SettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final offset = screenHeight * 0.01;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final sheetBg = theme.scaffoldBackgroundColor;
    final textColor = isDark ? Colors.white : Colors.black;
    final tileColor = isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade50;
    final dividerColor = isDark ? Colors.white24 : AppColors.greyColor;

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: sheetBg,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20.0),
            ),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Transform.translate(
                    offset: Offset(0, -offset - 8),
                    child: Container(
                      width: 230,
                      height: 5,
                      decoration: BoxDecoration(
                        color: dividerColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: offset * 2),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Настройки',
                    style: TextStyle(
                      fontSize: 22,
                      fontFamily: 'SFPro-SemiBold',
                      color: textColor,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, authState) {
                    if (authState is AuthLoadingState) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (authState is AuthAuthenticatedState) {
                      return _buildAuthenticatedSection(
                        context,
                        authState,
                        offset,
                        tileColor,
                        textColor,
                        isDark,
                      );
                    }
                    return _buildUnauthenticatedSection(
                      context,
                      tileColor,
                      textColor,
                      isDark,
                    );
                  },
                ),

                const SizedBox(height: 8),
                _SectionHeader(title: 'Приложение', isDark: isDark),

                // Тёмная тема
                BlocBuilder<ThemeBloc, ThemeState>(
                  builder: (context, themeState) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 4.0,
                      ),
                      child: Material(
                        color: tileColor,
                        borderRadius: BorderRadius.circular(12.0),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14.0,
                            vertical: 10.0,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                themeState.isDark
                                    ? Icons.dark_mode_outlined
                                    : Icons.light_mode_outlined,
                                size: 22,
                                color: textColor,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Тёмная тема',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'SFPro-Regular',
                                    color: textColor,
                                  ),
                                ),
                              ),
                              Switch(
                                value: themeState.isDark,
                                activeThumbColor: AppColors.primaryColor,
                                onChanged: (_) {
                                  context.read<ThemeBloc>().add(
                                    ToggleThemeEvent(),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                _SettingsTile(
                  icon: Icons.notifications_none_outlined,
                  title: 'Уведомления',
                  tileColor: tileColor,
                  textColor: textColor,
                  onTap: () {},
                ),
                _SettingsTile(
                  icon: Icons.info_outline,
                  title: 'О приложении',
                  tileColor: tileColor,
                  textColor: textColor,
                  onTap: () {},
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAuthenticatedSection(
    BuildContext context,
    AuthAuthenticatedState state,
    double offset,
    Color tileColor,
    Color textColor,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: 'Аккаунт', isDark: isDark),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: Material(
            color: tileColor,
            borderRadius: BorderRadius.circular(12.0),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primaryColor.withValues(
                      alpha: 0.15,
                    ),
                    backgroundImage:
                        state.user.photoUrl != null
                            ? NetworkImage(state.user.photoUrl!)
                            : null,
                    child:
                        state.user.photoUrl == null
                            ? Text(
                              (state.user.name ?? 'U')[0].toUpperCase(),
                              style: const TextStyle(
                                fontSize: 20,
                                fontFamily: 'SFPro-SemiBold',
                                color: AppColors.primaryColor,
                              ),
                            )
                            : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.user.name ?? 'Пользователь',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'SFPro-SemiBold',
                            color: textColor,
                          ),
                        ),
                        if (state.user.email != null)
                          Text(
                            state.user.email!,
                            style: TextStyle(
                              fontSize: 13,
                              fontFamily: 'SFPro-Light',
                              color: Colors.grey.shade500,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade50,
                foregroundColor: Colors.red,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.0),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16.0),
              ),
              onPressed: () {
                context.read<AuthBloc>().add(const SignOutEvent());
                Navigator.pop(context);
              },
              child: const Text(
                'Выйти из аккаунта',
                style: TextStyle(fontSize: 16, fontFamily: 'SFPro-Medium'),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUnauthenticatedSection(
    BuildContext context,
    Color tileColor,
    Color textColor,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: 'Аккаунт', isDark: isDark),
        _SettingsTile(
          icon: Icons.person_outline,
          title: 'Войти в аккаунт',
          subtitle: 'Привяжите аккаунт для сохранения фото',
          tileColor: tileColor,
          textColor: textColor,
          onTap: () {
            Navigator.pop(context);
            _showSignInSheet(context);
          },
        ),
      ],
    );
  }

  void _showSignInSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (_) => BlocProvider.value(
            value: context.read<AuthBloc>(),
            child: const SignInSheet(),
          ),
    );
  }
}

// ─── Страница авторизации ────────────────────────────────────────────────────

class SignInSheet extends StatelessWidget {
  const SignInSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);
    final sheetBg = theme.scaffoldBackgroundColor;
    final textColor =
        theme.brightness == Brightness.dark ? Colors.white : Colors.black;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticatedState) Navigator.pop(context);
        if (state is AuthErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.5,
        maxChildSize: 0.75,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: sheetBg,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24.0),
              ),
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.04),
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.checkroom_outlined,
                        size: 36,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.025),
                    Text(
                      'Войдите в аккаунт',
                      style: TextStyle(
                        fontSize: 24,
                        fontFamily: 'SFPro-SemiBold',
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Сохраняйте свой гардероб и\nполучайте доступ с любого устройства',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'SFPro-Light',
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.045),
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        final isLoading = state is AuthLoadingState;
                        return SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  theme.brightness == Brightness.dark
                                      ? const Color(0xFF2C2C2C)
                                      : Colors.white,
                              foregroundColor: textColor,
                              elevation: 0,
                              side: BorderSide(color: Colors.grey.shade300),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.0),
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 16.0,
                              ),
                            ),
                            onPressed:
                                isLoading
                                    ? null
                                    : () => context.read<AuthBloc>().add(
                                      const SignInWithGoogleEvent(),
                                    ),
                            child:
                                isLoading
                                    ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.primaryColor,
                                      ),
                                    )
                                    : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 22,
                                          height: 22,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: const Center(
                                            child: Text(
                                              'G',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        const Text(
                                          'Продолжить через Google',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontFamily: 'SFPro-Medium',
                                          ),
                                        ),
                                      ],
                                    ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Text(
                      'Нажимая "Продолжить", вы соглашаетесь\nс условиями использования приложения',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontFamily: 'SFPro-Light',
                        color: Colors.grey.shade400,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Вспомогательные виджеты ────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool isDark;
  const _SectionHeader({required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontFamily: 'SFPro-Medium',
          color: Colors.grey.shade500,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color tileColor;
  final Color textColor;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.tileColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Material(
        color: tileColor,
        borderRadius: BorderRadius.circular(12.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(12.0),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 14.0,
              vertical: 14.0,
            ),
            child: Row(
              children: [
                Icon(icon, size: 22, color: textColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'SFPro-Regular',
                          color: textColor,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'SFPro-Light',
                            color: Colors.grey.shade500,
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.grey.shade500,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
