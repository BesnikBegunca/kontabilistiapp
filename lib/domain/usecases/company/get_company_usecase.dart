import '../../entities/company.dart';
import '../../repositories/company_repository.dart';

class GetCompanyUseCase {
  final CompanyRepository repository;
  GetCompanyUseCase(this.repository);

  Future<Company?> call() => repository.getCompany();
}
