import '../../domain/entities/wallet_entity.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../datasources/wallet_remote_datasource.dart';

class WalletRepositoryImpl implements WalletRepository {
  final WalletRemoteDatasource _datasource;

  WalletRepositoryImpl([WalletRemoteDatasource? datasource])
      : _datasource = datasource ?? WalletSupabaseDatasource();

  @override
  Future<WalletEntity> getWalletData(String userId) async {
    return await _datasource.getWallet(userId);
  }

  @override
  Future<WalletEntity> rechargeWithCard({
    required String userId,
    required String cardCode,
  }) async {
    return await _datasource.rechargeWithCard(
      userId: userId,
      cardCode: cardCode,
    );
  }

  @override
  Future<bool> purchaseCourse({
    required String userId,
    required String courseId,
    required String teacherId,
    required double price,
    required String courseTitle,
  }) async {
    return await _datasource.purchaseCourse(
      userId: userId,
      courseId: courseId,
      teacherId: teacherId,
      price: price,
      courseTitle: courseTitle,
    );
  }
}
