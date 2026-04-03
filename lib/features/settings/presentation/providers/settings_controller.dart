import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/providers/repository_providers.dart';
import '../../../../domain/entities/app_settings.dart';
import '../../../../domain/usecases/settings/get_settings_usecase.dart';
import '../../../../domain/usecases/settings/save_settings_usecase.dart';

final settingsControllerProvider = AsyncNotifierProvider<SettingsController, AppSettings>(SettingsController.new);

class SettingsController extends AsyncNotifier<AppSettings> {
  late final GetSettingsUseCase _getSettings;
  late final SaveSettingsUseCase _saveSettings;

  @override
  Future<AppSettings> build() async {
    _getSettings = GetSettingsUseCase(ref.read(settingsRepositoryProvider));
    _saveSettings = SaveSettingsUseCase(ref.read(settingsRepositoryProvider));
    return _getSettings();
  }

  Future<void> save(AppSettings settings) async {
    state = const AsyncLoading();
    await _saveSettings(settings);
    state = AsyncData(await _getSettings());
  }
}
