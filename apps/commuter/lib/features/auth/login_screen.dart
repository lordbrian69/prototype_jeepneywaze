import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/api_client.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneCtrl = TextEditingController(text: '+63');
  final _otpCtrl = TextEditingController();
  bool _otpSent = false;
  bool _loading = false;
  String? _error;

  Future<void> _sendOtp() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await Supabase.instance.client.auth.signInWithOtp(phone: _phoneCtrl.text.trim());
      if (mounted) setState(() => _otpSent = true);
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _verifyOtp() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await Supabase.instance.client.auth.verifyOTP(
        phone: _phoneCtrl.text.trim(),
        token: _otpCtrl.text.trim(),
        type: OtpType.sms,
      );
      final session = res.session;
      if (session == null) {
        throw Exception('No session returned from Supabase');
      }

      await ref.read(apiClientProvider).verifyOtp(
            supabaseAccessToken: session.accessToken,
            supabaseUserId: session.user.id,
          );

      if (mounted) context.go('/');
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              const Icon(Icons.directions_bus,
                  size: 64, color: Color(0xFFE8401C)),
              const SizedBox(height: 16),
              Text('JeepneyWaze',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      )),
              const SizedBox(height: 8),
              const Text(
                'Real-time jeepney tracking — para sa commuter',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              TextField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                enabled: !_otpSent,
                decoration: const InputDecoration(
                  labelText: 'Phone number',
                  hintText: '+63 9XX XXX XXXX',
                  border: OutlineInputBorder(),
                ),
              ),
              if (_otpSent) ...[
                const SizedBox(height: 16),
                TextField(
                  controller: _otpCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'OTP code',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _loading
                    ? null
                    : (_otpSent ? _verifyOtp : _sendOtp),
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_otpSent ? 'Verify OTP' : 'Send OTP'),
              ),
              if (_otpSent)
                TextButton(
                  onPressed: _loading
                      ? null
                      : () => setState(() {
                            _otpSent = false;
                            _otpCtrl.clear();
                          }),
                  child: const Text('Change phone number'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _otpCtrl.dispose();
    super.dispose();
  }
}
