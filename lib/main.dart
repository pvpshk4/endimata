import 'package:endimata/common/theme/app_theme.dart';
import 'package:endimata/common/theme/theme_bloc.dart';
import 'package:endimata/common/theme/theme_state.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:endimata/common/photo_upload/presentation/bloc/photo_upload_bloc.dart';
import 'package:endimata/common/AppData/presentation/bloc/app_data_bloc.dart';
import 'package:endimata/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:endimata/features/home/presentation/bloc/home_bloc.dart';
import 'package:endimata/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:endimata/features/wardrobe/presentation/bloc/wardrobe_bloc.dart';
import 'package:endimata/firebase_options.dart';
import 'package:endimata/injection_container.dart' as di;
import 'package:shared_preferences/shared_preferences.dart';
import 'common/utils/debug_logger.dart';
import 'config/routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await di.init();
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(
    'flask_jwt_token',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJmcmVzaCI6ZmFsc2UsImlhdCI6MTc3NTM5NjI2MiwianRpIjoiM2QxODZmNGMtZmE4NS00NjQxLWI0MzMtNWZjZmEzNjliNGRjIiwidHlwZSI6ImFjY2VzcyIsInN1YiI6IjIiLCJuYmYiOjE3NzUzOTYyNjIsImNzcmYiOiJiMzhjMGY2MS1mODcwLTRmNWQtODA0MS1lZmFiNjVkYmY2ZmIiLCJleHAiOjE3NzU0MjUwNjJ9.2Y-7wZp4NP7UXkiANhAFHokrbcyK6hmxXD8utRPenuk',
  );
  await prefs.setString('flask_user_id', '2');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeBloc>(create: (context) => di.sl<ThemeBloc>()),
        BlocProvider<AppDataBloc>(create: (context) => di.sl<AppDataBloc>()),
        BlocProvider<PhotoUploadBloc>(
          create: (context) => di.sl<PhotoUploadBloc>(),
        ),
        BlocProvider<WardrobeBloc>(create: (context) => di.sl<WardrobeBloc>()),
        BlocProvider<HomeBloc>(create: (context) => di.sl<HomeBloc>()),
        BlocProvider<ProfileBloc>(create: (context) => di.sl<ProfileBloc>()),
        BlocProvider<AuthBloc>(create: (context) => di.sl<AuthBloc>()),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'Endimata',
            routerConfig: appRouter,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeState.themeMode,
            builder: (context, child) {
              return Stack(
                children: [
                  child ?? const SizedBox.shrink(),
                  // Debug overlay
                  Positioned(
                    bottom: 80,
                    left: 0,
                    right: 0,
                    child: ListenableBuilder(
                      listenable: DebugLogger.instance,
                      builder: (context, _) {
                        final logs = DebugLogger.instance.logs;
                        if (logs.isEmpty) return const SizedBox.shrink();
                        return Container(
                          color: Colors.black87,
                          padding: const EdgeInsets.all(8),
                          height: 200,
                          child: ListView.builder(
                            itemCount: logs.length,
                            itemBuilder:
                                (context, i) => Text(
                                  logs[i],
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontSize: 10,
                                  ),
                                ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
