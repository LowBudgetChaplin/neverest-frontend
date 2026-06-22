import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../dashboard/domain/dashboard_data.dart';
import '../../../dashboard/presentation/bloc/dashboard_bloc.dart';
import '../../data/event_action_repository.dart';

class EventEditScreen extends StatefulWidget {
  const EventEditScreen({super.key, required this.event});

  final EventSummary event;

  @override
  State<EventEditScreen> createState() => _EventEditScreenState();
}

class _EventEditScreenState extends State<EventEditScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _locationController;
  late final TextEditingController _pointsController;
  late final TextEditingController _capacityController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _routeMapController;
  late final TextEditingController _stravaClubController;
  late final TextEditingController _whatsappController;

  late String _activity;
  late String _recurrence;
  DateTime? _startsAt;
  bool _saving = false;

  static const _activities = ['RUNNING', 'MOUNTAIN', 'PADEL'];
  static const _recurrences = [
    'NONE',
    'WEEKLY',
    'BIWEEKLY',
    'MONTHLY',
    'QUARTERLY',
    'YEARLY',
  ];

  @override
  void initState() {
    super.initState();
    final e = widget.event;
    _titleController = TextEditingController(text: e.title);
    _locationController = TextEditingController(text: e.location);
    _pointsController = TextEditingController(text: e.pointsReward.toString());
    _capacityController = TextEditingController(text: e.capacity?.toString() ?? '');
    _descriptionController = TextEditingController(text: e.description ?? '');
    _routeMapController = TextEditingController(text: e.routeMapUrl ?? '');
    _stravaClubController = TextEditingController(text: e.stravaClubUrl ?? '');
    _whatsappController = TextEditingController(text: e.whatsappGroupUrl ?? '');
    _activity = _activities.contains(e.activityType.toUpperCase())
        ? e.activityType.toUpperCase()
        : 'RUNNING';
    _recurrence = _recurrences.contains((e.recurrence ?? 'NONE').toUpperCase())
        ? (e.recurrence ?? 'NONE').toUpperCase()
        : 'NONE';
    _startsAt = DateTime.tryParse(e.startsAt);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _pointsController.dispose();
    _capacityController.dispose();
    _descriptionController.dispose();
    _routeMapController.dispose();
    _stravaClubController.dispose();
    _whatsappController.dispose();
    super.dispose();
  }

  String _dateLabel(DateTime? d) {
    if (d == null) return '—';
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _pickStartsAt() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _startsAt ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 2)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startsAt ?? now),
    );
    if (!mounted) return;
    setState(() {
      _startsAt = DateTime(
        date.year,
        date.month,
        date.day,
        time?.hour ?? (_startsAt?.hour ?? 7),
        time?.minute ?? (_startsAt?.minute ?? 0),
      );
    });
  }

  Future<void> _save() async {
    final points = int.tryParse(_pointsController.text.trim());
    if (_titleController.text.trim().isEmpty ||
        _locationController.text.trim().isEmpty ||
        points == null ||
        points <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Titlu, locatie si puncte (>0) sunt obligatorii.')),
      );
      return;
    }
    final capacityText = _capacityController.text.trim();
    final capacity = capacityText.isEmpty ? null : int.tryParse(capacityText);

    setState(() => _saving = true);
    try {
      await context.read<EventActionRepository>().updateEvent(
            eventId: widget.event.id,
            title: _titleController.text,
            activityType: _activity,
            location: _locationController.text,
            startsAtIso: _startsAt?.toIso8601String().split('.').first,
            pointsReward: points,
            capacity: capacity,
            clearCapacity: capacityText.isEmpty,
            description: _descriptionController.text,
            recurrence: _recurrence,
            routeMapUrl: _routeMapController.text,
            stravaClubUrl: _stravaClubController.text,
            whatsappGroupUrl: _whatsappController.text,
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
      appBar: AppBar(title: const Text('Editeaza eveniment')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _titleController,
            enabled: !_saving,
            decoration: const InputDecoration(labelText: 'Titlu'),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _activity,
            items: _activities
                .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                .toList(),
            onChanged: _saving ? null : (v) => setState(() => _activity = v ?? _activity),
            decoration: const InputDecoration(labelText: 'Tip activitate'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _locationController,
            enabled: !_saving,
            decoration: const InputDecoration(labelText: 'Locatie'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _saving ? null : _pickStartsAt,
            icon: const Icon(Icons.event_outlined),
            label: Text('Incepe: ${_dateLabel(_startsAt)}'),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _pointsController,
                  enabled: !_saving,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Puncte'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _capacityController,
                  enabled: !_saving,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Capacitate (optional)'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _recurrence,
            items: _recurrences
                .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                .toList(),
            onChanged:
                _saving ? null : (v) => setState(() => _recurrence = v ?? _recurrence),
            decoration: const InputDecoration(labelText: 'Recurenta'),
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
          TextField(
            controller: _routeMapController,
            enabled: !_saving,
            decoration: const InputDecoration(labelText: 'Link traseu (optional)'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _stravaClubController,
            enabled: !_saving,
            decoration: const InputDecoration(labelText: 'Link Strava Club (optional)'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _whatsappController,
            enabled: !_saving,
            decoration: const InputDecoration(labelText: 'Link grup WhatsApp (optional)'),
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
