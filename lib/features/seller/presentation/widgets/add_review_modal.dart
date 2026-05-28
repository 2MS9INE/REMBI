import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/seller_repository.dart';
import '../providers/seller_provider.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddReviewModal extends ConsumerStatefulWidget {
  final String sellerId;

  const AddReviewModal({super.key, required this.sellerId});

  @override
  ConsumerState<AddReviewModal> createState() => _AddReviewModalState();
}

class _AddReviewModalState extends ConsumerState<AddReviewModal> {
  final _formKey = GlobalKey<FormState>();
  String _comment = '';
  double _rating = 5.0;
  String _reviewerName = '';

  @override
  void initState() {
    super.initState();
    // Auto-fill from logged-in user
    final user = Supabase.instance.client.auth.currentUser;
    // We need to fetch from public.users for full_name
    _loadReviewerName();
  }

  Future<void> _loadReviewerName() async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return;
    final data = await Supabase.instance.client
        .from('users')
        .select('full_name')
        .eq('id', uid)
        .single();
    setState(() {
      _reviewerName = data['full_name'] as String? ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                l10n.addReview,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Rating',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < _rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 36,
                    ),
                    onPressed: () {
                      setState(() {
                        _rating = index + 1.0;
                      });
                    },
                  );
                }),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: l10n.yourName,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? l10n.error : null,
                onSaved: (value) => _reviewerName = value!.trim(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: l10n.reviews,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 3,
                onSaved: (value) => _comment = value?.trim() ?? '',
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        final repo = ref.read(sellerRepositoryProvider);
                        await repo.submitReview(
                          sellerId: widget.sellerId,
                          reviewerName: _reviewerName,
                          rating: _rating,
                          comment: _comment.isEmpty ? null : _comment,
                        );
                        ref.invalidate(sellerReviewsProvider(widget.sellerId));
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Review added successfully'),
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.error),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    }
                  },
                  child: Text(l10n.save),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
