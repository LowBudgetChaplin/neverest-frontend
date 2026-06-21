import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../access/presentation/cubit/access_cubit.dart';
import '../../../dashboard/domain/dashboard_data.dart';
import '../../../dashboard/presentation/bloc/dashboard_bloc.dart';
import '../../../shell/presentation/design/neverest_design.dart';
import '../../data/partner_repository.dart';
import 'partner_scan_screen.dart';

class PartnerCenterScreen extends StatefulWidget {
  const PartnerCenterScreen({super.key});

  @override
  State<PartnerCenterScreen> createState() => _PartnerCenterScreenState();
}

class _PartnerCenterScreenState extends State<PartnerCenterScreen> {
  final _brandController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _discountController = TextEditingController();
  final _linkController = TextEditingController();
  String? _imageB64;
  String? _editingImageB64;
  String? _editingId;
  DateTime? _validFrom;
  DateTime? _validUntil;

  bool _busy = false;
  List<OfferSummary> _offers = const [];

  final _chTitleController = TextEditingController();
  final _chDescriptionController = TextEditingController();
  final _chRewardController = TextEditingController();
  String _chActivity = 'RUNNING';
  String? _editingChallengeId;
  List<ChallengeSummary> _myChallenges = const [];

  final _rwTitleController = TextEditingController();
  final _rwPartnerController = TextEditingController();
  final _rwDescriptionController = TextEditingController();
  final _rwCostController = TextEditingController();
  final _rwStockController = TextEditingController();
  String? _editingRewardId;
  List<RewardSummary> _myRewards = const [];

  static const _activityTypes = ['RUNNING', 'MOUNTAIN', 'PADEL'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _brandController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _discountController.dispose();
    _linkController.dispose();
    _chTitleController.dispose();
    _chDescriptionController.dispose();
    _chRewardController.dispose();
    _rwTitleController.dispose();
    _rwPartnerController.dispose();
    _rwDescriptionController.dispose();
    _rwCostController.dispose();
    _rwStockController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _busy = true);
    try {
      final repo = context.read<PartnerRepository>();
      final offers = await repo.getMyOffers();
      final challenges = await repo.getMyChallenges();
      final rewards = await repo.getMyRewards();
      if (!mounted) return;
      setState(() {
        _offers = offers;
        _myChallenges = challenges;
        _myRewards = rewards;
      });
    } catch (e) {
      _toast('${AppLocalizations.of(context)!.commonError}: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _saveChallenge() async {
    final l10n = AppLocalizations.of(context)!;
    if (_chTitleController.text.trim().isEmpty ||
        _chRewardController.text.trim().isEmpty) {
      _toast(l10n.partnerChallengeRequired);
      return;
    }
    setState(() => _busy = true);
    try {
      final repo = context.read<PartnerRepository>();
      if (_editingChallengeId != null) {
        await repo.updateChallenge(
          challengeId: _editingChallengeId!,
          title: _chTitleController.text,
          description: _chDescriptionController.text,
          activityType: _chActivity,
          rewardLabel: _chRewardController.text,
        );
      } else {
        await repo.createChallenge(
          title: _chTitleController.text,
          description: _chDescriptionController.text,
          activityType: _chActivity,
          rewardLabel: _chRewardController.text,
        );
      }
      _cancelChallengeEdit();
      if (mounted) {
        context.read<DashboardBloc>().add(const DashboardRefreshRequested());
      }
      await _load();
    } catch (e) {
      _toast('${l10n.commonError}: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _startEditChallenge(ChallengeSummary c) {
    setState(() {
      _editingChallengeId = c.id;
      _chTitleController.text = c.title;
      _chDescriptionController.text = c.description ?? '';
      _chRewardController.text = c.rewardLabel ?? '';
      _chActivity = _activityTypes.contains(c.activityType.toUpperCase())
          ? c.activityType.toUpperCase()
          : 'RUNNING';
    });
  }

  void _cancelChallengeEdit() {
    setState(() {
      _editingChallengeId = null;
      _chTitleController.clear();
      _chDescriptionController.clear();
      _chRewardController.clear();
      _chActivity = 'RUNNING';
    });
  }

  Future<void> _deleteChallenge(String id) async {
    setState(() => _busy = true);
    try {
      await context.read<PartnerRepository>().deleteChallenge(id);
      if (mounted) {
        context.read<DashboardBloc>().add(const DashboardRefreshRequested());
      }
      await _load();
    } catch (e) {
      _toast('${AppLocalizations.of(context)!.commonError}: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _saveReward() async {
    final l10n = AppLocalizations.of(context)!;
    final title = _rwTitleController.text.trim();
    final partner = _rwPartnerController.text.trim();
    final cost = int.tryParse(_rwCostController.text.trim());
    if (title.isEmpty || partner.isEmpty || cost == null || cost <= 0) {
      _toast('Titlu, brand și cost (puncte > 0) sunt obligatorii.');
      return;
    }
    final stock = int.tryParse(_rwStockController.text.trim());
    setState(() => _busy = true);
    try {
      final repo = context.read<PartnerRepository>();
      if (_editingRewardId != null) {
        await repo.updateReward(
          rewardId: _editingRewardId!,
          title: title,
          partnerName: partner,
          description: _rwDescriptionController.text,
          pointsCost: cost,
          stock: stock,
        );
      } else {
        await repo.createReward(
          title: title,
          partnerName: partner,
          description: _rwDescriptionController.text.trim().isEmpty
              ? title
              : _rwDescriptionController.text,
          pointsCost: cost,
          stock: stock,
        );
      }
      _cancelRewardEdit();
      if (mounted) {
        context.read<DashboardBloc>().add(const DashboardRefreshRequested());
      }
      await _load();
    } catch (e) {
      _toast('${l10n.commonError}: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _startEditReward(RewardSummary r) {
    setState(() {
      _editingRewardId = r.id;
      _rwTitleController.text = r.title;
      _rwPartnerController.text = r.partnerName;
      _rwDescriptionController.text = r.description ?? '';
      _rwCostController.text = r.pointsCost.toString();
      _rwStockController.text = r.stock?.toString() ?? '';
    });
  }

  void _cancelRewardEdit() {
    setState(() {
      _editingRewardId = null;
      _rwTitleController.clear();
      _rwPartnerController.clear();
      _rwDescriptionController.clear();
      _rwCostController.clear();
      _rwStockController.clear();
    });
  }

  Future<void> _deleteReward(String id) async {
    setState(() => _busy = true);
    try {
      await context.read<PartnerRepository>().deleteReward(id);
      if (mounted) {
        context.read<DashboardBloc>().add(const DashboardRefreshRequested());
      }
      await _load();
    } catch (e) {
      _toast('${AppLocalizations.of(context)!.commonError}: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pickImage() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      imageQuality: 85,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    final compressed = await FlutterImageCompress.compressWithList(
      bytes,
      minWidth: 600,
      quality: 70,
      format: CompressFormat.jpeg,
    );
    if (!mounted) return;
    setState(() => _imageB64 = 'data:image/jpeg;base64,${base64Encode(compressed)}');
  }

  void _startEdit(OfferSummary o) {
    setState(() {
      _editingId = o.id;
      _brandController.text = o.brand;
      _titleController.text = o.title;
      _descriptionController.text = o.description ?? '';
      _discountController.text = o.discountLabel ?? '';
      _linkController.text = o.linkUrl ?? '';
      _imageB64 = null;
      _editingImageB64 = o.imageB64;
      _validFrom = o.validFrom != null ? DateTime.tryParse(o.validFrom!) : null;
      _validUntil =
          o.validUntil != null ? DateTime.tryParse(o.validUntil!) : null;
    });
  }

  void _cancelEdit() {
    setState(() {
      _editingId = null;
      _brandController.clear();
      _titleController.clear();
      _descriptionController.clear();
      _discountController.clear();
      _linkController.clear();
      _imageB64 = null;
      _editingImageB64 = null;
      _validFrom = null;
      _validUntil = null;
    });
  }

  Future<void> _pickDate(bool from) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: (from ? _validFrom : _validUntil) ?? now,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365 * 2)),
    );
    if (picked == null) return;
    setState(() {
      if (from) {
        _validFrom = picked;
      } else {
        _validUntil = picked;
      }
    });
  }

  String _dateLabel(DateTime? d) {
    if (d == null) return '—';
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  String? _iso(DateTime? d) => d == null ? null : d.toIso8601String().split('.').first;

  Widget _thumbnail() {
    final src = _imageB64 ?? _editingImageB64;
    if (src == null || src.isEmpty) {
      return Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: NeverestPalette.orangeSoft,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.image_outlined,
            color: NeverestPalette.orange, size: 24),
      );
    }
    try {
      final raw = src.contains(',') ? src.split(',').last : src;
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.memory(base64Decode(raw),
            width: 56, height: 56, fit: BoxFit.cover),
      );
    } catch (_) {
      return const SizedBox(width: 56, height: 56);
    }
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    if (_brandController.text.trim().isEmpty ||
        _titleController.text.trim().isEmpty) {
      _toast(l10n.partnerBrandTitleRequired);
      return;
    }
    setState(() => _busy = true);
    try {
      final repo = context.read<PartnerRepository>();
      if (_editingId != null) {
        await repo.updateOffer(
          offerId: _editingId!,
          brand: _brandController.text,
          title: _titleController.text,
          description: _descriptionController.text,
          discountLabel: _discountController.text,
          imageB64: _imageB64,
          linkUrl: _linkController.text,
          validFromIso: _iso(_validFrom),
          validUntilIso: _iso(_validUntil),
        );
        _toast(l10n.partnerOfferUpdated);
      } else {
        await repo.createOffer(
          brand: _brandController.text,
          title: _titleController.text,
          description: _descriptionController.text,
          discountLabel: _discountController.text,
          imageB64: _imageB64,
          linkUrl: _linkController.text,
          validFromIso: _iso(_validFrom),
          validUntilIso: _iso(_validUntil),
        );
        _toast(l10n.partnerOfferPublished);
      }
      _cancelEdit();
      if (mounted) {
        context.read<DashboardBloc>().add(const DashboardRefreshRequested());
      }
      await _load();
    } catch (e) {
      _toast('${AppLocalizations.of(context)!.commonError}: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete(String id) async {
    setState(() => _busy = true);
    try {
      await context.read<PartnerRepository>().deleteOffer(id);
      if (mounted) {
        context.read<DashboardBloc>().add(const DashboardRefreshRequested());
      }
      await _load();
    } catch (e) {
      _toast('${AppLocalizations.of(context)!.commonError}: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final canOpen = context.select<AccessCubit, bool>(
      (c) => c.state.canOpenPartnerCenter,
    );
    if (!canOpen) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.partnerCenterTitle)),
        body: Center(child: Text(l10n.partnerAccessRequired)),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.partnerCenterTitle),
        actions: [
          IconButton(
            tooltip: 'Scanează cod',
            icon: const Icon(Icons.qr_code_scanner_rounded),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PartnerScanScreen()),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_busy) const LinearProgressIndicator(minHeight: 2),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      _editingId == null
                          ? l10n.partnerPublishOffer
                          : l10n.partnerEditOffer,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _brandController,
                    decoration: InputDecoration(labelText: l10n.partnerBrand),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                        labelText: l10n.partnerOfferTitleField),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _descriptionController,
                    minLines: 2,
                    maxLines: 4,
                    decoration: InputDecoration(
                        labelText: l10n.partnerDescriptionField),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _discountController,
                    decoration: InputDecoration(
                      labelText: l10n.partnerDiscountHint,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _linkController,
                    decoration: InputDecoration(
                      labelText: l10n.partnerLinkOptional,
                      hintText: 'https://...',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _thumbnail(),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _busy ? null : _pickImage,
                          icon: const Icon(Icons.image_outlined),
                          label: Text(
                            (_imageB64 != null || _editingImageB64 != null)
                                ? l10n.partnerChangePhoto
                                : l10n.partnerAddPhoto,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _busy ? null : () => _pickDate(true),
                          icon: const Icon(Icons.event_available, size: 16),
                          label: Text(
                              '${l10n.partnerFrom}: ${_dateLabel(_validFrom)}',
                              overflow: TextOverflow.ellipsis),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _busy ? null : () => _pickDate(false),
                          icon: const Icon(Icons.event_busy, size: 16),
                          label: Text(
                              '${l10n.partnerUntil}: ${_dateLabel(_validUntil)}',
                              overflow: TextOverflow.ellipsis),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // acțiuni (full-width, fără overflow)
                  Row(
                    children: [
                      if (_editingId != null) ...[
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _busy ? null : _cancelEdit,
                            child: Text(l10n.commonCancel),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        flex: 2,
                        child: FilledButton.icon(
                          onPressed: _busy ? null : _save,
                          icon: Icon(_editingId == null
                              ? Icons.campaign_outlined
                              : Icons.save_outlined),
                          label: Text(_editingId == null
                              ? l10n.partnerPublish
                              : l10n.partnerSave),
                        ),
                      ),
                      if (_editingId == null) ...[
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: _busy ? null : _cancelEdit,
                          icon: const Icon(Icons.restart_alt_rounded),
                          label: const Text('Reset'),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(l10n.partnerMyOffers,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (_offers.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(l10n.partnerNoOffers),
            )
          else
            ..._offers.map(
              (o) => Card(
                child: ListTile(
                  title: Text(o.title),
                  subtitle: Text(
                    '${o.brand}${o.discountLabel != null ? ' · ${o.discountLabel}' : ''}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: _busy ? null : () => _startEdit(o),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: _busy ? null : () => _delete(o.id),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _editingChallengeId == null
                        ? l10n.partnerCreateChallenge
                        : l10n.partnerEditChallenge,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _chTitleController,
                    decoration: InputDecoration(
                        labelText: l10n.partnerOfferTitleField),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _chDescriptionController,
                    minLines: 2,
                    maxLines: 3,
                    decoration: InputDecoration(
                        labelText: l10n.partnerDescriptionField),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _chActivity,
                    items: _activityTypes
                        .map((t) =>
                            DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: _busy
                        ? null
                        : (v) => setState(() => _chActivity = v ?? _chActivity),
                    decoration: InputDecoration(labelText: l10n.partnerActivity),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _chRewardController,
                    decoration: InputDecoration(
                      labelText: l10n.partnerBenefitLabel,
                      hintText: 'ex: -20% la print',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (_editingChallengeId != null) ...[
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _busy ? null : _cancelChallengeEdit,
                            child: Text(l10n.commonCancel),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        flex: 2,
                        child: FilledButton.icon(
                          onPressed: _busy ? null : _saveChallenge,
                          icon: Icon(_editingChallengeId == null
                              ? Icons.flag_outlined
                              : Icons.save_outlined),
                          label: Text(_editingChallengeId == null
                              ? l10n.partnerPublish
                              : l10n.partnerSave),
                        ),
                      ),
                      if (_editingChallengeId == null) ...[
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: _busy ? null : _cancelChallengeEdit,
                          icon: const Icon(Icons.restart_alt_rounded),
                          label: const Text('Reset'),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (_myChallenges.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(l10n.partnerNoChallenges),
            )
          else
            ..._myChallenges.map(
              (c) => Card(
                child: ListTile(
                  title: Text(c.title),
                  subtitle: Text(
                    '${c.activityType}${c.rewardLabel != null ? ' · ${c.rewardLabel}' : ''}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed:
                            _busy ? null : () => _startEditChallenge(c),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: _busy ? null : () => _deleteChallenge(c.id),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _editingRewardId == null
                        ? 'Creează beneficiu (puncte)'
                        : 'Editează beneficiul',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _rwTitleController,
                    decoration:
                        InputDecoration(labelText: l10n.partnerOfferTitleField),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _rwPartnerController,
                    decoration: InputDecoration(labelText: l10n.partnerBrand),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _rwDescriptionController,
                    minLines: 2,
                    maxLines: 3,
                    decoration: InputDecoration(
                        labelText: l10n.partnerDescriptionField),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _rwCostController,
                          keyboardType: TextInputType.number,
                          decoration:
                              const InputDecoration(labelText: 'Cost (puncte)'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _rwStockController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              labelText: 'Stoc (opțional)'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (_editingRewardId != null) ...[
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _busy ? null : _cancelRewardEdit,
                            child: Text(l10n.commonCancel),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        flex: 2,
                        child: FilledButton.icon(
                          onPressed: _busy ? null : _saveReward,
                          icon: Icon(_editingRewardId == null
                              ? Icons.card_giftcard_outlined
                              : Icons.save_outlined),
                          label: Text(_editingRewardId == null
                              ? l10n.partnerPublish
                              : l10n.partnerSave),
                        ),
                      ),
                      if (_editingRewardId == null) ...[
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: _busy ? null : _cancelRewardEdit,
                          icon: const Icon(Icons.restart_alt_rounded),
                          label: const Text('Reset'),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (_myRewards.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Niciun beneficiu creat.'),
            )
          else
            ..._myRewards.map(
              (r) => Card(
                child: ListTile(
                  title: Text(r.title),
                  subtitle: Text(
                    '${r.partnerName} · ${r.pointsCost} pct'
                    '${r.stock != null ? ' · stoc ${r.stock}' : ''}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: _busy ? null : () => _startEditReward(r),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: _busy ? null : () => _deleteReward(r.id),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
