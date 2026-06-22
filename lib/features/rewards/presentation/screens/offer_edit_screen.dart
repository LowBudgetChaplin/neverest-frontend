import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../dashboard/domain/dashboard_data.dart';
import '../../../dashboard/presentation/bloc/dashboard_bloc.dart';
import '../../../partner/data/partner_repository.dart';

class OfferEditScreen extends StatefulWidget {
  const OfferEditScreen({super.key, required this.offer});

  final OfferSummary offer;

  @override
  State<OfferEditScreen> createState() => _OfferEditScreenState();
}

class _OfferEditScreenState extends State<OfferEditScreen> {
  late final TextEditingController _brandController;
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _discountController;
  late final TextEditingController _linkController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final o = widget.offer;
    _brandController = TextEditingController(text: o.brand);
    _titleController = TextEditingController(text: o.title);
    _descriptionController = TextEditingController(text: o.description ?? '');
    _discountController = TextEditingController(text: o.discountLabel ?? '');
    _linkController = TextEditingController(text: o.linkUrl ?? '');
  }

  @override
  void dispose() {
    _brandController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _discountController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    if (_brandController.text.trim().isEmpty ||
        _titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.offerRequiredToast)),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await context.read<PartnerRepository>().adminUpdateOffer(
            offerId: widget.offer.id,
            brand: _brandController.text,
            title: _titleController.text,
            description: _descriptionController.text,
            discountLabel: _discountController.text,
            linkUrl: _linkController.text,
          );
      if (!mounted) return;
      context.read<DashboardBloc>().add(const DashboardRefreshRequested());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.offerSavedToast)),
      );
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.offerEditTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _brandController,
            enabled: !_saving,
            decoration: InputDecoration(labelText: l10n.offerBrandLabel),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _titleController,
            enabled: !_saving,
            decoration: InputDecoration(labelText: l10n.offerTitleLabel),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _descriptionController,
            enabled: !_saving,
            minLines: 2,
            maxLines: 4,
            decoration: InputDecoration(labelText: l10n.offerDescriptionLabel),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _discountController,
            enabled: !_saving,
            decoration: InputDecoration(labelText: l10n.offerDiscountLabel),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _linkController,
            enabled: !_saving,
            decoration: InputDecoration(labelText: l10n.offerLinkLabel),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.commonSave),
          ),
        ],
      ),
    );
  }
}
