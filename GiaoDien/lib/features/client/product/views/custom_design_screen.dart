import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../data/models/design_item.dart';
import '../../../../data/models/product_model.dart';
import '../../../../data/providers/cart_provider.dart';

class CustomDesignScreen extends StatefulWidget {
  const CustomDesignScreen({super.key});

  @override
  State<CustomDesignScreen> createState() => _CustomDesignScreenState();
}

class _CustomDesignScreenState extends State<CustomDesignScreen> {
  final GlobalKey _globalKey = GlobalKey();

  int _currentStep = 1;
  String? _selectedBrand;
  String? _selectedQuality;
  String? _selectedMaterial;

  int _selectedToolIndex = 0;
  Uint8List? _uploadedImageBytes;
  final ImagePicker _picker = ImagePicker();
  List<DesignItem> _designItems = [];
  String _userText = "";
  Color _userTextColor = Colors.black;
  String? _selectedSticker;

  final List<String> _brands = ["iPhone", "Samsung", "Xiaomi", "Oppo"];

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _uploadedImageBytes = bytes;
        });
      }
    } catch (e) {
      debugPrint("Lỗi chọn ảnh: $e");
    }
  }

  void _addTextLayer() {
    if (_userText.isNotEmpty) {
      setState(() {
        _designItems.add(
          DesignItem(
            id: DateTime.now().toString(),
            type: 'text',
            content: _userText,
            color: _userTextColor,
            position: const Offset(50, 150),
          ),
        );
        _userText = "";
        FocusScope.of(context).unfocus();
      });
    }
  }

  void _addStickerLayer(String iconChar) {
    setState(() {
      _selectedSticker = iconChar;
      _designItems.add(
        DesignItem(
          id: DateTime.now().toString(),
          type: 'sticker',
          content: iconChar,
          position: const Offset(50, 200),
        ),
      );
    });
  }

  void _removeLayer(String id) {
    setState(() {
      _designItems.removeWhere((item) => item.id == id);
    });
  }

  Future<Uint8List?> _captureDesign() async {
    try {
      RenderRepaintBoundary boundary =
          _globalKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint("Lỗi chụp ảnh thiết kế: $e");
      return null;
    }
  }

  void _addToCart() async {
    Uint8List? finalDesignImage = await _captureDesign();

    if (finalDesignImage == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Lỗi xử lý ảnh thiết kế!")));
      return;
    }

    final customProduct = Product(
      id: 'custom_case_${DateTime.now().millisecondsSinceEpoch}',
      name: "Ốp lưng $_selectedBrand Tự thiết kế",
      price: 169000,
      imageUrl: '',
      color: 'Custom Design',
      storage: _selectedMaterial ?? 'Standard',
      type: 'accessory',
      condition: 'new',
      brand: _selectedBrand ?? 'Custom',
    );

    String customDetailText = _designItems
        .where((e) => e.type == 'text')
        .map((e) => e.content)
        .join(", ");

    if (!mounted) return;

    context.read<CartProvider>().addItem(
      customProduct,
      quantity: 1,
      isCustom: true,
      img: finalDesignImage,
      text: customDetailText.isNotEmpty ? customDetailText : null,
      sticker: _selectedSticker,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Đã thêm vào giỏ hàng thành công!")),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Tự thiết kế ốp lưng',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            color: const Color(0xFFEEEEEE),
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStepCircle("1", "Chọn máy", _currentStep >= 1),
                _buildStepConnector(),
                _buildStepCircle("2", "Chất liệu", _currentStep >= 2),
                _buildStepConnector(),
                _buildStepCircle("3", "Thiết kế", _currentStep >= 3),
              ],
            ),
          ),

          Expanded(
            child: _currentStep == 3
                ? _buildStep3_Design()
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: _currentStep == 1 ? _buildStep1() : _buildStep2(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Bước 1: Chọn điện thoại",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _brands.map((brand) {
            bool isSelected = _selectedBrand == brand;
            return SizedBox(
              width: (MediaQuery.of(context).size.width - 48) / 4,
              height: 40,
              child: ElevatedButton(
                onPressed: () => setState(() {
                  _selectedBrand = brand;
                  _currentStep = 2;
                }),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected
                      ? Colors.deepOrange
                      : Colors.grey.shade200,
                  foregroundColor: isSelected ? Colors.white : Colors.black87,
                  padding: EdgeInsets.zero,
                  elevation: 0,
                ),
                child: Text(
                  brand,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => setState(() => _currentStep = 1),
            ),
            Text(
              "Bước 2: $_selectedBrand",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          "1. Chất lượng in:",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildQualityOption(
                "CHẤT LƯỢNG THẤP",
                "69.000đ",
                3,
                "Thấp",
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildQualityOption(
                "CHẤT LƯỢNG CAO",
                "139.000đ",
                5,
                "Cao",
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Text(
          "2. Loại ốp:",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 8),
        GridView.count(
          shrinkWrap: true,
          crossAxisCount: 2,
          childAspectRatio: 4,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: [
            _buildCaseTypeBtn("VIỀN DẺO ĐEN"),
            _buildCaseTypeBtn("TRÁNG GƯƠNG"),
            _buildCaseTypeBtn("DẺO TRONG"),
            _buildCaseTypeBtn("NHỰA CỨNG"),
          ],
        ),
      ],
    );
  }

  Widget _buildStep3_Design() {
    bool isSamsung = _selectedBrand == "Samsung";

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          color: Colors.grey.shade100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () => setState(() => _currentStep = 2),
                child: const Row(
                  children: [
                    Icon(Icons.arrow_back, size: 16),
                    Text("Quay lại"),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: _addToCart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  "THÊM VÀO GIỎ",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 60,
                color: Colors.black,
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildToolIcon(1, Icons.camera_alt, "Ảnh"),
                    _buildToolIcon(2, Icons.text_fields, "Chữ"),
                    _buildToolIcon(3, Icons.filter_vintage, "Trang trí"),
                  ],
                ),
              ),

              if (_selectedToolIndex != 0)
                Container(
                  width: 140,
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedToolIndex == 1
                            ? "Tải ảnh"
                            : _selectedToolIndex == 2
                            ? "Thêm chữ"
                            : "Trang trí",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Divider(),
                      Expanded(
                        child: _selectedToolIndex == 1
                            ? Center(
                                child: ElevatedButton.icon(
                                  onPressed: _pickImage,
                                  icon: const Icon(Icons.upload, size: 16),
                                  label: const Text(
                                    "Chọn ảnh",
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.deepOrange,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              )
                            : _selectedToolIndex == 2
                            ? Column(
                                children: [
                                  TextField(
                                    onChanged: (val) =>
                                        setState(() => _userText = val),
                                    decoration: const InputDecoration(
                                      hintText: "Nhập tên...",
                                      isDense: true,
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 5,
                                    children:
                                        [
                                              Colors.black,
                                              Colors.red,
                                              Colors.blue,
                                              Colors.green,
                                              Colors.yellow,
                                            ]
                                            .map(
                                              (c) => GestureDetector(
                                                onTap: () => setState(
                                                  () => _userTextColor = c,
                                                ),
                                                child: CircleAvatar(
                                                  backgroundColor: c,
                                                  radius: 10,
                                                  child: _userTextColor == c
                                                      ? const Icon(
                                                          Icons.check,
                                                          size: 12,
                                                          color: Colors.grey,
                                                        )
                                                      : null,
                                                ),
                                              ),
                                            )
                                            .toList(),
                                  ),
                                  const SizedBox(height: 10),
                                  ElevatedButton(
                                    onPressed: _addTextLayer,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.deepOrange,
                                    ),
                                    child: const Text(
                                      "Thêm",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              )
                            : GridView.count(
                                crossAxisCount: 2,
                                children: ["🌸", "🌹", "🍁", "⭐", "❤️", "🔥"]
                                    .map(
                                      (e) => GestureDetector(
                                        onTap: () => _addStickerLayer(e),
                                        child: Center(
                                          child: Text(
                                            e,
                                            style: const TextStyle(
                                              fontSize: 30,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                      ),
                    ],
                  ),
                ),

              Expanded(
                child: Container(
                  color: Colors.white,
                  child: Center(
                    child: RepaintBoundary(
                      key: _globalKey,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 200,
                            height: 400,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(
                                isSamsung ? 8 : 30,
                              ),
                              border: Border.all(
                                color: Colors.grey.shade400,
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 15,
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                isSamsung ? 8 : 30,
                              ),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  if (_uploadedImageBytes != null)
                                    Image.memory(
                                      _uploadedImageBytes!,
                                      fit: BoxFit.cover,
                                    ),

                                  ..._designItems
                                      .map((item) => _buildDraggableItem(item))
                                      .toList(),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            top: 20,
                            left: 20,
                            child: IgnorePointer(
                              child: isSamsung
                                  ? _buildSamsungCamera()
                                  : _buildIphoneCamera(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDraggableItem(DesignItem item) {
    return Positioned(
      left: item.position.dx,
      top: item.position.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            item.position += details.delta;
          });
        },
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.blue.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: item.type == 'text'
                  ? Text(
                      item.content,
                      style: TextStyle(
                        color: item.color,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : Text(item.content, style: const TextStyle(fontSize: 40)),
            ),
            GestureDetector(
              onTap: () => _removeLayer(item.id),
              child: const Icon(Icons.cancel, size: 16, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQualityOption(
    String title,
    String price,
    int stars,
    String value,
  ) {
    bool isSelected = _selectedQuality == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedQuality = value),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.deepOrange : Colors.grey.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(6),
          color: isSelected ? Colors.orange.shade50 : Colors.white,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (index) => Icon(
                  Icons.star,
                  size: 12,
                  color: index < stars ? Colors.amber : Colors.grey.shade300,
                ),
              ),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            ),
            Text(
              price,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.deepOrange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaseTypeBtn(String name) {
    return OutlinedButton(
      onPressed: () => setState(() {
        if (_selectedQuality != null) {
          _selectedMaterial = name;
          _currentStep = 3;
        }
      }),
      style: OutlinedButton.styleFrom(
        side: BorderSide(
          color: _selectedMaterial == name
              ? Colors.deepOrange
              : Colors.grey.shade300,
        ),
        backgroundColor: _selectedMaterial == name
            ? Colors.orange.shade50
            : Colors.white,
      ),
      child: Text(
        name,
        style: TextStyle(
          fontSize: 11,
          color: _selectedMaterial == name ? Colors.deepOrange : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildSamsungCamera() {
    return SizedBox(
      width: 80,
      height: 120,
      child: Stack(
        children: [
          Positioned(top: 0, left: 0, child: _camCircle(18)),
          Positioned(top: 40, left: 0, child: _camCircle(18)),
          Positioned(top: 80, left: 0, child: _camCircle(18)),
          Positioned(top: 10, left: 45, child: _camCircle(12)),
          Positioned(top: 50, left: 45, child: _camCircle(10)),
        ],
      ),
    );
  }

  Widget _buildIphoneCamera() => Container(
    width: 90,
    height: 90,
    decoration: BoxDecoration(
      color: Colors.black12,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.grey.shade400),
    ),
    child: const Icon(Icons.camera_alt, color: Colors.black26),
  );
  Widget _camCircle(double size) => Container(
    width: size * 2,
    height: size * 2,
    decoration: BoxDecoration(
      color: Colors.black87,
      shape: BoxShape.circle,
      border: Border.all(color: Colors.grey.shade400, width: 2),
    ),
  );

  Widget _buildToolIcon(int index, IconData icon, String label) {
    bool isSelected = _selectedToolIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedToolIndex = isSelected ? 0 : index),
      child: Container(
        width: 60,
        padding: const EdgeInsets.symmetric(vertical: 15),
        color: isSelected ? Colors.deepOrange : Colors.black,
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepCircle(String step, String title, bool isActive) => Column(
    children: [
      Container(
        width: 35,
        height: 35,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(
            color: isActive ? Colors.deepOrange : Colors.grey.shade400,
            width: 2,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          step,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.deepOrange : Colors.grey,
          ),
        ),
      ),
      const SizedBox(height: 4),
      Text(
        title,
        style: TextStyle(
          fontSize: 10,
          color: isActive ? Colors.black : Colors.grey,
        ),
      ),
    ],
  );
  Widget _buildStepConnector() =>
      Container(width: 30, height: 1, color: Colors.grey.shade300);
}
