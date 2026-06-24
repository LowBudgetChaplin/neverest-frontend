import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../admin/data/admin_repository.dart';
import '../../../dashboard/domain/dashboard_data.dart';
import '../../../dashboard/presentation/bloc/dashboard_bloc.dart';
import '../../../shell/presentation/design/neverest_design.dart';

class RewardEditScreen extends StatefulWidget {
  const RewardEditScreen({super.key, required this.reward});

  final RewardSummary reward;

  @override
  State<RewardEditScreen> createState() => _RewardEditScreenState();
}

class _RewardEditScreenState extends State<RewardEditScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _partnerController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _pointsController;
  late final TextEditingController _stockController;
  late final TextEditingController _addressController;

  String? _imageB64;
  bool _imageChanged = false;
  bool _saving = false;

  List<RewardCategory> _categories = const [];
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    final r = widget.reward;
    _titleController = TextEditingController(text: r.title);
    _partnerController = TextEditingController(text: r.partnerName);
    _descriptionController = TextEditingController(text: r.description ?? '');
    _pointsController = TextEditingController(text: r.pointsCost.toString());
    _stockController =
        TextEditingController(text: r.stock?.toString() ?? '');
    _addressController = TextEditingController(text: r.address ?? '');
    _imageB64 = r.imageB64;
    _selectedCategory =
        (r.category != null && r.category!.trim().isNotEmpty)
            ? r.category!.trim().toUpperCase()
            : null;
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await context.read<AdminRepository>().getRewardCategories();
      if (!mounted) return;
      setState(() {
        _categories = cats;
        // Daca valoarea curenta nu e in lista, o pastram doar daca exista.
        if (_selectedCategory != null &&
            !cats.any((c) => c.code == _selectedCategory)) {
          _selectedCategory = null;
        }
      });
    } catch (_) {
      // Optional; daca nu se incarca, dropdown-ul ramane fara optiuni.
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _partnerController.dispose();
    _descriptionController.dispose();
    _pointsController.dispose();
    _addressController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasImage = _imageB64 != null && _imageB64!.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.rewardEditTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          _ImagePreview(imageB64: _imageB64, accent: NeverestPalette.orange),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _saving ? null : _pickImage,
                  icon: const Icon(Icons.add_photo_alternate_outlined),
                  label: Text(l10n.rewardEditChangePhoto),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: (_saving || !hasImage) ? null : _removeImage,
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: Text(l10n.rewardEditRemovePhoto),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            enabled: !_saving,
            decoration: InputDecoration(labelText: l10n.rewardEditFieldTitle),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _partnerController,
            enabled: !_saving,
            decoration: InputDecoration(labelText: l10n.rewardEditFieldPartner),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            isExpanded: true,
            decoration:
                InputDecoration(labelText: l10n.rewardEditFieldCategory),
            items: [
              DropdownMenuItem<String>(
                value: null,
                child: Text(l10n.rewardCategoryNone),
              ),
              ..._categories.map(
                (c) => DropdownMenuItem<String>(
                  value: c.code,
                  child: Text(
                    c.label(Localizations.localeOf(context).languageCode),
                  ),
                ),
              ),
            ],
            onChanged: _saving
                ? null
                : (value) => setState(() => _selectedCategory = value),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _descriptionController,
            enabled: !_saving,
            minLines: 2,
            maxLines: 4,
            decoration:
                InputDecoration(labelText: l10n.rewardEditFieldDescription),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _pointsController,
                  enabled: !_saving,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration:
                      InputDecoration(labelText: l10n.rewardEditFieldPoints),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _stockController,
                  enabled: !_saving,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: l10n.rewardEditFieldStock,
                    hintText: l10n.rewardEditStockHint,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _addressController,
            enabled: !_saving,
            decoration: InputDecoration(labelText: l10n.rewardEditFieldAddress),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.commonConfirm),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1000,
      maxHeight: 1000,
      imageQuality: 85,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    final compressed = await FlutterImageCompress.compressWithList(
      bytes,
      minWidth: 600,
      minHeight: 600,
      quality: 70,
      format: CompressFormat.jpeg,
    );
    if (!mounted) return;
    setState(() {
      _imageB64 = 'data:image/jpeg;base64,${base64Encode(compressed)}';
      _imageChanged = true;
    });
  }

  void _removeImage() {
    setState(() {
      _imageB64 = null;
      _imageChanged = true;
    });
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final points = int.tryParse(_pointsController.text.trim());
    if (_titleController.text.trim().isEmpty ||
        points == null ||
        points <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.rewardEditValidation)),
      );
      return;
    }
    final stockText = _stockController.text.trim();
    final stock = stockText.isEmpty ? null : int.tryParse(stockText);

    setState(() => _saving = true);
    try {
      await context.read<AdminRepository>().updateReward(
            rewardId: widget.reward.id,
            title: _titleController.text,
            partnerName: _partnerController.text,
            description: _descriptionController.text,
            pointsCost: points,
            stock: stock,
            clearStock: stockText.isEmpty,
            address: _addressController.text,
            imageB64: (_imageChanged && _imageB64 != null) ? _imageB64 : null,
            clearImage: _imageChanged && _imageB64 == null,
            category: _selectedCategory ?? '',
          );
      if (!mounted) return;
      context.read<DashboardBloc>().add(const DashboardRefreshRequested());
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({required this.imageB64, required this.accent});

  final String? imageB64;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 170,
        width: double.infinity,
        color: accent,
        child: NeverestRewardImage(imageB64: imageB64, fallbackColor: accent),
      ),
    );
  }
}
