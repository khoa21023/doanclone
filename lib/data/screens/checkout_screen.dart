import 'package:flutter/material.dart';
import '../widgets/checkout_stepper.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String selectedMethod = 'Thẻ tín dụng quốc tế (Visa/Master)';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FA),
      appBar: AppBar(
        title: const Text("Thanh toán"),
        backgroundColor: const Color(0xFF1A65EB),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const CheckoutStepper(currentStep: 1),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Phương thức thanh toán",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  const Text("Chọn phương thức", style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: selectedMethod,
                        items: ['Thẻ tín dụng quốc tế (Visa/Master)', 'Ví MoMo', 'ZaloPay']
                            .map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            selectedMethod = newValue!;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Số thẻ", style: TextStyle(fontWeight: FontWeight.w500)),
                        const SizedBox(height: 8),
                        TextField(
                          decoration: InputDecoration(
                            hintText: "0000 0000 0000 0000",
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text("Tên in trên thẻ", style: TextStyle(fontWeight: FontWeight.w500)),
                        const SizedBox(height: 8),
                        TextField(
                          decoration: InputDecoration(
                            hintText: "NGUYEN VAN A",
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Ngày hết hạn", style: TextStyle(fontWeight: FontWeight.w500)),
                                  const SizedBox(height: 8),
                                  TextField(
                                    decoration: InputDecoration(
                                      hintText: "MM/YY",
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(color: Colors.grey.shade300),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Mã CVC/CVV", style: TextStyle(fontWeight: FontWeight.w500)),
                                  const SizedBox(height: 8),
                                  TextField(
                                    obscureText: true,
                                    decoration: InputDecoration(
                                      hintText: "***",
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(color: Colors.grey.shade300),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.payment, color: Colors.white),
                      label: const Text(
                        "Đặt hàng • 30.020.000 VND",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A65EB),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Tóm tắt đơn hàng",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text("iPhone 15 Pro Max", style: TextStyle(color: Colors.black87)),
                            Text("29.990.000 VND", style: TextStyle(color: Colors.black87)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Divider(),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text("Tạm tính", style: TextStyle(color: Colors.grey)),
                            Text("29.990.000 VND", style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text("Phí giao hàng", style: TextStyle(color: Colors.grey)),
                            Text("30.000 VND", style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              "Tổng cộng",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              "30.020.000 VND",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Color(0xFF1A65EB),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}