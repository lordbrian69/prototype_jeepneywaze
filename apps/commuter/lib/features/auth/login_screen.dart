import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/design_tokens.dart';
import '../../services/api_client.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneCtrl = TextEditingController();
  final List<TextEditingController> _otpCtrls =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpNodes = List.generate(6, (_) => FocusNode());

  bool _otpSent = false;
  bool _loading = false;
  String? _error;

  String get _otpCode => _otpCtrls.map((c) => c.text).join();

  Future<void> _sendOtp() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await Supabase.instance.client.auth
          .signInWithOtp(phone: '+63${_phoneCtrl.text.trim()}');
      if (mounted) {
        setState(() => _otpSent = true);
        Future.delayed(const Duration(milliseconds: 100),
            () => _otpNodes.first.requestFocus());
      }
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) {
        setState(() => _error =
            'Hindi pa nakaka-konekta sa server. Subukan ang Demo mode sa baba.');
      }
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
        phone: '+63${_phoneCtrl.text.trim()}',
        token: _otpCode,
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
      backgroundColor: JWColors.white,
      appBar: AppBar(
        backgroundColor: JWColors.white,
        title: Text(_otpSent ? 'Kumpirmahin' : 'Mag-sign in'),
        leading: _otpSent
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() {
                  _otpSent = false;
                  for (final c in _otpCtrls) {
                    c.clear();
                  }
                }),
              )
            : null,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: JWSpacing.xl),
          child: _otpSent ? _buildOtpStep(context) : _buildPhoneStep(context),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────
  // PHONE STEP
  // ──────────────────────────────────────────────────────
  Widget _buildPhoneStep(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 40),
        Text(
          'Ano ang iyong numero?',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: JWSpacing.sm),
        Text(
          'Padadalhan ka namin ng verification code.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: JWSpacing.xxxl),
        _buildPhoneInput(),
        if (_error != null) ...[
          const SizedBox(height: JWSpacing.md),
          Text(
            _error!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: JWColors.siksikanRed,
                ),
          ),
        ],
        const SizedBox(height: JWSpacing.lg),
        FilledButton(
          onPressed: _loading || _phoneCtrl.text.length < 10 ? null : _sendOtp,
          child: _loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: JWColors.white,
                  ),
                )
              : const Text('Humingi ng Code'),
        ),
        const SizedBox(height: JWSpacing.xxl),
        Row(
          children: [
            const Expanded(
              child: Divider(color: JWColors.chipGray, thickness: 1),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: JWSpacing.md),
              child: Text(
                'o',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const Expanded(
              child: Divider(color: JWColors.chipGray, thickness: 1),
            ),
          ],
        ),
        const SizedBox(height: JWSpacing.xxl),
        OutlinedButton(
          onPressed: () => context.go('/'),
          child: const Text('Continue as Guest (Demo)'),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.only(bottom: JWSpacing.xl),
          child: Text(
            'Sa pag-sign in, sumasang-ayon ka sa aming Terms at Privacy Policy.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: JWColors.mutedGray,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneInput() {
    return Container(
      decoration: BoxDecoration(
        color: JWColors.white,
        border: Border.all(color: JWColors.black, width: 1),
        borderRadius: BorderRadius.circular(JWRadius.card),
      ),
      padding: const EdgeInsets.symmetric(horizontal: JWSpacing.lg),
      child: Row(
        children: [
          const Text('🇵🇭', style: TextStyle(fontSize: 20)),
          const SizedBox(width: JWSpacing.sm),
          Text(
            '+63',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          Container(
            width: 1,
            height: 24,
            color: JWColors.chipGray,
            margin: const EdgeInsets.symmetric(horizontal: JWSpacing.md),
          ),
          Expanded(
            child: TextField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: '9XX XXX XXXX',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: JWSpacing.lg),
              ),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────
  // OTP STEP
  // ──────────────────────────────────────────────────────
  Widget _buildOtpStep(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 40),
        Text(
          'I-enter ang code',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: JWSpacing.sm),
        RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.bodyMedium,
            children: [
              const TextSpan(text: 'Ipinadala sa +63 '),
              TextSpan(
                text: _phoneCtrl.text,
                style: const TextStyle(
                  color: JWColors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const TextSpan(text: '   '),
              TextSpan(
                text: 'Baguhin',
                style: const TextStyle(
                  color: JWColors.black,
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.underline,
                ),
                recognizer: null,
              ),
            ],
          ),
        ),
        const SizedBox(height: JWSpacing.xxxl),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (i) => _otpBox(i)),
        ),
        if (_error != null) ...[
          const SizedBox(height: JWSpacing.md),
          Text(
            _error!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: JWColors.siksikanRed,
                ),
          ),
        ],
        const SizedBox(height: JWSpacing.xl),
        FilledButton(
          onPressed:
              _loading || _otpCode.length < 6 ? null : _verifyOtp,
          child: _loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: JWColors.white,
                  ),
                )
              : const Text('Verify'),
        ),
        const SizedBox(height: JWSpacing.lg),
        TextButton(
          onPressed: _loading ? null : _sendOtp,
          child: Text(
            'Muling humingi ng code',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: JWColors.mutedGray,
                  decoration: TextDecoration.underline,
                ),
          ),
        ),
      ],
    );
  }

  Widget _otpBox(int i) {
    final filled = _otpCtrls[i].text.isNotEmpty;
    return SizedBox(
      width: 48,
      height: 56,
      child: TextField(
        controller: _otpCtrls[i],
        focusNode: _otpNodes[i],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: filled ? JWColors.white : JWColors.black,
              fontWeight: FontWeight.w700,
              fontSize: 24,
            ),
        decoration: InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.zero,
          filled: true,
          fillColor: filled ? JWColors.black : JWColors.chipGray,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(JWRadius.small),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(JWRadius.small),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(JWRadius.small),
            borderSide:
                const BorderSide(color: JWColors.black, width: 2),
          ),
        ),
        onChanged: (v) {
          setState(() {});
          if (v.isNotEmpty && i < 5) {
            _otpNodes[i + 1].requestFocus();
          } else if (v.isEmpty && i > 0) {
            _otpNodes[i - 1].requestFocus();
          }
          if (_otpCode.length == 6 && !_loading) {
            _verifyOtp();
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    for (final c in _otpCtrls) {
      c.dispose();
    }
    for (final n in _otpNodes) {
      n.dispose();
    }
    super.dispose();
  }
}
