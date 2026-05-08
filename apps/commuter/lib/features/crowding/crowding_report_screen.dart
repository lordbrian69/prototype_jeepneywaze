import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/design_tokens.dart';
import '../../services/api_client.dart';

/// Crowding report — modal-style sheet with 3 large pill buttons.
/// Per JW Design spec section 6.9: fast 1-tap reports while standing
/// at the kanto. Each option auto-submits and dismisses.
class CrowdingReportScreen extends ConsumerStatefulWidget {
  final String beaconId;

  const CrowdingReportScreen({super.key, required this.beaconId});

  @override
  ConsumerState<CrowdingReportScreen> createState() =>
      _CrowdingReportScreenState();
}

class _CrowdingReportScreenState extends ConsumerState<CrowdingReportScreen> {
  bool _submitting = false;
  String? _selected;

  Future<void> _submit(String level) async {
    if (_submitting) return;
    setState(() {
      _submitting = true;
      _selected = level;
    });
    try {
      await ref.read(apiClientProvider).reportCrowding(
            beaconId: widget.beaconId,
            level: level,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: JWColors.black,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(JWSpacing.lg),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(JWRadius.card),
            ),
            content: Row(
              children: [
                const Icon(Icons.check_circle,
                    color: JWColors.jeepneyYellow, size: 18),
                const SizedBox(width: JWSpacing.sm),
                Expanded(
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(color: JWColors.white),
                      children: [
                        TextSpan(text: 'Na-report ang crowding. '),
                        TextSpan(
                          text: '+5',
                          style: TextStyle(
                            color: JWColors.jeepneyYellow,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextSpan(text: ' Guardian Points'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
        context.pop();
      }
    } catch (_) {
      if (mounted) {
        // Demo mode — backend not running. Still acknowledge to user.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: JWColors.black,
            content: Text(
              'Demo mode: report would be sent to backend.',
              style: TextStyle(color: JWColors.white),
            ),
          ),
        );
        context.pop();
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54,
      body: GestureDetector(
        onTap: () => context.pop(),
        child: Stack(
          children: [
            // Bottom sheet content
            Align(
              alignment: Alignment.bottomCenter,
              child: GestureDetector(
                onTap: () {}, // absorb taps inside sheet
                child: Container(
                  decoration: const BoxDecoration(
                    color: JWColors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(JWRadius.sheet),
                      topRight: Radius.circular(JWRadius.sheet),
                    ),
                  ),
                  padding: EdgeInsets.fromLTRB(
                    JWSpacing.xl,
                    JWSpacing.md,
                    JWSpacing.xl,
                    MediaQuery.of(context).padding.bottom + JWSpacing.xxl,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Drag handle
                      Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: JWColors.chipGray,
                          borderRadius:
                              BorderRadius.circular(JWRadius.pill),
                        ),
                      ),
                      const SizedBox(height: JWSpacing.xxl),
                      Text(
                        'Kamusta ang sasakyan?',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: JWSpacing.sm),
                      Text(
                        'Para sa ibang commuters na naghihintay.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: JWSpacing.xxl),

                      _crowdButton(
                        level: 'siksikan',
                        label: 'SIKSIKAN',
                        sub: 'Puno na!',
                        color: JWColors.siksikanRed,
                        icon: Icons.directions_bus,
                      ),
                      const SizedBox(height: JWSpacing.md),
                      _crowdButton(
                        level: 'ok',
                        label: 'KATAMTAMAN',
                        sub: 'Pwede pa.',
                        color: JWColors.warningOrange,
                        icon: Icons.directions_bus,
                      ),
                      const SizedBox(height: JWSpacing.md),
                      _crowdButton(
                        level: 'malwag',
                        label: 'MALWAG',
                        sub: 'May puwang pa!',
                        color: JWColors.malwagGreen,
                        icon: Icons.directions_bus,
                      ),

                      const SizedBox(height: JWSpacing.lg),
                      TextButton(
                        onPressed: () => context.pop(),
                        child: Text(
                          'Hindi na ako makapag-report',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: JWColors.mutedGray,
                                    decoration: TextDecoration.underline,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _crowdButton({
    required String level,
    required String label,
    required String sub,
    required Color color,
    required IconData icon,
  }) {
    final isLoading = _submitting && _selected == level;
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _submitting ? null : () => _submit(level),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: JWColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(JWRadius.pill),
          ),
          elevation: 0,
          disabledBackgroundColor: color.withOpacity(0.6),
          disabledForegroundColor: JWColors.white,
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: JWColors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 20, color: JWColors.white),
                  const SizedBox(width: JWSpacing.md),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: JWSpacing.sm),
                  Text(
                    sub,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: JWColors.white.withOpacity(0.85),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
