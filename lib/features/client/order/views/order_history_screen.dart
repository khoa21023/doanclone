import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/order_view_model.dart';
import '../../../../data/models/order.dart';

class OrderHistoryScreen extends StatelessWidget{
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context){
    return ChangeNotifierProvider(
      create: (_) => OrderViewModel(),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: (){}, 
            icon: Icon(Icons.arrow_back)
            ),
          title: const Text("Lịch sử mua hàng"),
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
        ),
        body: Consumer<OrderViewModel>(
          builder: (context, vm, _){
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: vm.orders.length,
              itemBuilder: (context, index){
                return OrderCard(order: vm.orders[index]);
              },
              );
          }
          ),
      )
    );
  }
}

class OrderCard extends StatelessWidget {
  final Order order;
  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const Divider(height: 24),
            // map(_buildItem) biến mỗi sản phẩm thành 1 Widget
            //// Dấu ... (spread operator) dùng để "trải" danh sách Widget ra cho childrenn
            // Không ... ->children: [ [Widget, Widget, Widget] ] || Có ...->children: [ Widget, Widget, Widget ]
            ...order.items.map(_buildItem),
            const Divider(height: 24),
            _buildTotal(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Đơn hàng ${order.id}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatDate(order.createdAt),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        _StatusBadge(),
      ],
    );
  }

  Widget _buildItem(OrderItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  'Số lượng: ${item.quantity}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _formatPrice(item.price),
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildTotal() {
    return Row(
      children: [
        const Text(
          'Tổng thành tiền',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const Spacer(),
        Text(
          _formatPrice(order.total),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2563EB),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} - '
        '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatPrice(double price) {
    return '${price.toStringAsFixed(2)} VND';
  }
}

class _StatusBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'Đã đặt',
        style: TextStyle(
          fontSize: 12,
          color: Colors.orange,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}