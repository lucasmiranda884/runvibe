import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:location/location.dart';
import 'package:image_picker/image_picker.dart';
import 'package:runvibe_mobile/core/network/api_client.dart';
import 'package:runvibe_mobile/core/network/auth_interceptor.dart';
import 'package:runvibe_mobile/core/storage/token_storage.dart';
import 'package:runvibe_mobile/features/auth/data/auth_repository.dart';
import 'package:runvibe_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:runvibe_mobile/features/tracking/data/activity_local_data_source.dart';
import 'package:runvibe_mobile/features/tracking/data/activity_remote_data_source.dart';
import 'package:runvibe_mobile/features/tracking/data/tracking_repository.dart';
import 'package:runvibe_mobile/features/tracking/domain/location_service.dart';
import 'package:runvibe_mobile/features/tracking/domain/activity_photo_storage.dart';
import 'package:runvibe_mobile/features/tracking/domain/foreground_tracking_service.dart';
import 'package:runvibe_mobile/features/tracking/domain/sync_coordinator.dart';
import 'package:runvibe_mobile/features/tracking/presentation/bloc/tracking_bloc.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  const secureStorage = FlutterSecureStorage();
  getIt.registerSingleton<FlutterSecureStorage>(secureStorage);
  getIt.registerLazySingleton(() => TokenStorage(getIt()));
  getIt.registerLazySingleton(() => AuthInterceptor(getIt()));
  getIt.registerLazySingleton<Dio>(() => createDio(getIt()));
  getIt.registerLazySingleton(() => AuthRepository(getIt(), getIt()));

  final localDataSource = ActivityLocalDataSource();
  await localDataSource.initialize();
  getIt.registerSingleton(localDataSource);
  getIt.registerLazySingleton(() => ActivityRemoteDataSource(getIt()));
  getIt.registerLazySingleton(() => TrackingRepository(getIt(), getIt()));
  getIt.registerLazySingleton(() => ForegroundTrackingService());
  getIt.registerLazySingleton(() => ActivityPhotoStorage(ImagePicker()));
  getIt<ForegroundTrackingService>().initialize();
  getIt.registerLazySingleton(() => LocationService(Location(), getIt()));
  getIt.registerLazySingleton(() => SyncCoordinator(getIt()));

  getIt.registerFactory(() => AuthBloc(getIt()));
  getIt.registerFactory(() => TrackingBloc(getIt(), getIt()));

  await getIt<SyncCoordinator>().start();
}
