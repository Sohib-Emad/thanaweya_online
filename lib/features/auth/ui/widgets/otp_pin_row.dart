import 'package:flutter/material.dart';

import 'otp_pin_field.dart';

/// Row of 6 OTP digit input fields with auto-focus behaviour.
class OtpPinRow extends StatelessWidget {
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;

  const OtpPinRow({
    super.key,
    required this.controllers,
    required this.focusNodes,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (index) {
        return OtpPinField(
          controller: controllers[index],
          focusNode: focusNodes[index],
          onChanged: (value) {
            if (value.isNotEmpty && index < 5) {
              focusNodes[index + 1].requestFocus();
            } else if (value.isEmpty && index > 0) {
              focusNodes[index - 1].requestFocus();
            }
          },
        );
      }),
    );
  }
}
