// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../seller/data/seller_repository.dart';
import '../../../../l10n/app_localizations.dart';

class ReportModal extends ConsumerStatefulWidget {
  final String listingId;
  const ReportModal({super.key, required this.listingId});

  @override
  ConsumerState<ReportModal> createState() => _ReportModalState();
}

class _ReportModalState extends ConsumerState<ReportModal> {
  String? _selectedReason;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.8,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
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
                l10n.reportListing,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    RadioListTile<String>(
                      title: Text(l10n.reportFake),
                      value: 'fake',
                      groupValue: _selectedReason,
                      onChanged: (value) => setState(() => _selectedReason = value),
                    ),
                    RadioListTile<String>(
                      title: Text(l10n.reportInappropriate),
                      value: 'inappropriate',
                      groupValue: _selectedReason,
                      onChanged: (value) => setState(() => _selectedReason = value),
                    ),
                    RadioListTile<String>(
                      title: Text(l10n.reportDuplicate),
                      value: 'duplicate',
                      groupValue: _selectedReason,
                      onChanged: (value) => setState(() => _selectedReason = value),
                    ),
                    RadioListTile<String>(
                      title: Text(l10n.reportScam),
                      value: 'scam',
                      groupValue: _selectedReason,
                      onChanged: (value) => setState(() => _selectedReason = value),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _selectedReason == null
                      ? null
                      : () async {
                          try {
                            final repo = ref.read(sellerRepositoryProvider);
                            await repo.submitReport(widget.listingId, _selectedReason!);
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(l10n.reportSubmitted)),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(l10n.error), backgroundColor: Colors.red),
                              );
                            }
                          }
                        },
                  child: Text(l10n.reportListing),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
