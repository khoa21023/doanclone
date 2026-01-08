import 'package:flutter/material.dart';
import 'success_screen.dart'; 

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _currentStep = 0;
  String _selectedPaymentMethod = 'visa';

  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _zipController = TextEditingController();
  final _phoneController = TextEditingController();
  
  final _promoController = TextEditingController();

  void _goToPayment() {
    setState(() {
      _currentStep = 1; 
    });
  }

  void _finishOrder() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SuccessScreen()),
    );
  }

  void _goBack() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    } else {
      Navigator.pop(context); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF1976D2),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _goBack,
        ),
        title: const Text(
          "Thanh toán",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStepItem(1, "Thông tin", isActive: _currentStep == 0, isCompleted: _currentStep > 0),
                Container(
                  width: 50, height: 2, 
                  color: Colors.grey[300], 
                  margin: const EdgeInsets.symmetric(horizontal: 10)
                ),
                _buildStepItem(2, "Thanh toán", isActive: _currentStep == 1, isCompleted: false),
              ],
            ),
          ),
          
          const SizedBox(height: 10),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: _currentStep == 0 
                  ? _buildShippingInfoStep() 
                  : _buildPaymentStep(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShippingInfoStep() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Thông tin giao hàng", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Divider(height: 30, thickness: 1, color: Colors.grey),
            
            _buildLabel("Địa chỉ nhận hàng"),
            _buildTextField(hint: "Ví dụ: 123 Đường Nguyễn Huệ", controller: _addressController),
            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Tỉnh/Thành phố"),
                      _buildTextField(hint: "TP.HCM", controller: _cityController),
                    ],
                  )
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Mã bưu điện"),
                      _buildTextField(hint: "700000", controller: _zipController),
                    ],
                  )
                ),
              ],
            ),
            const SizedBox(height: 15),

            _buildLabel("Số điện thoại"),
            _buildTextField(hint: "0912 345 678", controller: _phoneController),
            
            const SizedBox(height: 30),
            
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1976D2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  elevation: 0,
                ),
                onPressed: _goToPayment, 
                child: const Text("Tiếp tục thanh toán", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentStep() {
    return Column(
      children: [
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Phương thức thanh toán", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const Divider(height: 30, thickness: 1, color: Colors.grey),
                
                _buildLabel("Chọn phương thức"),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedPaymentMethod,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down),
                      items: const [
                        DropdownMenuItem(value: 'visa', child: Text("Thẻ tín dụng quốc tế (Visa/Master)")),
                        DropdownMenuItem(value: 'momo', child: Text("Ví điện tử MoMo")),
                        DropdownMenuItem(value: 'atm', child: Text("Thẻ ghi nợ nội địa")),
                        DropdownMenuItem(value: 'cod', child: Text("Thanh toán khi nhận hàng (COD)")),
                      ],
                      onChanged: (val) {
                        setState(() {
                          _selectedPaymentMethod = val!;
                        });
                      },
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                _buildDynamicPaymentContent(),

                const SizedBox(height: 20),

                _buildLabel("Mã khuyến mãi (nếu có)"),
                Row(
                  children: [
                     Expanded(
                       child: _buildTextField(hint: "Nhập mã voucher", controller: _promoController),
                     ),
                     const SizedBox(width: 10),
                     SizedBox(
                       height: 48,
                       child: OutlinedButton(
                         onPressed: () {},
                         style: OutlinedButton.styleFrom(
                           side: const BorderSide(color: Color(0xFF1976D2)),
                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                         ),
                         child: const Text("Áp dụng", style: TextStyle(color: Color(0xFF1976D2))),
                       ),
                     )
                  ],
                ),
                
                const SizedBox(height: 20),
                
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1976D2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      elevation: 0,
                    ),
                    onPressed: _finishOrder, 
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.credit_card, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text("Đặt hàng • 29,99 VND", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Tóm tắt đơn hàng", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                _buildSummaryRow("Cáp nguồn cổng sạc iPhone (x1)", "24,99 VND", isBold: false),
                const Divider(height: 30),
                _buildSummaryRow("Tạm tính", "24,99 VND", isBold: false),
                const SizedBox(height: 8),
                _buildSummaryRow("Phí giao hàng", "5,000 VND", isBold: false),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text("Tổng cộng", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text("29,99 VND", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1976D2))),
                  ],
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDynamicPaymentContent() {
    switch (_selectedPaymentMethod) {
      case 'visa':
      case 'atm':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel("Số thẻ"),
            _buildTextField(hint: "0000 0000 0000 0000"),
            const SizedBox(height: 12),
            _buildLabel("Tên in trên thẻ"),
            _buildTextField(hint: "NGUYEN VAN A"),
            const SizedBox(height: 12),
            Row(
              children: [
                 Expanded(
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       _buildLabel("Ngày hết hạn"),
                       _buildTextField(hint: "MM/YY"),
                     ],
                   )
                 ),
                 const SizedBox(width: 12),
                 Expanded(
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       _buildLabel("Mã CVC/CVV"),
                       _buildTextField(hint: "***"),
                     ],
                   )
                 ),
              ],
            ),
          ],
        );

      case 'momo':
        return Center(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.pink[50], borderRadius: BorderRadius.circular(8)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.qr_code, color: Colors.pink),
                SizedBox(width: 10),
                Text("Mở App MoMo để quét mã thanh toán", style: TextStyle(color: Colors.pink)),
              ],
            ),
          ),
        );

      case 'cod':
        return const Text(
            "Bạn sẽ thanh toán bằng tiền mặt khi nhận hàng.",
            style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(text, style: TextStyle(fontSize: 14, color: Colors.grey[700], fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildTextField({required String hint, TextEditingController? controller}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Color(0xFF1976D2))),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: 14)),
      ],
    );
  }

  Widget _buildStepItem(int step, String label, {required bool isActive, required bool isCompleted}) {
    Color circleColor = isActive ? const Color(0xFF2E7D32) : (isCompleted ? const Color(0xFF1976D2) : Colors.grey[300]!);
    Color textColor = isActive ? const Color(0xFF1976D2) : Colors.grey;
    
    return Row(
      children: [
        Container(
          width: 24, height: 24,
          decoration: BoxDecoration(
            color: circleColor, 
            shape: BoxShape.circle
          ),
          child: Center(
            child: Text("$step", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(color: textColor, fontWeight: isActive ? FontWeight.bold : FontWeight.normal, fontSize: 14)),
      ],
    );
  }
}