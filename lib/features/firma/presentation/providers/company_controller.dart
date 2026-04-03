import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/providers/repository_providers.dart';
import '../../../../domain/entities/company.dart';
import '../../../../domain/usecases/company/get_company_usecase.dart';
import '../../../../domain/usecases/company/save_company_usecase.dart';

final companyControllerProvider = AsyncNotifierProvider<CompanyController, Company?>(CompanyController.new);

class CompanyController extends AsyncNotifier<Company?> {
  late final GetCompanyUseCase _getCompany;
  late final SaveCompanyUseCase _saveCompany;

  @override
  Future<Company?> build() async {
    _getCompany = GetCompanyUseCase(ref.read(companyRepositoryProvider));
    _saveCompany = SaveCompanyUseCase(ref.read(companyRepositoryProvider));
    return _getCompany();
  }

  Future<void> save(Company company) async {
    state = const AsyncLoading();
    await _saveCompany(company);
    state = AsyncData(await _getCompany());
  }
}
