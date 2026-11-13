import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_client.dart';
import '../../../core/state/business_state.dart';
import '../../../core/widgets/app_text_field.dart';

class CreateBusinessScreen extends ConsumerStatefulWidget {
  const CreateBusinessScreen({super.key});

  @override
  ConsumerState<CreateBusinessScreen> createState() => _CreateBusinessScreenState();
}

class _CreateBusinessScreenState extends ConsumerState<CreateBusinessScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _taxIdCtrl = TextEditingController();
  String _category = 'Supermarket';
  String _currency = 'NGN';
  String _country = 'NG';
  bool _loading = false;

  static const _categories = <String>[
    'Supermarket', 'Grocery', 'Pharmacy', 'Cosmetics', 'Electronics',
    'Fashion', 'Building Materials', 'General Merchandise', 'Other',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    _taxIdCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final api = ref.read(apiClientProvider);
      final response = await api.post<dynamic>(
        '/businesses',
        data: <String, dynamic>{
          'name': _nameCtrl.text.trim(),
          'category': _category,
          'phone': _phoneCtrl.text.trim(),
          if (_emailCtrl.text.trim().isNotEmpty) 'email': _emailCtrl.text.trim(),
          if (_addressCtrl.text.trim().isNotEmpty) 'address': _addressCtrl.text.trim(),
          'country': _country,
          'currency': _currency,
          if (_taxIdCtrl.text.trim().isNotEmpty) 'taxIdentifier': _taxIdCtrl.text.trim(),
        },
      );
      final data = api.unwrap<Map<String, dynamic>>(response, (d) => (d as Map<String, dynamic>));
      final bizId = data['activeBusinessId'] as String?;
      if (bizId != null) {
        await ref.read(businessProvider.notifier).setActiveBusiness(bizId);
      }
      await ref.read(businessProvider.notifier).fetchMemberships();
      if (!mounted) return;
      context.go('/home');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Set up your business')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text('Tell us about your store', style: theme.textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text(
                  'You can change these details later in Settings.',
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 24),
                AppTextField(
                  label: 'Business name *',
                  controller: _nameCtrl,
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a business name' : null,
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: _category,
                  decoration: const InputDecoration(labelText: 'Category *'),
                  items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) => setState(() => _category = v ?? _category),
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Business phone *',
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  validator: (v) => (v == null || v.trim().length < 6) ? 'Enter a phone number' : null,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Business email (optional)',
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Address (optional)',
                  controller: _addressCtrl,
                  maxLines: 2,
                ),
                const SizedBox(height: 14),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _country,
                        decoration: const InputDecoration(labelText: 'Country'),
                        items: const <DropdownMenuItem<String>>[
                          DropdownMenuItem(value: 'NG', child: Text('Nigeria')),
                          DropdownMenuItem(value: 'GH', child: Text('Ghana')),
                          DropdownMenuItem(value: 'KE', child: Text('Kenya')),
                        ],
                        onChanged: (v) => setState(() => _country = v ?? _country),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _currency,
                        decoration: const InputDecoration(labelText: 'Currency'),
                        items: const <DropdownMenuItem<String>>[
                          DropdownMenuItem(value: 'NGN', child: Text('NGN ₦')),
                          DropdownMenuItem(value: 'GHS', child: Text('GHS ₵')),
                          DropdownMenuItem(value: 'KES', child: Text('KES KSh')),
                          DropdownMenuItem(value: 'USD', child: Text('USD \$')),
                        ],
                        onChanged: (v) => setState(() => _currency = v ?? _currency),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Tax identifier (optional)',
                  controller: _taxIdCtrl,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Create business'),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
