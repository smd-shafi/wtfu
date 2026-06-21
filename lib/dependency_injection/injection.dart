import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wtfu/features/alarm/presentation/bloc/alarm_bloc.dart';
import 'package:wtfu/features/alarm/data/datasources/alarm_datasource.dart';
import 'package:wtfu/features/alarm/data/repos/alarm_repo_impl.dart';
import 'package:wtfu/features/alarm/domain/repos/alarm_repo.dart';
import 'package:wtfu/features/alarm/services/local_storage_service.dart';
import 'package:wtfu/features/alarm/services/alarm_scheduler_service.dart';
import 'package:wtfu/features/alarm/services/notification_service.dart';
import 'package:wtfu/features/alarm/services/full_screen_alarm_service.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);

  // Global Navigator Key
  final navigatorKey = GlobalKey<NavigatorState>();
  sl.registerSingleton<GlobalKey<NavigatorState>>(navigatorKey);

  // Services
  sl.registerLazySingleton<LocalStorageService>(() => LocalStorageService(sl()));
  sl.registerLazySingleton<AlarmSchedulerService>(() => AlarmSchedulerService());
  sl.registerLazySingleton<NotificationService>(() => NotificationService());
  sl.registerLazySingleton<FullScreenAlarmService>(() => FullScreenAlarmService(sl()));

  // Datasources & Repos
  sl.registerLazySingleton<AlarmDatasource>(() => AlarmDatasource(sl(), sl()));
  sl.registerLazySingleton<AlarmRepo>(() => AlarmRepoImpl(sl()));

  // BLoC
  sl.registerFactory<AlarmBloc>(() => AlarmBloc(
    repo: sl(),
    scheduler: sl(),
    fullScreenService: sl(),
    notificationService: sl(),
  ));
}
