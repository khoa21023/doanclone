import 'package:flutter/material.dart';

class CheckoutStepper extends StatelessWidget {
  final int currentStep;

  const CheckoutStepper({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
              color: Color(0xFF00C853),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                "1",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            "Thông tin",
            style: TextStyle(
              color: Color(0xFF00C853),
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF1A65EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
              color: Color(0xFF1A65EB),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                "2",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            "Thanh toán",
            style: TextStyle(
              color: Color(0xFF1A65EB),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}