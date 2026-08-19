import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/theme/student_payments_repo.dart';
import 'package:thanaweya_online/features/student/logic/student_payments_cubit.dart';
import 'package:thanaweya_online/l10n/l10n.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'widgets/widgets.dart';

/// Screen for adding a new payment card.
class StudentAddCardScreen extends StatefulWidget {
  const StudentAddCardScreen({super.key});

  @override
  State<StudentAddCardScreen> createState() => _StudentAddCardScreenState();
}

class _StudentAddCardScreenState extends State<StudentAddCardScreen> {
  final _cardNameController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cubit = StudentPaymentsCubit(repo: StudentPaymentsRepo());

  @override
  void dispose() {
    _cubit.close();
    _cardNameController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  String _detectBrand(String number) {
    if (number.startsWith('4')) return 'Visa';
    if (number.startsWith('5')) return 'MasterCard';
    return 'Card';
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message,
          style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
      backgroundColor: const Color(0xFFEF4444),
      behavior: SnackBarBehavior.floating,
    ));
  }

  Future<void> _saveCard() async {
    final l10n = context.l10n;
    final cardHolder = _cardNameController.text.trim();
    final cardNumber = _cardNumberController.text
        .replaceAll(' ', '')
        .replaceAll('-', '');
    if (cardHolder.isEmpty) return _showError(l10n.enterCardHolderName);
    if (cardNumber.length < 4) return _showError(l10n.enterValidCardNumber);

    final parts = _expiryController.text.trim().split('/');
    int? expiryMonth;
    int? expiryYear;
    if (parts.length == 2) {
      expiryMonth = int.tryParse(parts[0].trim());
      final yy = int.tryParse(parts[1].trim());
      if (yy != null) expiryYear = 2000 + yy;
    }
    if (expiryMonth == null || expiryYear == null) {
      return _showError(l10n.enterValidExpiry);
    }

    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return _showError(l10n.loginRequiredFirst);

    final saved = await _cubit.addPaymentMethod(
      studentId: userId,
      cardHolder: cardHolder,
      cardLast4: cardNumber.substring(cardNumber.length - 4),
      cardBrand: _detectBrand(cardNumber),
      expiryMonth: expiryMonth,
      expiryYear: expiryYear,
    );
    if (!mounted) return;
    if (saved) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(context.l10n.cardAddedSuccess,
            style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
        backgroundColor: NotebookColors.green,
        behavior: SnackBarBehavior.floating,
      ));
      Navigator.pop(context, true);
    } else {
      _showError(context.l10n.cardAddError);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: NotebookColors.ground,
        appBar: NotebookTopBar(
          title: l10n.addCardTitle,
          subtitle: l10n.addCardSubtitle,
        ),
        body: NotebookPaper(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 40.h),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NotebookSectionHeader(title: l10n.cardDataSection),
                SizedBox(height: 12.h),
                AddCardForm(
                  cardNameController: _cardNameController,
                  cardNumberController: _cardNumberController,
                  expiryController: _expiryController,
                  cvvController: _cvvController,
                  onFieldChanged: (_) => setState(() {}),
                ),
                SizedBox(height: 28.h),
                NotebookPrimaryButton(
                  label: l10n.addCardButton,
                  icon: Icons.add_rounded,
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    _saveCard();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
