import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/l10n/l10n.dart';
import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'notebook_input_field.dart';

/// The form body for adding a payment card with card data fields.
class AddCardForm extends StatelessWidget {
  /// Creates an [AddCardForm].
  const AddCardForm({
    super.key,
    required this.cardNameController,
    required this.cardNumberController,
    required this.expiryController,
    required this.cvvController,
    required this.onFieldChanged,
  });

  /// Controller for the card holder name field.
  final TextEditingController cardNameController;

  /// Controller for the card number field.
  final TextEditingController cardNumberController;

  /// Controller for the expiry date field.
  final TextEditingController expiryController;

  /// Controller for the CVV field.
  final TextEditingController cvvController;

  /// Called when any field value changes.
  final ValueChanged<String?> onFieldChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return NotebookCard(
      ruled: true,
      ruledStartY: 20,
      borderRadius: 12,
      padding: EdgeInsets.all(20.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NotebookInputField(
            label: l10n.cardHolderNameRequired,
            controller: cardNameController,
            hint: l10n.cardHolderHint,
            onChanged: onFieldChanged,
          ),
          SizedBox(height: 18.h),
          NotebookInputField(
            label: l10n.cardNumberRequired,
            controller: cardNumberController,
            hint: l10n.cardNumberHint,
            keyboardType: TextInputType.number,
            onChanged: onFieldChanged,
          ),
          SizedBox(height: 18.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: NotebookInputField(
                  label: l10n.expiryDateRequired,
                  controller: expiryController,
                  hint: 'MM/YY',
                  keyboardType: TextInputType.datetime,
                  onChanged: onFieldChanged,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: NotebookInputField(
                  label: l10n.cvvRequired,
                  controller: cvvController,
                  hint: l10n.cvvHint,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
