import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/promotions_view_model.dart';
import '../../../../data/models/promotion.dart';

class PromotionsScreen extends StatefulWidget {
  const PromotionsScreen({super.key});

  @override
  State<PromotionsScreen> createState() => _PromotionsScreenState();
}

class _PromotionsScreenState extends State<PromotionsScreen> {
  final _codeController = TextEditingController();
  final _discountController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  void _showAddPromoSheet(BuildContext context) {
    _codeController.clear();
    _discountController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Tạo khuyến mãi mới",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _codeController,
              decoration: const InputDecoration(
                labelText: "Mã giảm giá (VD: SAVE20)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _discountController,
              decoration: const InputDecoration(
                labelText: "Phần trăm giảm (%)",
                suffixText: "%",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (_codeController.text.isEmpty ||
                      _discountController.text.isEmpty) {
                    return;
                  }

                  final codeInput = _codeController.text.toUpperCase();
                  final discountInput =
                      int.tryParse(_discountController.text) ?? 0;

                  context.read<PromotionsViewModel>().addPromotion(
                        Promotion(
                          id: "PROMO-${DateTime.now().millisecondsSinceEpoch}",
                          type: "voucher",
                          code: codeInput,
                          discountPercent: discountInput,
                          isActive: true,
                          expiresAt: DateTime.now().add(
                            const Duration(days: 30),
                          ),
                        ),
                      );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                ),
                child: const Text("Lưu khuyến mãi"),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PromotionsViewModel()..loadPromotions(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Quản lý khuyến mãi"),
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
        ),
        body: Consumer<PromotionsViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.promotions.isEmpty) {
              return const Center(child: Text("Chưa có khuyến mãi nào"));
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: viewModel.promotions.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final promo = viewModel.promotions[index];
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: promo.isActive ? Colors.white : Colors.grey.shade200,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: CircleAvatar(
                      radius: 24,
                      backgroundColor: promo.type == 'voucher'
                          ? Colors.orange.shade100
                          : Colors.blue.shade100,
                      child: Icon(
                        promo.type == 'voucher'
                            ? Icons.confirmation_number
                            : Icons.inventory_2,
                        color: promo.type == 'voucher'
                            ? Colors.orange.shade700
                            : Colors.blue.shade700,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      promo.type == 'voucher'
                          ? 'Mã: ${promo.code}'
                          : 'Sản phẩm giảm giá',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: promo.isActive
                            ? null
                            : TextDecoration.lineThrough,
                        color: promo.isActive ? Colors.black87 : Colors.grey,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          'Giảm: ${promo.discountPercent}%',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Hết hạn: ${promo.expiresAt.day}/${promo.expiresAt.month}/${promo.expiresAt.year}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: promo.isActive,
                          activeColor: const Color(0xFF2563EB),
                          onChanged: (val) =>
                              viewModel.togglePromotion(promo.id),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          onPressed: () => viewModel.deletePromotion(promo.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
        floatingActionButton: Builder(
          builder: (context) {
            return FloatingActionButton(
              onPressed: () => _showAddPromoSheet(context),
              backgroundColor: const Color(0xFF2563EB),
              child: const Icon(Icons.add, color: Colors.white),
            );
          },
        ),
      ),
    );
  }
}