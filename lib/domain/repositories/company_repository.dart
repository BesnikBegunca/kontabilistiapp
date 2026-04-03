import '../entities/company.dart';

abstract class CompanyRepository {
  Future<Company?> getCompany();
  Future<void> upsertCompany(Company company);
}
