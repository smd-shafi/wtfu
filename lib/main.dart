import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wtfu/dependency_injection/injection.dart';
import 'package:wtfu/core/theme/app_theme.dart';
import 'package:wtfu/routes/app_routes.dart';
import 'package:wtfu/features/alarm/presentation/bloc/alarm_bloc.dart';
import 'package:wtfu/features/alarm/presentation/bloc/alarm_event.dart';
import 'package:wtfu/features/alarm/presentation/bloc/alarm_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize alarm scheduler system
  await Alarm.init();
  
  // Set notification warning when app is killed (Android/iOS)
  await Alarm.setWarningNotificationOnKill(
    'WTFU is closed',
    'Alarms will not ring if the application is force stopped. Please keep it open in the background.',
  );
  
  // Initialize dependency injection
  await init();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AlarmBloc>(
          create: (_) => sl<AlarmBloc>()..add(LoadAlarmsEvent()),
        ),
      ],
      child: BlocBuilder<AlarmBloc, AlarmState>(
        buildWhen: (previous, current) => previous.darkMode != current.darkMode,
        builder: (context, state) {
          return MaterialApp.router(
            title: 'WTFU',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: state.darkMode ? ThemeMode.dark : ThemeMode.light,
            routerConfig: appRouter,
          );
        },
      ),
    );
  }
}