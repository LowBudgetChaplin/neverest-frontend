import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../dashboard/domain/dashboard_data.dart';
import '../../../shell/presentation/design/neverest_design.dart';
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
  final List<_ScanEntry> _recentEntries = [];
  bool _detectionLocked = false;
  _ScanEntry? _lastSuccess;

  int? _capacity;
  int _checkedIn = 0;

  @override
  void initState() {
    super.initState();
    _capacity = widget.event.capacity;
  }

  @override
  void dispose() {
    _manualQrController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: NeverestPalette.ink,
      body: BlocConsumer<EventCheckInBloc, EventCheckInState>(
        listener: (context, state) {
          if (state.status == EventCheckInStatus.success && state.result != null) {
            final entry = _ScanEntry(
              userId: state.result!.userId,
              name: state.result!.userName,
              avatarB64: state.result!.userAvatarB64,
              points: state.result!.pointsAwarded,
              time: _timeNow(),
            );
            setState(() {
              _lastSuccess = entry;
              _recentEntries.insert(0, entry);
              if (_recentEntries.length > 6) {
                _recentEntries.removeLast();
              }
              _checkedIn = state.result!.checkInCount ?? (_checkedIn + 1);
              _capacity = state.result!.capacity ?? _capacity;
            });
            _detectionLocked = true;
            _scannerController.stop();
            return;
          }

          if (state.status == EventCheckInStatus.failure) {
            _detectionLocked = false;
            // Backend-ul semnaleaza capacitatea depasita printr-un marcaj stabil,
            final raw = state.errorMessage ?? '';
            final message = raw.contains('EVENT_CAPACITY_EXCEEDED')
                ? l10n.adminScanCapacityExceeded
                : raw.contains('EVENT_NOT_JOINED')
                    ? l10n.adminScanNotJoined
                    : (raw.isEmpty ? l10n.adminScanFailed : raw);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message)),
            );
          }
        },
        builder: (context, state) {
          final isSubmitting = state.status == EventCheckInStatus.submitting;
          return Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        MobileScanner(
                          controller: _scannerController,
                          onDetect: _onDetect,
                        ),
                        Container(
                          color: Colors.black.withOpacity(0.25),
                        ),
                        SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                            child: Row(
                              children: [
                                NeverestGlassIconButton(
                                  icon: Icons.close_rounded,
                                  foreground: Colors.white,
                                  background: Colors.black.withOpacity(0.55),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                                const Spacer(),
                                // Container(
                                //   padding: const EdgeInsets.symmetric(
                                //     horizontal: 12,
                                //     vertical: 8,
                                //   ),
                                //   decoration: BoxDecoration(
                                //     color: Colors.black.withOpacity(0.55),
                                //     borderRadius: BorderRadius.circular(99),
                                //   ),
                                //   child: Text(
                                //     l10n.adminScanHeader,
                                //     style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                //           color: NeverestPalette.orange,
                                //           letterSpacing: 1.2,
                                //         ),
                                //   ),
                                // ),
                                const Spacer(),
                                const SizedBox(width: 38),
                              ],
                            ),
                          ),
                        ),
                        Center(
                          child: SizedBox(
                            width: 220,
                            height: 220,
                            child: Stack(
                              children: [
                                ..._reticleCorners(),
                                Center(
                                  child: Container(
                                    width: 188,
                                    height: 2,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.transparent,
                                          NeverestPalette.orange.withOpacity(0.9),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 16,
                          right: 16,
                          bottom: 18,
                          child: Text(
                            l10n.adminScanHint,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withOpacity(0.86),
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(
                      20,
                      18,
                      20,
                      MediaQuery.paddingOf(context).bottom > 0
                          ? MediaQuery.paddingOf(context).bottom + 10
                          : 18,
                    ),
                    decoration: const BoxDecoration(
                      color: NeverestPalette.inkRaised,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              _capacity != null
                                  ? l10n.adminScanSpots(_checkedIn, _capacity!)
                                  : l10n.adminScanCheckedInCount(_checkedIn),
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: _capacity != null &&
                                            _checkedIn >= _capacity!
                                        ? NeverestPalette.orange
                                        : Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _manualQrController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: l10n.adminScanManualInput,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 48,
                                child: FilledButton(
                                  onPressed: isSubmitting ? null : _submitManual,
                                  child: Text(l10n.adminScanSubmit),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: SizedBox(
                                height: 48,
                                child: OutlinedButton(
                                  onPressed: isSubmitting ? null : _resetScanner,
                                  child: Text(l10n.adminScanReset),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (isSubmitting) ...[
                          const SizedBox(height: 10),
                          const LinearProgressIndicator(minHeight: 2),
                        ],
                        const SizedBox(height: 12),
                        ..._recentEntries.take(3).map(
                              (entry) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    NeverestAvatar(
                                      name: entry.label,
                                      imageB64: entry.avatarB64,
                                      size: 32,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            entry.label,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall
                                                ?.copyWith(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                          Text(
                                            '${entry.time} · +${entry.points} pts',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color: Colors.white.withOpacity(0.64),
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      Icons.check_rounded,
                                      color: NeverestPalette.success,
                                      size: 18,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                      ],
                    ),
                  ),
                ],
              ),
              if (_lastSuccess != null)
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () => setState(() => _lastSuccess = null),
                    child: Container(
                      color: Colors.black.withOpacity(0.7),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: NeverestPalette.ink,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: NeverestPalette.orange),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                NeverestAvatar(
                                  name: _lastSuccess!.label,
                                  imageB64: _lastSuccess!.avatarB64,
                                  size: 72,
                                ),
                                Container(
                                  width: 26,
                                  height: 26,
                                  decoration: BoxDecoration(
                                    color: NeverestPalette.success,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: NeverestPalette.ink, width: 2),
                                  ),
                                  child: const Icon(Icons.check_rounded,
                                      color: Colors.white, size: 16),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Text(
                              l10n.adminScanCheckedIn.toUpperCase(),
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: NeverestPalette.orange,
                                    letterSpacing: 1.4,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _lastSuccess!.label,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              l10n.adminScanPointsCredited(_lastSuccess!.points),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.white.withOpacity(0.72),
                                  ),
                            ),
                            const SizedBox(height: 14),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: () {
                                  setState(() => _lastSuccess = null);
                                  _resetScanner();
                                },
                                child: Text(l10n.adminScanNext),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
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
      _submitQr('NV-DEMO-7841');
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

  String _timeNow() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  List<Widget> _reticleCorners() {
    return [
      Align(
        alignment: Alignment.topLeft,
        child: _Corner(
          border: Border(
            top: const BorderSide(color: NeverestPalette.orange, width: 3),
            left: const BorderSide(color: NeverestPalette.orange, width: 3),
          ),
        ),
      ),
      Align(
        alignment: Alignment.topRight,
        child: _Corner(
          border: Border(
            top: const BorderSide(color: NeverestPalette.orange, width: 3),
            right: const BorderSide(color: NeverestPalette.orange, width: 3),
          ),
        ),
      ),
      Align(
        alignment: Alignment.bottomLeft,
        child: _Corner(
          border: Border(
            bottom: const BorderSide(color: NeverestPalette.orange, width: 3),
            left: const BorderSide(color: NeverestPalette.orange, width: 3),
          ),
        ),
      ),
      Align(
        alignment: Alignment.bottomRight,
        child: _Corner(
          border: Border(
            bottom: const BorderSide(color: NeverestPalette.orange, width: 3),
            right: const BorderSide(color: NeverestPalette.orange, width: 3),
          ),
        ),
      ),
    ];
  }
}

class _ScanEntry {
  const _ScanEntry({
    required this.userId,
    required this.points,
    required this.time,
    this.name,
    this.avatarB64,
  });

  final String userId;
  final String? name;
  final String? avatarB64;
  final int points;
  final String time;

  String get label => (name != null && name!.isNotEmpty) ? name! : userId;
}

class _Corner extends StatelessWidget {
  const _Corner({required this.border});

  final Border border;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      height: 28,
      child: DecoratedBox(
        decoration: BoxDecoration(border: border),
      ),
    );
  }
}
