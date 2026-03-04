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
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Supabase.initialize(
    url: 'https://redwzoepozxnazdqrnzt.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJlZHd6b2Vwb3p4bmF6ZHFybnp0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzE1OTg0MDYsImV4cCI6MjA4NzE3NDQwNn0.yf_eUKu6tbtcSFAxfpYxjH9n-t4iMLdubRQHrzTieNY',
  );
  await di.init();
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
          );
        },
      ),
    );
  }
}
