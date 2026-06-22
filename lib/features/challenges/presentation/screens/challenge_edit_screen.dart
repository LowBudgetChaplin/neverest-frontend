import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../dashboard/domain/dashboard_data.dart';
import '../../../dashboard/presentation/bloc/dashboard_bloc.dart';
import '../../data/challenge_action_repository.dart';

class ChallengeEditScreen extends StatefulWidget {
  const ChallengeEditScreen({super.key, required this.challenge});

  final ChallengeSummary challenge;

  @override
  State<ChallengeEditScreen> createState() => _ChallengeEditScreenState();
}

class _ChallengeEditScreenState extends State<ChallengeEditScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _pointsController;
  late final TextEditingController _targetValueController;
  late final TextEditingController _targetUnitController;

  late String _activity;
  DateTime? _startsAt;
  DateTime? _endsAt;
  bool _saving = false;

  static const _activities = ['RUNNING', 'MOUNTAIN', 'PADEL'];

  @override
  void initState() {
    super.initState();
    final c = widget.challenge;
    _titleController = TextEditingController(text: c.title);
    _descriptionController = TextEditingController(text: c.description ?? '');
    _pointsController = TextEditingController(text: c.pointsReward.toString());
    _targetValueController =
        TextEditingController(text: c.targetValue?.toString() ?? '');
    _targetUnitController = TextEditingController(text: c.targetUnit ?? '');
    _activity = _activities.contains(c.activityType.toUpperCase())
        ? c.activityType.toUpperCase()
        : 'RUNNING';
    _startsAt = c.startsAt != null ? DateTime.tryParse(c.startsAt!) : null;
    _endsAt = c.endsAt != null ? DateTime.tryParse(c.endsAt!) : null;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _pointsController.dispose();
    _targetValueController.dispose();
    _targetUnitController.dispose();
    super.dispose();
  }

  String _dateLabel(DateTime? d) {
    if (d == null) return '—';
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  Future<void> _pickDate(bool start) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: (start ? _startsAt : _endsAt) ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 2)),
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (start) {
        _startsAt = picked;
      } else {
        _endsAt = picked;
      }
    });
  }

  Future<void> _save() async {
    final points = int.tryParse(_pointsController.text.trim());
    if (_titleController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty ||
        points == null ||
        points <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Titlu, descriere si puncte (>0) sunt obligatorii.')),
      );
      return;
    }
    final targetRaw = _targetValueController.text.trim().replaceAll(',', '.');
    final targetValue = targetRaw.isEmpty ? null : double.tryParse(targetRaw);
    if (targetRaw.isNotEmpty && targetValue == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Valoarea tinta trebuie sa fie numerica.')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await context.read<ChallengeActionRepository>().updateChallenge(
            challengeId: widget.challenge.id,
            title: _titleController.text,
            description: _descriptionController.text,
            activityType: _activity,
            pointsReward: points,
            targetValue: targetValue,
            targetUnit: _targetUnitController.text,
            startsAtIso: _startsAt?.toIso8601String().split('.').first,
            endsAtIso: _endsAt?.toIso8601String().split('.').first,
          );
      if (!mounted) return;
      context.read<DashboardBloc>().add(const DashboardRefreshRequested());
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
    return Scaffold(
      appBar: AppBar(title: const Text('Editeaza obiectiv')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _titleController,
            enabled: !_saving,
            decoration: const InputDecoration(labelText: 'Titlu'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _descriptionController,
            enabled: !_saving,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'Descriere'),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _activity,
            items: _activities
                .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                .toList(),
            onChanged:
                _saving ? null : (v) => setState(() => _activity = v ?? _activity),
            decoration: const InputDecoration(labelText: 'Tip activitate'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _pointsController,
            enabled: !_saving,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Puncte'),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _targetValueController,
                  enabled: !_saving,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration:
                      const InputDecoration(labelText: 'Valoare tinta (optional)'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _targetUnitController,
                  enabled: !_saving,
                  decoration: const InputDecoration(
                    labelText: 'Unitate (ex: km)',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _saving ? null : () => _pickDate(true),
                  icon: const Icon(Icons.event_available, size: 16),
                  label: Text('Start: ${_dateLabel(_startsAt)}',
                      overflow: TextOverflow.ellipsis),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _saving ? null : () => _pickDate(false),
                  icon: const Icon(Icons.event_busy, size: 16),
                  label: Text('Final: ${_dateLabel(_endsAt)}',
                      overflow: TextOverflow.ellipsis),
                ),
              ),
            ],
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
                  : const Text('Salveaza'),
            ),
          ),
        ],
      ),
    );
  }
}
