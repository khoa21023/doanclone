import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../view_models/checkout_view_model.dart';
import '../../cart/view_models/cart_view_model.dart';
import 'package:url_launcher/url_launcher.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _currentStep = 0;
  String _selectedPaymentMethod = 'cod';

  // Thêm NameController
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _zipController =
      TextEditingController(); // Có thể dùng làm Ghi chú nếu muốn
  final _phoneController = TextEditingController();
  final _promoController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _zipController.dispose();
    _phoneController.dispose();
    _promoController.dispose();
    super.dispose();
  }

  void _goToPayment() {
    // Validate cơ bản trước khi qua bước 2
    if (_nameController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập đủ thông tin giao hàng")),
      );
      return;
    }
    setState(() {
      _currentStep = 1;
    });
  }

  // Hàm xử lý đặt hàng
  void _finishOrder(
    BuildContext context,
    CheckoutViewModel viewModel,
    CartViewModel cart,
  ) async {
    final fullAddress = "${_addressController.text}, ${_cityController.text}";

    // 1. Gọi API tạo đơn
    bool success = await viewModel.placeOrder(
      name: _nameController.text,
      phone: _phoneController.text,
      address: fullAddress,
      note: _zipController.text,
      paymentMethod: _selectedPaymentMethod,
      cartViewModel: cart,
    );

    if (!context.mounted) return;

    if (success) {
      // 2. Xử lý thành công

      // TRƯỜNG HỢP A: Thanh toán Online (Visa/PayOS) -> Có link thanh toán
      if (viewModel.checkoutUrl != null && viewModel.checkoutUrl!.isNotEmpty) {
        final Uri uri = Uri.parse(viewModel.checkoutUrl!);

        try {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } catch (e) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Không thể mở liên kết: $e")));
        }
        if (!context.mounted) return;
        // Sau khi mở link, có thể pop về trang chủ hoặc trang "Chờ thanh toán"
        Navigator.popUntil(context, (route) => route.isFirst);
      }
      // TRƯỜNG HỢP B: Thanh toán COD (Tiền mặt) -> Không có link
      else {
        Navigator.popUntil(context, (route) => route.isFirst);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("🎉 Đặt hàng thành công!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      // 3. Xử lý thất bại
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage ?? "Đặt hàng thất bại."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _goBack() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lấy dữ liệu giỏ hàng để hiện tiền thật
    final cart = Provider.of<CartViewModel>(context);

    return ChangeNotifierProvider(
      create: (_) => CheckoutViewModel(),
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: const Color(0xFF2563EB),
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
        body: Consumer<CheckoutViewModel>(
          builder: (context, checkoutVM, child) {
            // Hiển thị loading khi đang gọi API
            if (checkoutVM.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return Column(
              children: [
                // STEPPER
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStepItem(
                        1,
                        "Thông tin",
                        isActive: _currentStep == 0,
                        isCompleted: _currentStep > 0,
                      ),
                      Container(
                        width: 50,
                        height: 2,
                        color: Colors.grey[300],
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                      ),
                      _buildStepItem(
                        2,
                        "Thanh toán",
                        isActive: _currentStep == 1,
                        isCompleted: false,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // NỘI DUNG
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: _currentStep == 0
                        ? _buildShippingInfoStep()
                        : _buildPaymentStep(context, checkoutVM, cart),
                  ),
                ),
              ],
            );
          },
        ),
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
            const Text(
              "Thông tin giao hàng",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 30, thickness: 1, color: Colors.grey),

            // THÊM Ô HỌ TÊN
            _buildLabel("Họ tên người nhận"),
            _buildTextField(hint: "Nguyễn Văn A", controller: _nameController),
            const SizedBox(height: 15),

            _buildLabel("Số điện thoại"),
            _buildTextField(
              hint: "0912 345 678",
              controller: _phoneController,
              isNumber: true,
            ),
            const SizedBox(height: 15),

            _buildLabel("Địa chỉ nhận hàng"),
            _buildTextField(
              hint: "123 Đường Nguyễn Huệ",
              controller: _addressController,
            ),
            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Tỉnh/Thành phố"),
                      _buildTextField(
                        hint: "TP.HCM",
                        controller: _cityController,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Ghi chú (Tùy chọn)"),
                      _buildTextField(
                        hint: "Giao giờ hành chính...",
                        controller: _zipController,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  elevation: 0,
                ),
                onPressed: _goToPayment,
                child: const Text(
                  "Tiếp tục thanh toán",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentStep(
    BuildContext context,
    CheckoutViewModel vm,
    CartViewModel cart,
  ) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

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
                const Text(
                  "Phương thức thanh toán",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
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
                        DropdownMenuItem(
                          value: 'cod',
                          child: Text("Thanh toán khi nhận hàng (COD)"),
                        ),
                        DropdownMenuItem(
                          value: 'visa',
                          child: Text("Thẻ tín dụng quốc tế (Visa/Master)"),
                        ),
                      ],
                      onChanged: (val) =>
                          setState(() => _selectedPaymentMethod = val!),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildDynamicPaymentContent(),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      elevation: 0,
                    ),
                    // GỌI HÀM ĐẶT HÀNG
                    onPressed: () => _finishOrder(context, vm, cart),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Đặt hàng • ${currencyFormat.format(cart.summary.total)}", // Hiển thị giá thật
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // TÓM TẮT ĐƠN HÀNG
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Tóm tắt đơn hàng",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                // Liệt kê sản phẩm ngắn gọn
                ...cart.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: _buildSummaryRow(
                      "${item.name} (x${item.quantity})",
                      currencyFormat.format(item.totalItemPrice),
                    ),
                  ),
                ),

                const Divider(height: 30),
                _buildSummaryRow(
                  "Tạm tính",
                  currencyFormat.format(cart.summary.subTotal),
                ),
                const SizedBox(height: 8),
                _buildSummaryRow(
                  "Phí giao hàng",
                  currencyFormat.format(cart.summary.shippingFee),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Tổng cộng",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      currencyFormat.format(cart.summary.total),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ],
                ),
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
        return const Text(
          "Chức năng thanh toán thẻ đang bảo trì. Vui lòng chọn COD.",
          style: TextStyle(color: Colors.red),
        );
      case 'cod':
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            children: [
              Icon(Icons.local_shipping, color: Colors.blue),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Bạn sẽ thanh toán bằng tiền mặt khi nhận hàng.",
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[700],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    TextEditingController? controller,
    bool isNumber = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Color(0xFF2563EB)),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildStepItem(
    int step,
    String label, {
    required bool isActive,
    required bool isCompleted,
  }) {
    Color circleColor = isActive
        ? const Color(0xFF2E7D32)
        : (isCompleted ? const Color(0xFF2563EB) : Colors.grey[300]!);
    Color textColor = isActive ? const Color(0xFF2563EB) : Colors.grey;
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(color: circleColor, shape: BoxShape.circle),
          child: Center(
            child: Text(
              "$step",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: textColor,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
