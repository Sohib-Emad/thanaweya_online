import '../entities/wallet_entity.dart';

abstract class WalletRepository {
  Future<WalletEntity> getWalletData(String userId);

  Future<WalletEntity> rechargeWithCard({
    required String userId,
    required String cardCode,
  });

  Future<bool> purchaseCourse({
    required String userId,
    required String courseId,
    required String teacherId,
    required double price,
    required String courseTitle,
  });
}
