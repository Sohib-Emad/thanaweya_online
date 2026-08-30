import 'package:flutter_test/flutter_test.dart';
import 'package:thanaweya_online/core/services/app_system_config_repo.dart';
import 'package:thanaweya_online/features/wallet/domain/entities/wallet_transaction_entity.dart';
import 'package:thanaweya_online/features/wallet/data/models/wallet_model.dart';
import 'package:thanaweya_online/features/wallet/data/models/wallet_transaction_model.dart';
import 'package:thanaweya_online/features/chatbot/data/datasources/chatbot_local_datasource.dart';
import 'package:thanaweya_online/features/chatbot/data/repositories/chatbot_repository_impl.dart';
import 'package:thanaweya_online/features/chatbot/presentation/cubit/chatbot_cubit.dart';

void main() {
  group('Wallet Feature Tests', () {
    test('WalletModel calculates totalRecharged and totalSpent properly', () {
      final tx1 = WalletTransactionModel(
        id: '1',
        userId: 'u1',
        title: 'شحن كارت',
        amount: 150.0,
        type: WalletTransactionType.credit,
        createdAt: DateTime.now(),
      );

      final tx2 = WalletTransactionModel(
        id: '2',
        userId: 'u1',
        title: 'شراء كورس',
        amount: 50.0,
        type: WalletTransactionType.debit,
        createdAt: DateTime.now(),
      );

      final wallet = WalletModel.fromData(
        balance: 100.0,
        transactions: [tx1, tx2],
      );

      expect(wallet.currentBalance, 100.0);
      expect(wallet.totalRecharged, 150.0);
      expect(wallet.totalSpent, 50.0);
      expect(wallet.transactions.length, 2);
      expect(wallet.transactions[0].isCredit, true);
      expect(wallet.transactions[1].isDebit, true);
    });

    test('Card code sanitization cleans dashes, spaces, and capitalizes', () {
      const rawInput = '  rsln-8492-9102  ';
      final clean = rawInput.trim().replaceAll('-', '').replaceAll(' ', '').toUpperCase();
      expect(clean, 'RSLN84929102');
    });
  });

  group('Chatbot Feature Tests', () {
    late ChatbotLocalDataSource dataSource;
    late ChatbotRepositoryImpl repository;

    setUp(() {
      dataSource = ChatbotLocalDataSourceImpl();
      repository = ChatbotRepositoryImpl(dataSource);
    });

    test('Chatbot provides the 4 documented categories', () {
      final categories = repository.getCategories();
      expect(categories.length, 4);
      expect(categories, contains('💳 المحفظة والشحن'));
      expect(categories, contains('📚 الكورسات والدروس'));
      expect(categories, contains('📝 الامتحانات والواجبات'));
      expect(categories, contains('⚙️ الحساب والتقنيات'));
    });

    test('Welcome message has correct follow-up suggestions', () {
      final welcome = repository.getWelcomeMessage();
      expect(welcome.isUser, false);
      expect(welcome.followUpQuestions.isNotEmpty, true);
      expect(welcome.text, contains('المساعد الذكي'));
    });

    test('Wallet questions map to wallet actionRoute', () {
      final answer = repository.answerQuestion('كيف أشحن رصيد الخزنة بكارت سنتر؟');
      expect(answer.isUser, false);
      expect(answer.actionRoute, 'wallet');
      expect(answer.actionLabel, contains('الخزنة'));
      expect(answer.followUpQuestions.isNotEmpty, true);
    });

    test('Support questions map to support WhatsApp actionRoute', () {
      final answer = repository.answerQuestion('أريد التحدث مع خدمة العملاء أو الدعم الفني؟');
      expect(answer.isUser, false);
      expect(answer.actionRoute, 'support');
      expect(answer.actionLabel, contains('واتساب'));
    });

    test('ChatbotCubit loads initial state and processes questions', () async {
      final cubit = ChatbotCubit(repository: repository);
      expect(cubit.state.categories.length, 4);
      expect(cubit.state.messages.length, 1);
      expect(cubit.state.isBotTyping, false);

      await cubit.askQuestion('كيف أشحن رصيد الخزنة بكارت سنتر؟');
      // Should now contain user message and bot response
      expect(cubit.state.messages.length, 3);
      expect(cubit.state.messages[1].isUser, true);
      expect(cubit.state.messages[1].text, 'كيف أشحن رصيد الخزنة بكارت سنتر؟');
      expect(cubit.state.messages[2].isUser, false);
      expect(cubit.state.messages[2].actionRoute, 'wallet');
      expect(cubit.state.isBotTyping, false);

      await cubit.close();
    });
  });

  group('AppSystemConfig Version Enforcement Tests', () {
    test('isVersionOlder handles versions, build numbers, and patch digits accurately', () {
      expect(AppSystemConfigRepo.isVersionOlder('1.0.0', '1.0.1'), true);
      expect(AppSystemConfigRepo.isVersionOlder('1.0.1', '1.0.0'), false);
      expect(AppSystemConfigRepo.isVersionOlder('1.0.1', '1.0.1'), false);
      expect(AppSystemConfigRepo.isVersionOlder('1.0.1+2', '1.0.1'), false);
      expect(AppSystemConfigRepo.isVersionOlder('1.0.0+1', '1.0.1+2'), true);
      expect(AppSystemConfigRepo.isVersionOlder('1.0.2', '1.0.1'), false);
    });

    test('isUpdateEnforced allows latest version even when force lock (update_mode) is ON', () {
      const config = AppSystemConfig(
        isUpdateRequired: true,
        minVersion: '1.0.0',
        latestVersion: '1.0.1',
      );

      // Latest version client (1.0.1) MUST NOT be blocked!
      expect(config.isUpdateEnforced('1.0.1'), false);
      expect(config.isUpdateEnforced('1.0.1+2'), false);
      expect(config.isUpdateEnforced('1.0.2'), false);

      // Old version client (1.0.0) MUST be blocked!
      expect(config.isUpdateEnforced('1.0.0'), true);
      expect(config.isUpdateEnforced('1.0.0+1'), true);
    });

    test('isUpdateEnforced respects minVersion when force lock is OFF', () {
      const config = AppSystemConfig(
        isUpdateRequired: false,
        minVersion: '1.0.1',
        latestVersion: '1.0.1',
      );

      expect(config.isUpdateEnforced('1.0.1'), false);
      expect(config.isUpdateEnforced('1.0.0'), true);
    });
  });
}
