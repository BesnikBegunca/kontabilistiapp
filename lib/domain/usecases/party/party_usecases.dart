import '../../entities/party.dart';
import '../../repositories/party_repository.dart';

class GetCustomersUseCase {
  final PartyRepository repository;
  GetCustomersUseCase(this.repository);
  Future<List<Party>> call({String search = ''}) => repository.getCustomers(search: search);
}

class GetSuppliersUseCase {
  final PartyRepository repository;
  GetSuppliersUseCase(this.repository);
  Future<List<Party>> call({String search = ''}) => repository.getSuppliers(search: search);
}

class SaveCustomerUseCase {
  final PartyRepository repository;
  SaveCustomerUseCase(this.repository);
  Future<void> call(Party party) => repository.saveCustomer(party);
}

class SaveSupplierUseCase {
  final PartyRepository repository;
  SaveSupplierUseCase(this.repository);
  Future<void> call(Party party) => repository.saveSupplier(party);
}

class DeleteCustomerUseCase {
  final PartyRepository repository;
  DeleteCustomerUseCase(this.repository);
  Future<void> call(int id) => repository.deleteCustomer(id);
}

class DeleteSupplierUseCase {
  final PartyRepository repository;
  DeleteSupplierUseCase(this.repository);
  Future<void> call(int id) => repository.deleteSupplier(id);
}
