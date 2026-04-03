import '../../entities/app_settings.dart';
import '../../repositories/settings_repository.dart';

class GetSettingsUseCase {
  final SettingsRepository repository;
  GetSettingsUseCase(this.repository);

  Future<AppSettings> call() => repository.getSettings();
}
