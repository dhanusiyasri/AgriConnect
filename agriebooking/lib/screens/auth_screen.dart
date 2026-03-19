import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../widgets/language_toggle.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _aadhaarController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _aadhaarController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context, bool isRegistering) async {
    if (_formKey.currentState!.validate()) {
      final state = context.read<AppState>();
      
      try {
        final supabase = Supabase.instance.client;
        
        if (isRegistering) {
          try {
            // Pass ALL metadata here — our DB trigger (handle_new_user) will
            // automatically insert into public.users using SECURITY DEFINER,
            // which bypasses RLS and avoids the "violates row policy" error.
            final res = await supabase.auth.signUp(
              email: _emailController.text.trim(),
              password: _passwordController.text,
              data: {
                'name': _nameController.text.trim(),
                'phone': _phoneController.text.trim(),
                'aadhaar_number': _aadhaarController.text.trim(),
                'role': 'farmer',
              },
            );

            if (res.user != null) {
              // Set local app state — the DB row will be created by the trigger
              state.setUserProfile(UserProfile(
                id: res.user!.id,
                name: _nameController.text.trim(),
                phone: _phoneController.text.trim(),
                email: _emailController.text.trim(),
                aadhaar: _aadhaarController.text.trim(),
              ));
              state.setRole('farmer');
              state.setScreen('role-selection');
            } else {
              // Supabase requires email confirmation
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Registration successful! Please check your email to verify your account, then sign in.'),
                    duration: Duration(seconds: 5),
                  ),
                );
              }
            }
          } on AuthException catch (e) {
            if (e.message.contains('rate limit') || e.message.contains('429')) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('⚠️ Email rate limit exceeded. Please wait a while or disable "Confirm Email" in your Supabase Auth settings.'),
                  duration: Duration(seconds: 10),
                ),
              );
            } else if (e.message.contains('already registered') || e.message.contains('User already registered')) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Account already exists. Signing you in...')),
              );
              _performSignIn(supabase, state);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
            }
          }
        } else {
           _performSignIn(supabase, state);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields correctly')),
      );
    }
  }

  Future<void> _performSignIn(SupabaseClient supabase, AppState state) async {
    try {
      await supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final user = supabase.auth.currentUser;
      if (user != null) {
        final userData = await supabase.from('users').select().eq('id', user.id).maybeSingle();

        if (userData != null) {
          final String role = userData['role'] ?? 'farmer';
          state.setRole(role);
          state.setUserProfile(UserProfile(
            id: user.id,
            name: userData['name'] ?? 'User',
            phone: userData['phone'] ?? '',
            email: userData['email'] ?? _emailController.text.trim(),
            aadhaar: userData['aadhaar_number'],
          ));

          if (role == 'owner') {
            state.setScreen('owner-dashboard');
          } else {
            state.setScreen('dashboard');
          }
        } else {
          // User exists in Auth but not in public.users (trigger may not have fired)
          // Create the profile now
          await supabase.from('users').upsert({
            'id': user.id,
            'name': user.userMetadata?['name'] ?? 'User',
            'email': user.email ?? '',
            'phone': user.userMetadata?['phone'] ?? '',
            'aadhaar_number': user.userMetadata?['aadhaar_number'] ?? '',
            'role': 'farmer',
          });
          state.setRole('farmer');
          state.setScreen('role-selection');
        }
      }
    } on AuthException catch (e) {
      if (e.message.contains('Email not confirmed') || e.message.contains('email_not_confirmed')) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('📧 Please check your email inbox and click the confirmation link before signing in.'),
              duration: const Duration(seconds: 6),
              action: SnackBarAction(
                label: 'Resend',
                onPressed: () async {
                  await supabase.auth.resend(
                    type: OtpType.signup,
                    email: _emailController.text.trim(),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Confirmation email resent!')),
                  );
                },
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign-in error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isRegistering = state.isRegistering;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => context.read<AppState>().setScreen('language'),
                      icon: Icon(LucideIcons.arrowLeft, color: Theme.of(context).textTheme.bodyLarge?.color),
                      padding: EdgeInsets.zero,
                      alignment: Alignment.centerLeft,
                    ),
                    const LanguageToggle(),
                  ],
                ),
                const SizedBox(height: 32),
                
                Text(
                  isRegistering ? state.translate('createAccount') : state.translate('welcomeBack'),
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.titleLarge?.color),
                ),
                const SizedBox(height: 8),
                Text(
                  isRegistering ? state.translate('joinAgriConnect') : state.translate('signInSub'),
                  style: const TextStyle(fontSize: 16, color: AppTheme.slate500),
                ),
                const SizedBox(height: 32),

                if (isRegistering) ...[
                  _buildInput(
                    label: state.translate('fullName'), 
                    hint: state.translate('nameHint'),
                    controller: _nameController,
                    validator: (val) => val == null || val.isEmpty ? 'Name is required' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildInput(
                    label: state.translate('phoneNum'), 
                    hint: state.translate('phoneHint'),
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    validator: (val) => val == null || val.isEmpty ? 'Phone is required' : null,
                  ),
                  const SizedBox(height: 16),
                ],
                
                _buildInput(
                  label: state.translate('emailAddress'), 
                  hint: state.translate('emailHint'),
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Email is required';
                    if (!val.contains('@')) return 'Email must contain @';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(state.translate('passwordText'), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyLarge?.color)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      validator: (val) => val == null || val.isEmpty ? 'Password is required' : null,
                      decoration: InputDecoration(
                        hintText: state.translate('passwordHint'),
                        hintStyle: const TextStyle(color: AppTheme.slate400),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.slate200)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.slate200)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.green500)),
                        suffixIcon: const Icon(LucideIcons.lock, color: AppTheme.slate400, size: 20),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                if (isRegistering) ...[
                  _buildInput(
                    label: state.translate('aadhaarNum'), 
                    hint: state.translate('aadhaarHint'),
                    controller: _aadhaarController,
                    keyboardType: TextInputType.number,
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Aadhaar is required';
                      if (val.length != 12) return 'Aadhaar must be exactly 12 digits';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],
                
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _submit(context, isRegistering),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.green700,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(isRegistering ? state.translate('registerNow') : state.translate('signIn'), style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),

                const SizedBox(height: 24),
                Center(
                  child: TextButton(
                    onPressed: () {
                      _formKey.currentState?.reset();
                      context.read<AppState>().setIsRegistering(!isRegistering);
                    },
                    child: RichText(
                      text: TextSpan(
                        text: isRegistering ? state.translate('alreadyHaveAccount') : state.translate('dontHaveAccount'),
                        style: const TextStyle(color: AppTheme.slate600, fontSize: 14, fontWeight: FontWeight.w500, fontFamily: 'NotoSans'),
                        children: [
                          TextSpan(
                            text: isRegistering ? state.translate('signIn') : state.translate('createNewAccount'),
                            style: const TextStyle(color: AppTheme.green700, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput({
    required String label, 
    required String hint,
    required TextEditingController controller,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyLarge?.color)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppTheme.slate400),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.slate200)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.slate200)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.green500)),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }
}
