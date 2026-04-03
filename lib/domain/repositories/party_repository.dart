import '../entities/party.dart';

abstract class PartyRepository {
  Future<List<Party>> getCustomers({String search = ''});
  Future<List<Party>> getSuppliers({String search = ''});
  Future<void> saveCustomer(Party party);
  Future<void> saveSupplier(Party party);
  Future<void> deleteCustomer(int id);
  Future<void> deleteSupplier(int id);
}
