import '../../entities/document_numbering_settings.dart';
import '../../repositories/document_numbering_repository.dart';

class GetDocumentNumberingSettingsUseCase {
  final DocumentNumberingRepository repository;
  GetDocumentNumberingSettingsUseCase(this.repository);
  Future<DocumentNumberingSettings> call() => repository.getSettings();
}

class SaveDocumentNumberingSettingsUseCase {
  final DocumentNumberingRepository repository;
  SaveDocumentNumberingSettingsUseCase(this.repository);
  Future<void> call(DocumentNumberingSettings settings) => repository.saveSettings(settings);
}

class GenerateNextOutgoingInvoiceNumberUseCase {
  final DocumentNumberingRepository repository;
  GenerateNextOutgoingInvoiceNumberUseCase(this.repository);
  Future<String> call() => repository.generateNextOutgoingInvoiceNumber();
}

class GenerateNextIncomingInvoiceNumberUseCase {
  final DocumentNumberingRepository repository;
  GenerateNextIncomingInvoiceNumberUseCase(this.repository);
  Future<String> call() => repository.generateNextIncomingInvoiceNumber();
}
