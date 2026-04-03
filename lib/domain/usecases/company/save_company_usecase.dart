import '../../entities/company.dart';
import '../../repositories/company_repository.dart';

class SaveCompanyUseCase {
  final CompanyRepository repository;
  SaveCompanyUseCase(this.repository);

  Future<void> call(Company company) => repository.upsertCompany(company);
}
