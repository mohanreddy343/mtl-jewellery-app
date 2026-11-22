import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../model/banner_model.dart';
import '../services/admin_api_service.dart';

/// Admin: list, add, edit and delete home screen banners.
class AdminBannersScreen extends StatefulWidget {
  const AdminBannersScreen({super.key});

  @override
  State<AdminBannersScreen> createState() => _AdminBannersScreenState();
}

class _AdminBannersScreenState extends State<AdminBannersScreen> {
  static const Color _accent = Color(0xFFFFA000);

  List<BannerModel> _items = [];
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
      final list = await AdminApi.getBanners();
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

  Future<void> _openForm([BannerModel? banner]) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => AdminBannerForm(banner: banner)),
    );
    if (saved == true) _load();
  }

  Future<void> _delete(BannerModel b) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete banner'),
        content: const Text('Delete this banner?'),
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
      await AdminApi.deleteBanner(b.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Banner deleted')));
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
        title: const Text('Banners',
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
      return const Center(child: Text('No banners yet.'));
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) => _card(_items[i]),
      ),
    );
  }

  Widget _card(BannerModel b) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _openForm(b),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 130,
              width: double.infinity,
              child: Image.network(
                b.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey.shade100,
                  child: const Icon(Icons.broken_image_outlined),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 4, 6),
              child: Row(
                children: [
                  Icon(b.hasLink ? Icons.link : Icons.link_off,
                      size: 18, color: b.hasLink ? _accent : Colors.grey),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      b.hasLink ? b.link : 'No link',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 13, color: Colors.grey.shade700),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Delete',
                    icon: const Icon(Icons.delete_outline,
                        color: Color(0xFFE02020)),
                    onPressed: () => _delete(b),
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

// ── Add / edit form ──────────────────────────────────────────────────────────
class AdminBannerForm extends StatefulWidget {
  final BannerModel? banner; // null = add new
  const AdminBannerForm({super.key, this.banner});

  @override
  State<AdminBannerForm> createState() => _AdminBannerFormState();
}

class _AdminBannerFormState extends State<AdminBannerForm> {
  static const Color _accent = Color(0xFFFFA000);

  late final TextEditingController _link;
  final ImagePicker _picker = ImagePicker();
  File? _pickedFile;
  bool _saving = false;
  String? _error;

  bool get _isEdit => widget.banner != null;

  @override
  void initState() {
    super.initState();
    _link = TextEditingController(text: widget.banner?.link ?? '');
  }

  @override
  void dispose() {
    _link.dispose();
    super.dispose();
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
    final link = _link.text.trim();
    if (!_isEdit && _pickedFile == null) {
      setState(() => _error = 'Choose a banner image');
      return;
    }
    if (link.isNotEmpty && !RegExp(r'^https?://\S+$', caseSensitive: false).hasMatch(link)) {
      setState(() => _error = 'Link must start with http:// or https://');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      String? imageName;
      if (_pickedFile != null) {
        imageName = await AdminApi.uploadImage(_pickedFile!.path);
      }
      if (_isEdit) {
        await AdminApi.updateBanner(widget.banner!.id, link, image: imageName);
      } else {
        await AdminApi.addBanner(imageName!, link);
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text(_isEdit ? 'Edit banner' : 'Add banner',
            style: const TextStyle(
                color: Colors.black87,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GestureDetector(
            onTap: _saving ? null : _pickImage,
            child: Container(
              height: 180,
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
                  : (_isEdit && widget.banner!.imageUrl.isNotEmpty)
                  ? Image.network(widget.banner!.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                  const Icon(Icons.broken_image_outlined))
                  : const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate_outlined,
                      size: 40, color: _accent),
                  SizedBox(height: 8),
                  Text('Choose banner image from album',
                      style: TextStyle(color: Colors.black54)),
                ],
              ),
            ),
          ),
          if (_isEdit)
            const Padding(
              padding: EdgeInsets.only(bottom: 14),
              child: Text('Tap the picture to replace it.',
                  style: TextStyle(color: Colors.black54, fontSize: 12)),
            ),
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: TextField(
              controller: _link,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                labelText: 'Link (optional)',
                hintText: 'https://example.com/offer',
                border: OutlineInputBorder(),
              ),
            ),
          ),
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
                  : Text(_isEdit ? 'Save changes' : 'Add banner'),
            ),
          ),
        ],
      ),
    );
  }
}