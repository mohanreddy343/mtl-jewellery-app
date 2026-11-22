import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/admin_api_service.dart';

/// Admin: add, edit (name + image) and delete categories and subcategories.
class AdminCategoriesScreen extends StatefulWidget {
  const AdminCategoriesScreen({super.key});

  @override
  State<AdminCategoriesScreen> createState() => _AdminCategoriesScreenState();
}

class _AdminCategoriesScreenState extends State<AdminCategoriesScreen> {
  static const Color _accent = Color(0xFFFFA000);

  List<AdminCategory> _items = [];
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
      final list = await AdminApi.getCategories();
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

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ── Image helpers ──────────────────────────────────────────────────────────
  Future<String?> _pickImagePath() async {
    final x = await ImagePicker().pickImage(
        source: ImageSource.gallery, maxWidth: 800, imageQuality: 85);
    return x?.path;
  }

  /// Square picker box shown inside the add / edit dialogs.
  Widget _imageBox({
    String? localPath,
    String? url,
    required VoidCallback onPick,
  }) {
    Widget child;
    if (localPath != null) {
      child = Image.file(File(localPath), fit: BoxFit.cover);
    } else if (url != null && url.isNotEmpty) {
      child = Image.network(url,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
          const Icon(Icons.broken_image_outlined, color: Colors.grey));
    } else {
      child = const Icon(Icons.add_photo_alternate_outlined,
          color: _accent, size: 32);
    }
    return GestureDetector(
      onTap: onPick,
      child: Container(
        width: 90,
        height: 90,
        clipBehavior: Clip.antiAlias,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: child,
      ),
    );
  }

  /// Small thumbnail in the category list.
  Widget _thumb(AdminCategory c) {
    return Container(
      width: 44,
      height: 44,
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: c.imageUrl.isNotEmpty
          ? Image.network(c.imageUrl,
          width: 44,
          height: 44,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
          const Icon(Icons.broken_image_outlined, color: Colors.grey))
          : Icon(
          c.isParent
              ? Icons.folder_outlined
              : Icons.subdirectory_arrow_right,
          color: c.isParent ? _accent : Colors.grey),
    );
  }

  // ── Actions ────────────────────────────────────────────────────────────────
  Future<void> _run(Future<void> Function() action, String done) async {
    try {
      await action();
      if (!mounted) return;
      _toast(done);
      _load();
    } catch (e) {
      if (!mounted) return;
      _toast(e.toString());
    }
  }

  // Add dialog: image + name + optional main category (blank = new main category)
  Future<void> _add({int? parentId}) async {
    final nameCtrl = TextEditingController();
    int? selectedParent = parentId;
    String? pickedPath;
    final parents = _items.where((c) => c.isParent).toList();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: const Text('Add category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _imageBox(
                localPath: pickedPath,
                onPick: () async {
                  final p = await _pickImagePath();
                  if (p != null) setLocal(() => pickedPath = p);
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameCtrl,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int?>(
                value: selectedParent,
                isExpanded: true,
                decoration:
                const InputDecoration(labelText: 'Put under (optional)'),
                items: [
                  const DropdownMenuItem<int?>(
                      value: null, child: Text('Main category')),
                  ...parents.map((p) =>
                      DropdownMenuItem<int?>(value: p.id, child: Text(p.name))),
                ],
                onChanged: (v) => setLocal(() => selectedParent = v),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel')),
            TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Add')),
          ],
        ),
      ),
    );
    if (ok != true) return;
    final name = nameCtrl.text.trim();
    if (name.isEmpty) {
      _toast('Enter a category name');
      return;
    }
    await _run(() async {
      final img =
      pickedPath == null ? '' : await AdminApi.uploadImage(pickedPath!);
      await AdminApi.addCategory(name, parentId: selectedParent, image: img);
    }, 'Category added');
  }

  // Edit dialog: change the name and/or the image
  Future<void> _rename(AdminCategory c) async {
    final ctrl = TextEditingController(text: c.name);
    String? pickedPath;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: const Text('Edit category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _imageBox(
                localPath: pickedPath,
                url: c.imageUrl,
                onPick: () async {
                  final p = await _pickImagePath();
                  if (p != null) setLocal(() => pickedPath = p);
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ctrl,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel')),
            TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Save')),
          ],
        ),
      ),
    );
    if (ok != true) return;
    final name = ctrl.text.trim();
    if (name.isEmpty) return;
    if (name == c.name && pickedPath == null) return;
    await _run(() async {
      final img =
      pickedPath == null ? null : await AdminApi.uploadImage(pickedPath!);
      await AdminApi.renameCategory(c.id, name, image: img);
    }, 'Category saved');
  }

  Future<void> _delete(AdminCategory c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete category'),
        content: Text('Delete "${c.fullName}"?'),
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
    await _run(() => AdminApi.deleteCategory(c.id), 'Category deleted');
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text('Categories',
            style: TextStyle(
                color: Colors.black87,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _accent,
        foregroundColor: Colors.white,
        onPressed: _loading ? null : () => _add(),
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
      return const Center(child: Text('No categories yet.'));
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

  Widget _tile(AdminCategory c) {
    return Padding(
      padding: EdgeInsets.only(left: c.isParent ? 0 : 28),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: _thumb(c),
        title: Text(c.name,
            style: TextStyle(
                fontWeight: c.isParent ? FontWeight.w700 : FontWeight.w500)),
        subtitle: Text('${c.productCount} product(s)'),
        onTap: () => _rename(c),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (c.isParent)
              IconButton(
                tooltip: 'Add subcategory',
                icon: const Icon(Icons.add_circle_outline, color: _accent),
                onPressed: () => _add(parentId: c.id),
              ),
            IconButton(
              tooltip: 'Delete',
              icon: const Icon(Icons.delete_outline, color: Color(0xFFE02020)),
              onPressed: () => _delete(c),
            ),
          ],
        ),
      ),
    );
  }
}