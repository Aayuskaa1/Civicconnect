import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:civic_connect/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:civic_connect/features/complaint/domain/entities/complaint_entity.dart';
import 'package:civic_connect/features/complaint/presentation/view_model/complaint_view_model.dart';

class PostComplaintPage extends ConsumerStatefulWidget {
  const PostComplaintPage({super.key});

  @override
  ConsumerState<PostComplaintPage> createState() => _PostComplaintPageState();
}

class _PostComplaintPageState extends ConsumerState<PostComplaintPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedCategory;
  final _categories = ['Infrastructure', 'Waste Management', 'Water Supply', 'Roads', 'Other'];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final user = ref.read(authViewModelProvider).user;
    if (user == null) return;

    final entity = ComplaintEntity(
      complaintId: '',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _selectedCategory ?? 'Other',
      status: 'New',
      userEmail: user.email,
    );

    await ref.read(complaintViewModelProvider.notifier).createComplaint(entity);
  }

  @override
  Widget build(BuildContext context) {
    final complaintState = ref.watch(complaintViewModelProvider);

    ref.listen(complaintViewModelProvider, (previous, next) {
      if (previous?.isLoading == true && !next.isLoading && next.error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Complaint submitted successfully.')),
        );
        Navigator.pop(context);
      } else if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next.error!)));
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Post Complaint')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) => v!.isEmpty ? 'Enter a title' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 4,
                validator: (v) => v!.isEmpty ? 'Enter a description' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Category'),
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedCategory = v),
                validator: (v) => v == null ? 'Select a category' : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: complaintState.isLoading ? null : _submit,
                  child: complaintState.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Submit Complaint'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
