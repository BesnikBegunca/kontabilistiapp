import '../../domain/entities/document_numbering_settings.dart';
import '../../domain/repositories/document_numbering_repository.dart';
import '../local/dao/document_numbering_dao.dart';

class DocumentNumberingRepositoryImpl implements DocumentNumberingRepository {
  final DocumentNumberingDao dao;
  DocumentNumberingRepositoryImpl(this.dao);

  @override
  Future<DocumentNumberingSettings> getSettings() => dao.getSettings();

  @override
  Future<void> saveSettings(DocumentNumberingSettings settings) => dao.saveSettings(settings);

  @override
  Future<String> generateNextIncomingInvoiceNumber() => dao.generateNextIncomingInvoiceNumber();

  @override
  Future<String> generateNextOutgoingInvoiceNumber() => dao.generateNextOutgoingInvoiceNumber();
}
