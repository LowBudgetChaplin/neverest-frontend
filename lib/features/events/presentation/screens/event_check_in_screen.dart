import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../dashboard/domain/dashboard_data.dart';
import '../../data/event_action_repository.dart';
import '../bloc/event_check_in_bloc.dart';

class EventCheckInScreen extends StatelessWidget {
  const EventCheckInScreen({
    super.key,
    required this.event,
  });

  final EventSummary event;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EventCheckInBloc(
        repository: context.read<EventActionRepository>(),
      ),
      child: _EventCheckInView(event: event),
    );
  }
}

class _EventCheckInView extends StatefulWidget {
  const _EventCheckInView({required this.event});

  final EventSummary event;

  @override
  State<_EventCheckInView> createState() => _EventCheckInViewState();
}

class _EventCheckInViewState extends State<_EventCheckInView> {
  final TextEditingController _manualQrController = TextEditingController();
  final MobileScannerController _scannerController = MobileScannerController();
  bool _detectionLocked = false;

  @override
  void dispose() {
    _manualQrController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Event check-in')),
      body: BlocConsumer<EventCheckInBloc, EventCheckInState>(
        listener: (context, state) {
          if (state.status == EventCheckInStatus.success) {
            _detectionLocked = true;
            _scannerController.stop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Check-in successful.')),
            );
            return;
          }

          if (state.status == EventCheckInStatus.failure) {
            _detectionLocked = false;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'Check-in failed.')),
            );
          }
        },
        builder: (context, state) {
          final isSubmitting = state.status == EventCheckInStatus.submitting;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.event.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      Text('Event ID: ${widget.event.id}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Card(
                child: ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('Scan participant QR'),
                  subtitle: Text(
                    'Point camera to QR code, or paste code manually as fallback.',
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 280,
                  child: MobileScanner(
                    controller: _scannerController,
                    onDetect: _onDetect,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _manualQrController,
                minLines: 1,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Manual QR input',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton(
                    onPressed: isSubmitting ? null : _submitManual,
                    child: const Text('Submit check-in'),
                  ),
                  OutlinedButton(
                    onPressed: isSubmitting ? null : _resetScanner,
                    child: const Text('Scan again'),
                  ),
                ],
              ),
              if (isSubmitting) ...[
                const SizedBox(height: 12),
                const LinearProgressIndicator(minHeight: 2),
              ],
              const SizedBox(height: 12),
              _ResultCard(state: state),
            ],
          );
        },
      ),
    );
  }

  void _onDetect(BarcodeCapture capture) {
    if (_detectionLocked) {
      return;
    }
    for (final barcode in capture.barcodes) {
      final code = barcode.rawValue;
      if (code != null && code.trim().isNotEmpty) {
        _submitQr(code.trim());
        return;
      }
    }
  }

  void _submitManual() {
    final qrCode = _manualQrController.text.trim();
    if (qrCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('QR code is required.')),
      );
      return;
    }
    _submitQr(qrCode);
  }

  void _submitQr(String qrCode) {
    _detectionLocked = true;
    context.read<EventCheckInBloc>().add(
          EventCheckInSubmitted(
            eventId: widget.event.id,
            userQrCode: qrCode,
          ),
        );
  }

  void _resetScanner() {
    _detectionLocked = false;
    _manualQrController.clear();
    context.read<EventCheckInBloc>().add(const EventCheckInResetRequested());
    _scannerController.start();
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.state});

  final EventCheckInState state;

  @override
  Widget build(BuildContext context) {
    if (state.status == EventCheckInStatus.success && state.result != null) {
      final result = state.result!;
      return Card(
        child: ListTile(
          leading: const Icon(Icons.verified),
          title: const Text('Last check-in'),
          subtitle: Text(
            'User: ${result.userId}\n'
            'Points awarded: ${result.pointsAwarded}\n'
            'Updated total points: ${result.updatedTotalPoints}',
          ),
          isThreeLine: true,
        ),
      );
    }

    if (state.status == EventCheckInStatus.failure) {
      return Card(
        child: ListTile(
          leading: const Icon(Icons.error_outline),
          title: const Text('Check-in error'),
          subtitle: Text(state.errorMessage ?? 'Unknown error'),
        ),
      );
    }

    return const Card(
      child: ListTile(
        leading: Icon(Icons.info_outline),
        title: Text('Ready for scan'),
        subtitle: Text('Scan a user QR code or paste it manually.'),
      ),
    );
  }
}
