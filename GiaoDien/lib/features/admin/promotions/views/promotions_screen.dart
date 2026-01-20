import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../view_models/promotions_view_model.dart';

class PromotionsScreen extends StatefulWidget {
  const PromotionsScreen({super.key});

  @override
  State<PromotionsScreen> createState() => _PromotionsScreenState();
}

class _PromotionsScreenState extends State<PromotionsScreen> {
  final _codeController = TextEditingController();
  final _discountController = TextEditingController();
  final _minOrderController = TextEditingController();
  final _qtyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // GỌI API LẤY DỮ LIỆU NGAY KHI VÀO MÀN HÌNH
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PromotionsViewModel>().loadPromotions();
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    _discountController.dispose();
    _minOrderController.dispose();
    _qtyController.dispose();
    super.dispose();
  }

  // ... (Giữ nguyên hàm _showAddPromoSheet của bạn không cần sửa)
  void _showAddPromoSheet(BuildContext context) {
    // Copy lại y nguyên nội dung hàm _showAddPromoSheet cũ của bạn vào đây
    // Vì hàm này bạn viết logic form đã ổn rồi.
    // ... (Code cũ) ...
    // Để ngắn gọn mình không paste lại đoạn này, bạn giữ nguyên nhé.

    // Tuy nhiên, lưu ý đoạn: Provider.of<PromotionsViewModel>(context, listen: false);
    // Nó sẽ hoạt động tốt khi bạn sửa hàm build bên dưới.

    // --- DÁN CODE CŨ CỦA BẠN VÀO ĐÂY ---
    final viewModel = Provider.of<PromotionsViewModel>(context, listen: false);
    viewModel.resetForm();

    _codeController.clear();
    _discountController.clear();
    _minOrderController.clear();
    _qtyController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Consumer<PromotionsViewModel>(
          builder: (context, vm, child) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        "Tạo Khuyến Mãi",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _codeController,
                      decoration: const InputDecoration(
                        labelText: 'Mã Code (VD: TET2025)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _discountController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Giảm (VNĐ)',
                              suffixText: 'đ',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _qtyController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Số lượng',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _minOrderController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Đơn tối thiểu',
                        suffixText: 'đ',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // ... (Phần chọn ngày giữ nguyên) ...
                    const Text(
                      "Thời gian áp dụng:",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.calendar_today, size: 16),
                            label: Text(
                              DateFormat('dd/MM/yyyy').format(vm.tempStartDate),
                            ),
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: vm.tempStartDate,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2030),
                              );
                              if (picked != null) vm.updateDate(start: picked);
                            },
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text("➜"),
                        ),
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.event, size: 16),
                            label: Text(
                              DateFormat('dd/MM/yyyy').format(vm.tempEndDate),
                            ),
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: vm.tempEndDate,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2030),
                              );
                              if (picked != null) vm.updateDate(end: picked);
                            },
                          ),
                        ),
                      ],
                    ),

                    if (vm.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 5),
                        child: Center(
                          child: Text(
                            vm.errorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),

                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: vm.isLoading
                            ? null
                            : () async {
                                bool success = await vm.createPromotion(
                                  code: _codeController.text,
                                  amountStr: _discountController.text,
                                  minOrderStr: _minOrderController.text,
                                  qtyStr: _qtyController.text,
                                );
                                if (success && context.mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("✅ Thành công!"),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              },
                        child: vm.isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'Hoàn tất',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // SỬA QUAN TRỌNG TẠI ĐÂY:
    // Không dùng ChangeNotifierProvider ở đây nữa, vì đã có ở main.dart
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quản lý Khuyến mãi"),
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
      ),
      body: Consumer<PromotionsViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Hiển thị thêm lỗi nếu có (để debug vì sao list rỗng)
          if (viewModel.promotions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Danh sách trống"),
                  if (viewModel.errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      "Lỗi: ${viewModel.errorMessage}",
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => viewModel.loadPromotions(),
                    child: const Text("Tải lại"),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: viewModel.promotions.length,
            itemBuilder: (context, index) {
              final promo = viewModel.promotions[index];
              return Card(
                child: ListTile(
                  title: Text(
                    promo.code,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  // Format tiền cho đẹp
                  subtitle: Text(
                    "Giảm: ${NumberFormat('#,###').format(promo.discountAmount)} đ",
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => viewModel.deletePromotion(promo.id),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPromoSheet(context),
        backgroundColor: const Color(0xFF2563EB),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
