import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../shell/presentation/design/neverest_design.dart';
import '../../data/partner_repository.dart';

class PartnerScanScreen extends StatefulWidget {
  const PartnerScanScreen({super.key});

  @override
  State<PartnerScanScreen> createState() => _PartnerScanScreenState();
}

class _PartnerScanScreenState extends State<PartnerScanScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  final TextEditingController _manualController = TextEditingController();
  bool _busy = false;
  bool _locked = false;
  RedemptionValidation? _result;

  @override
  void dispose() {
    _scannerController.dispose();
    _manualController.dispose();
    super.dispose();
  }

  Future<void> _validate(String code) async {
    if (_busy || code.trim().isEmpty) return;
    setState(() {
      _busy = true;
      _locked = true;
    });
    await _scannerController.stop();
    try {
      final result = await context.read<PartnerRepository>().validateCode(code);
      if (!mounted) return;
      setState(() => _result = result);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
      _resetScanner();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _onDetect(BarcodeCapture capture) {
    if (_locked) return;
    for (final barcode in capture.barcodes) {
      final code = barcode.rawValue;
      if (code != null && code.trim().isNotEmpty) {
        _validate(code.trim());
        return;
      }
    }
  }

  void _resetScanner() {
    _manualController.clear();
    setState(() {
      _result = null;
      _locked = false;
    });
    _scannerController.start();
  }

  ({Color color, IconData icon, String title}) _resultVisual(RedemptionValidation r) {
    if (r.valid) {
      return (
        color: NeverestPalette.success,
        icon: Icons.verified_rounded,
        title: 'Cod valid',
      );
    }
    switch (r.status) {
      case 'ALREADY_USED':
        return (
          color: NeverestPalette.danger,
          icon: Icons.block_rounded,
          title: 'Cod expirat (deja folosit)',
        );
      case 'FORBIDDEN':
        return (
          color: NeverestPalette.danger,
          icon: Icons.lock_outline_rounded,
          title: 'Codul nu apartine beneficiilor tale',
        );
      case 'NOT_FOUND':
      default:
        return (
          color: NeverestPalette.danger,
          icon: Icons.error_outline_rounded,
          title: 'Cod inexistent',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeverestPalette.ink,
      body: Stack(
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
                    Container(color: Colors.black.withOpacity(0.25)),
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
                          ],
                        ),
                      ),
                    ),
                    const Center(
                      child: SizedBox(
                        width: 220,
                        height: 220,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            border: Border.fromBorderSide(
                              BorderSide(color: NeverestPalette.orange, width: 3),
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                          ),
                        ),
                      ),
                    ),
                    const Positioned(
                      left: 16,
                      right: 16,
                      bottom: 18,
                      child: Text(
                        'Scaneaza codul QR al beneficiului prezentat de client',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(
                  20,
                  16,
                  20,
                  MediaQuery.paddingOf(context).bottom > 0
                      ? MediaQuery.paddingOf(context).bottom + 10
                      : 16,
                ),
                decoration: const BoxDecoration(
                  color: NeverestPalette.inkRaised,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _manualController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Introdu codul manual',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton(
                            onPressed: _busy
                                ? null
                                : () => _validate(_manualController.text),
                            child: const Text('Valideaza'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: _busy ? null : _resetScanner,
                          child: const Text('Reset'),
                        ),
                      ],
                    ),
                    if (_busy) ...[
                      const SizedBox(height: 10),
                      const LinearProgressIndicator(minHeight: 2),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (_result != null) _buildResultOverlay(_result!),
        ],
      ),
    );
  }

  Widget _buildResultOverlay(RedemptionValidation r) {
    final visual = _resultVisual(r);
    return Positioned.fill(
      child: GestureDetector(
        onTap: _resetScanner,
        child: Container(
          color: Colors.black.withOpacity(0.75),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: NeverestPalette.ink,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: visual.color),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(visual.icon, color: visual.color, size: 56),
                const SizedBox(height: 12),
                Text(
                  visual.title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                if (r.rewardTitle != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    r.rewardTitle!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.white.withOpacity(0.8)),
                  ),
                ],
                if (r.valid && r.userName != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Client: ${r.userName}',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.white.withOpacity(0.7)),
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _resetScanner,
                    child: const Text('Scaneaza altul'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
