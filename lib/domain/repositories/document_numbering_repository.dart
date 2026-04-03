import '../entities/document_numbering_settings.dart';

abstract class DocumentNumberingRepository {
  Future<DocumentNumberingSettings> getSettings();
  Future<void> saveSettings(DocumentNumberingSettings settings);
  Future<String> generateNextOutgoingInvoiceNumber();
  Future<String> generateNextIncomingInvoiceNumber();
}
