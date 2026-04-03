import '../../entities/payment_entity.dart';
import '../../repositories/payment_repository.dart';

class GetPaymentsUseCase {
  final PaymentRepository repository;
  GetPaymentsUseCase(this.repository);

  Future<List<PaymentEntity>> call({String search = ''}) => repository.getPayments(search: search);
}
