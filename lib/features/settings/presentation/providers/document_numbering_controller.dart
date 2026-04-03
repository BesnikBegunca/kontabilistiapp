import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/providers/repository_providers.dart';
import '../../../../domain/entities/document_numbering_settings.dart';
import '../../../../domain/usecases/document_numbering/document_numbering_usecases.dart';

final documentNumberingControllerProvider =
    AsyncNotifierProvider<DocumentNumberingController, DocumentNumberingSettings>(DocumentNumberingController.new);

class DocumentNumberingController extends AsyncNotifier<DocumentNumberingSettings> {
  late final GetDocumentNumberingSettingsUseCase _get;
  late final SaveDocumentNumberingSettingsUseCase _save;

  @override
  Future<DocumentNumberingSettings> build() async {
    _get = GetDocumentNumberingSettingsUseCase(ref.read(documentNumberingRepositoryProvider));
    _save = SaveDocumentNumberingSettingsUseCase(ref.read(documentNumberingRepositoryProvider));
    return _get();
  }

  Future<void> save(DocumentNumberingSettings settings) async {
    state = const AsyncLoading();
    await _save(settings);
    state = AsyncData(await _get());
  }
}
