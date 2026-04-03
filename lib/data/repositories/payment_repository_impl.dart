import '../../domain/entities/payment_entity.dart';
import '../../domain/repositories/payment_repository.dart';
import '../local/dao/payment_dao.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentDao dao;
  PaymentRepositoryImpl(this.dao);

  @override
  Future<List<PaymentEntity>> getPayments({String search = ''}) => dao.getPayments(search: search);
}
