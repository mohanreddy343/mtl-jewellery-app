import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/admin_api_service.dart';

/// Admin: list, add, edit and delete products.
class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  static const Color _accent = Color(0xFFFFA000);

  List<AdminProduct> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await AdminApi.getProducts();
      if (!mounted) return;
      setState(() {
        _items = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _openForm([AdminProduct? product]) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => AdminProductForm(product: product)),
    );
    if (saved == true) _load();
  }

  Future<void> _delete(AdminProduct p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete product'),
        content: Text('Delete "${p.name}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('No')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Yes')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await AdminApi.deleteProduct(p.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Product deleted')));
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text('Products',
            style: TextStyle(
                color: Colors.black87,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _accent,
        foregroundColor: Colors.white,
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
      body: _body(),
    );
  }

  Widget _body() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: _accent));
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _load, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (_items.isEmpty) {
      return const Center(child: Text('No products yet.'));
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
        itemCount: _items.length,
        separatorBuilder: (_, __) =>
            Divider(height: 1, color: Colors.grey.shade200),
        itemBuilder: (_, i) => _tile(_items[i]),
      ),
    );
  }

  Widget _tile(AdminProduct p) {
    final out = p.quantity == 0;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(p.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
        'ID ${p.id}  •  KWD ${kwd(p.price)}  •  '
            '${out ? 'Out of stock' : 'Stock ${p.quantity}'}  •  ${p.categoryName}',
        style: TextStyle(color: out ? const Color(0xFFE02020) : null),
      ),
      onTap: () => _openForm(p),
      trailing: IconButton(
        tooltip: 'Delete',
        icon: const Icon(Icons.delete_outline, color: Color(0xFFE02020)),
        onPressed: () => _delete(p),
      ),
    );
  }
}

// ── Add / edit form ──────────────────────────────────────────────────────────
class AdminProductForm extends StatefulWidget {
  final AdminProduct? product; // null = add new
  const AdminProductForm({super.key, this.product});

  @override
  State<AdminProductForm> createState() => _AdminProductFormState();
}

class _AdminProductFormState extends State<AdminProductForm> {
  static const Color _accent = Color(0xFFFFA000);

  late final TextEditingController _name;
  late final TextEditingController _price;
  late final TextEditingController _original;
  late final TextEditingController _qty;
  late final TextEditingController _weight;
  late final TextEditingController _sku;
  late final TextEditingController _image;
  late final TextEditingController _variantOf;

  List<AdminCategory> _cats = [];
  int? _categoryId;
  bool _loadingCats = true;
  bool _saving = false;
  String? _error;
  File? _pickedFile;
  final ImagePicker _picker = ImagePicker();

  bool get _isEdit => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _name = TextEditingController(text: p?.name ?? '');
    _price = TextEditingController(text: p == null ? '' : kwd(p.price));
    _original =
        TextEditingController(text: p == null ? '' : kwd(p.originalPrice));
    _qty = TextEditingController(text: p == null ? '' : '${p.quantity}');
    _weight = TextEditingController(text: p?.weight ?? '');
    _sku = TextEditingController(text: p?.sku ?? '');
    _image = TextEditingController(text: p?.image ?? '');
    _variantOf = TextEditingController(
        text: (p != null && p.groupId.isNotEmpty && p.groupId != p.id)
            ? p.groupId
            : '');
    _categoryId = p?.categoryId;
    _loadCategories();
  }

  @override
  void dispose() {
    for (final c in [
      _name, _price, _original, _qty, _weight, _sku, _image, _variantOf
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final list = await AdminApi.getCategories();
      if (!mounted) return;
      setState(() {
        _cats = list;
        _loadingCats = false;
        // keep the saved category only if it still exists
        if (_categoryId != null && !list.any((c) => c.id == _categoryId)) {
          _categoryId = null;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loadingCats = false;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final x = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        imageQuality: 85,
      );
      if (x == null || !mounted) return;
      setState(() => _pickedFile = File(x.path));
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Could not open gallery: $e');
    }
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    final price = double.tryParse(_price.text.trim());
    final original = _original.text.trim().isEmpty
        ? price
        : double.tryParse(_original.text.trim());
    final qty = int.tryParse(_qty.text.trim());

    String? problem;
    if (name.isEmpty) {
      problem = 'Enter the product name';
    } else if (price == null || price < 0) {
      problem = 'Enter a valid price';
    } else if (original == null || original < 0) {
      problem = 'Enter a valid original price';
    } else if (qty == null || qty < 0) {
      problem = 'Enter the stock quantity (whole number)';
    } else if (_categoryId == null) {
      problem = 'Select a category';
    }
    if (problem != null) {
      setState(() => _error = problem);
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      var imageName = _image.text.trim();
      if (_pickedFile != null) {
        imageName = await AdminApi.uploadImage(_pickedFile!.path);
      }
      await AdminApi.saveProduct(
        {
          'name': name,
          'price': price,
          'originalPrice': original,
          'quantity': qty,
          'categoryId': _categoryId,
          'weight': _weight.text.trim(),
          'sku': _sku.text.trim(),
          'image': imageName,
          'variantOf': _variantOf.text.trim(),
        },
        id: widget.product?.id,
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = e.toString();
      });
    }
  }

  Widget _field(TextEditingController c, String label,
      {bool number = false, bool decimal = false, String? hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: c,
        keyboardType: number
            ? TextInputType.numberWithOptions(decimal: decimal)
            : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text(_isEdit ? 'Edit product' : 'Add product',
            style: const TextStyle(
                color: Colors.black87,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _field(_name, 'Product name'),
          Row(
            children: [
              Expanded(
                  child: _field(_price, 'Price (KWD)',
                      number: true, decimal: true)),
              const SizedBox(width: 12),
              Expanded(
                  child: _field(_original, 'Original price',
                      number: true, decimal: true, hint: 'optional')),
            ],
          ),
          _field(_qty, 'Stock quantity', number: true),
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _loadingCats
                ? const LinearProgressIndicator(color: _accent)
                : DropdownButtonFormField<int>(
              value: _categoryId,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: _cats
                  .map((c) => DropdownMenuItem<int>(
                  value: c.id, child: Text(c.fullName)))
                  .toList(),
              onChanged: (v) => setState(() => _categoryId = v),
            ),
          ),
          _field(_weight, 'Weight / size', hint: 'e.g. 200g'),
          _field(_sku, 'SKU', hint: 'leave empty to generate'),
          _field(_variantOf, 'Main product ID (only for sizes)',
              number: true, hint: 'e.g. 12 to make this a size of product 12'),
          GestureDetector(
            onTap: _saving ? null : _pickImage,
            child: Container(
              height: 160,
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 14),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: _pickedFile != null
                  ? Image.file(_pickedFile!, fit: BoxFit.cover)
                  : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_photo_alternate_outlined,
                      size: 40, color: _accent),
                  const SizedBox(height: 8),
                  Text(
                    _image.text.isEmpty
                        ? 'Choose image from album'
                        : 'Current: ${_image.text}\nTap to replace',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
          ),
          _field(_image, 'Image file name (optional)',
              hint: 'filled automatically when you upload'),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(_error!,
                  style: const TextStyle(color: Color(0xFFE02020))),
            ),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _accent,
                foregroundColor: Colors.white,
              ),
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
                  : Text(_isEdit ? 'Save changes' : 'Add product'),
            ),
          ),
        ],
      ),
    );
  }
}