import '../../domain/entities/party.dart';
import '../../domain/repositories/party_repository.dart';
import '../local/dao/audit_log_dao.dart';
import '../local/dao/party_dao.dart';

class PartyRepositoryImpl implements PartyRepository {
  final PartyDao dao;
  final AuditLogDao audit;

  PartyRepositoryImpl({required this.dao, required this.audit});

  @override
  Future<List<Party>> getCustomers({String search = ''}) => dao.getCustomers(search: search);

  @override
  Future<List<Party>> getSuppliers({String search = ''}) => dao.getSuppliers(search: search);

  @override
  Future<void> saveCustomer(Party party) async {
    await dao.saveCustomer(party);
    await audit.log(
      action: party.id == null ? 'create' : 'update',
      entityName: 'customers',
      recordId: '${party.id ?? 'new'}',
      details: 'Customer saved: ${party.name}',
    );
  }

  @override
  Future<void> saveSupplier(Party party) async {
    await dao.saveSupplier(party);
    await audit.log(
      action: party.id == null ? 'create' : 'update',
      entityName: 'suppliers',
      recordId: '${party.id ?? 'new'}',
      details: 'Supplier saved: ${party.name}',
    );
  }

  @override
  Future<void> deleteCustomer(int id) async {
    await dao.deleteCustomer(id);
    await audit.log(action: 'delete', entityName: 'customers', recordId: '$id');
  }

  @override
  Future<void> deleteSupplier(int id) async {
    await dao.deleteSupplier(id);
    await audit.log(action: 'delete', entityName: 'suppliers', recordId: '$id');
  }
}
