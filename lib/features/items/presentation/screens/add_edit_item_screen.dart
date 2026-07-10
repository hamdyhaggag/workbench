import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:workbench/core/constants/app_colors.dart';
import 'package:workbench/core/constants/app_text_styles.dart';
import 'package:workbench/core/utils/item_utils.dart';
import 'package:workbench/features/items/domain/entities/item_entity.dart';
import 'package:workbench/features/items/presentation/providers/item_providers.dart';
import 'package:workbench/features/projects/presentation/providers/project_providers.dart';

class AddEditItemScreen extends ConsumerStatefulWidget {
  final String? itemId;
  final ItemType? initialType;
  final String? initialProjectId;

  const AddEditItemScreen({
    super.key,
    this.itemId,
    this.initialType,
    this.initialProjectId,
  });

  @override
  ConsumerState<AddEditItemScreen> createState() => _AddEditItemScreenState();
}

class _AddEditItemScreenState extends ConsumerState<AddEditItemScreen> {
  final _formKey = GlobalKey<FormState>();

  ItemType _type = ItemType.note;
  String? _projectId;
  bool _isLoading = false;
  ItemEntity? _existingItem;

  // Common
  final _titleCtrl = TextEditingController();
  final _tagsCtrl = TextEditingController();

  // Note
  final _contentCtrl = TextEditingController();

  // Prompt
  final _promptCtrl = TextEditingController();

  // Link
  final _urlCtrl = TextEditingController();

  // Account
  final _websiteCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _showPassword = false;

  // Snippet
  final _codeCtrl = TextEditingController();
  String _codeLanguage = 'Dart';

  // API
  final _endpointCtrl = TextEditingController();
  String _method = 'GET';
  final _headersCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  final _apiNotesCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _type = widget.initialType ?? ItemType.note;
    _projectId = widget.initialProjectId;
    if (widget.itemId != null) _loadExisting();
  }

  Future<void> _loadExisting() async {
    setState(() => _isLoading = true);
    final repo = ref.read(itemRepositoryProvider);
    final item = await repo.getItem(widget.itemId!);
    if (item != null && mounted) {
      setState(() {
        _existingItem = item;
        _type = item.type;
        _projectId = item.projectId;
        _titleCtrl.text = item.title;
        _tagsCtrl.text = item.tags.join(', ');
        _contentCtrl.text = item.content ?? '';
        _promptCtrl.text = item.promptContent ?? '';
        _urlCtrl.text = item.url ?? '';
        _websiteCtrl.text = item.website ?? '';
        _emailCtrl.text = item.email ?? '';
        _usernameCtrl.text = item.username ?? '';
        _passwordCtrl.text = item.encryptedPassword ?? '';
        _codeCtrl.text = item.code ?? '';
        _codeLanguage = item.codeLanguage ?? 'Dart';
        _endpointCtrl.text = item.endpoint ?? '';
        _method = item.method ?? 'GET';
        _headersCtrl.text = item.headersJson ?? '';
        _bodyCtrl.text = item.bodyJson ?? '';
        _apiNotesCtrl.text = item.apiNotes ?? '';
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  List<String> _parseTags(String raw) {
    return raw.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_projectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اختار مشروع الأول')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final notifier = ref.read(itemNotifierProvider.notifier);
      final tags = _parseTags(_tagsCtrl.text);

      if (_existingItem != null) {
        final updated = _existingItem!.copyWith(
          title: _titleCtrl.text.trim(),
          tags: tags,
          content: _contentCtrl.text.isEmpty ? null : _contentCtrl.text,
          promptContent: _promptCtrl.text.isEmpty ? null : _promptCtrl.text,
          url: _urlCtrl.text.isEmpty ? null : _urlCtrl.text,
          website: _websiteCtrl.text.isEmpty ? null : _websiteCtrl.text,
          email: _emailCtrl.text.isEmpty ? null : _emailCtrl.text,
          username: _usernameCtrl.text.isEmpty ? null : _usernameCtrl.text,
          encryptedPassword: _passwordCtrl.text.isEmpty ? null : _passwordCtrl.text,
          code: _codeCtrl.text.isEmpty ? null : _codeCtrl.text,
          codeLanguage: _codeLanguage,
          endpoint: _endpointCtrl.text.isEmpty ? null : _endpointCtrl.text,
          method: _method,
          headersJson: _headersCtrl.text.isEmpty ? null : _headersCtrl.text,
          bodyJson: _bodyCtrl.text.isEmpty ? null : _bodyCtrl.text,
          apiNotes: _apiNotesCtrl.text.isEmpty ? null : _apiNotesCtrl.text,
        );
        await notifier.updateItem(updated);
        if (mounted) context.go('/items/${updated.id}');
      } else {
        final id = await notifier.createItem(
          projectId: _projectId!,
          title: _titleCtrl.text.trim(),
          type: _type,
          tags: tags,
          content: _contentCtrl.text.isEmpty ? null : _contentCtrl.text,
          promptContent: _promptCtrl.text.isEmpty ? null : _promptCtrl.text,
          url: _urlCtrl.text.isEmpty ? null : _urlCtrl.text,
          website: _websiteCtrl.text.isEmpty ? null : _websiteCtrl.text,
          email: _emailCtrl.text.isEmpty ? null : _emailCtrl.text,
          username: _usernameCtrl.text.isEmpty ? null : _usernameCtrl.text,
          encryptedPassword: _passwordCtrl.text.isEmpty ? null : _passwordCtrl.text,
          code: _codeCtrl.text.isEmpty ? null : _codeCtrl.text,
          codeLanguage: _codeLanguage,
          endpoint: _endpointCtrl.text.isEmpty ? null : _endpointCtrl.text,
          method: _method,
          headersJson: _headersCtrl.text.isEmpty ? null : _headersCtrl.text,
          bodyJson: _bodyCtrl.text.isEmpty ? null : _bodyCtrl.text,
          apiNotes: _apiNotesCtrl.text.isEmpty ? null : _apiNotesCtrl.text,
        );
        if (mounted) context.go('/items/$id');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(projectsStreamProvider);
    final isEdit = _existingItem != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isLoading && _existingItem == null && widget.itemId != null
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Form(
              key: _formKey,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                onPressed: () => context.pop(),
                                icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textSecondary),
                              ),
                              const Spacer(),
                              ElevatedButton(
                                onPressed: _isLoading ? null : _save,
                                child: _isLoading
                                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.background))
                                    : const Text('حفظ'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Text(isEdit ? 'تعديل' : 'إضافة عنصر', style: AppTextStyles.displayLarge),
                          const SizedBox(height: 24),

                          // Type selector (only for new items)
                          if (!isEdit) ...[
                            Text('النوع', style: AppTextStyles.labelLarge),
                            const SizedBox(height: 10),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: ItemType.values.map((t) {
                                  final selected = _type == t;
                                  final color = ItemUtils.getTypeColor(t);
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: GestureDetector(
                                      onTap: () => setState(() => _type = t),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 150),
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: selected ? color.withValues(alpha: 0.15) : AppColors.card,
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(color: selected ? color : AppColors.border),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(ItemUtils.getTypeIcon(t), size: 14, color: selected ? color : AppColors.textSecondary),
                                            const SizedBox(width: 6),
                                            Text(ItemUtils.getTypeLabel(t), style: AppTextStyles.labelSmall.copyWith(
                                              color: selected ? color : AppColors.textSecondary,
                                              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                                            )),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],

                          // Project selector
                          Text('المشروع', style: AppTextStyles.labelLarge),
                          const SizedBox(height: 8),
                          projectsAsync.when(
                            loading: () => const LinearProgressIndicator(color: AppColors.primary),
                            error: (_, __) => const SizedBox.shrink(),
                            data: (projects) => DropdownButtonFormField<String>(
                              initialValue: _projectId,
                              dropdownColor: AppColors.card,
                              style: AppTextStyles.bodyMedium,
                              decoration: const InputDecoration(hintText: 'اختار المشروع'),
                              items: projects.map((p) => DropdownMenuItem(
                                value: p.id,
                                child: Text('${p.emoji} ${p.name}'),
                              )).toList(),
                              onChanged: (v) => setState(() => _projectId = v),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Title
                          TextFormField(
                            controller: _titleCtrl,
                            decoration: const InputDecoration(labelText: 'العنوان *'),
                            style: AppTextStyles.bodyLarge,
                            validator: (v) => v?.isEmpty == true ? 'لازم تكتب عنوان' : null,
                          ),
                          const SizedBox(height: 16),

                          // Tags
                          TextFormField(
                            controller: _tagsCtrl,
                            decoration: const InputDecoration(
                              labelText: 'التاجات',
                              hintText: 'Flutter, Firebase, AI',
                            ),
                            style: AppTextStyles.bodyMedium,
                          ),
                          const SizedBox(height: 24),
                          const Divider(color: AppColors.border),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),

                  // Type-specific fields
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _buildTypeFields(),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ),
    );
  }

  Widget _buildTypeFields() {
    switch (_type) {
      case ItemType.note:
        return TextFormField(
          controller: _contentCtrl,
          maxLines: null,
          minLines: 8,
          decoration: const InputDecoration(
            labelText: 'المحتوى',
            alignLabelWithHint: true,
          ),
          style: AppTextStyles.bodyLarge,
        );
      case ItemType.prompt:
        return TextFormField(
          controller: _promptCtrl,
          maxLines: null,
          minLines: 10,
          decoration: const InputDecoration(
            labelText: 'البرومبت',
            alignLabelWithHint: true,
          ),
          style: AppTextStyles.bodyLarge.copyWith(height: 1.7),
        );
      case ItemType.link:
        return TextFormField(
          controller: _urlCtrl,
          decoration: const InputDecoration(labelText: 'الرابط'),
          keyboardType: TextInputType.url,
          style: AppTextStyles.bodyMedium,
        );
      case ItemType.account:
        return Column(
          children: [
            TextFormField(controller: _websiteCtrl, decoration: const InputDecoration(labelText: 'الموقع')),
            const SizedBox(height: 12),
            TextFormField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'الإيميل'), keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 12),
            TextFormField(controller: _usernameCtrl, decoration: const InputDecoration(labelText: 'اليوزرنيم')),
            const SizedBox(height: 12),
            TextFormField(
              controller: _passwordCtrl,
              obscureText: !_showPassword,
              decoration: InputDecoration(
                labelText: 'الباسورد',
                suffixIcon: IconButton(
                  icon: Icon(_showPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: AppColors.textSecondary),
                  onPressed: () => setState(() => _showPassword = !_showPassword),
                ),
              ),
            ),
          ],
        );
      case ItemType.snippet:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _codeLanguage,
              dropdownColor: AppColors.card,
              style: AppTextStyles.bodyMedium,
              decoration: const InputDecoration(labelText: 'اللغة'),
              items: ['Dart', 'Flutter', 'JavaScript', 'TypeScript', 'Python', 'SQL', 'HTML', 'CSS', 'JSON', 'Kotlin', 'Swift', 'Bash']
                  .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                  .toList(),
              onChanged: (v) => setState(() => _codeLanguage = v ?? 'Dart'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _codeCtrl,
              maxLines: null,
              minLines: 10,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 13, color: AppColors.text),
              decoration: const InputDecoration(
                labelText: 'الكود',
                alignLabelWithHint: true,
              ),
            ),
          ],
        );
      case ItemType.api:
        return Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: 110,
                  child: DropdownButtonFormField<String>(
                    initialValue: _method,
                    dropdownColor: AppColors.card,
                    style: AppTextStyles.bodyMedium,
                    decoration: const InputDecoration(labelText: 'الميثود'),
                    items: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE']
                        .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                        .toList(),
                    onChanged: (v) => setState(() => _method = v ?? 'GET'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _endpointCtrl,
                    decoration: const InputDecoration(labelText: 'الرابط (Endpoint)'),
                    style: AppTextStyles.mono,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _headersCtrl,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'الـ Headers (JSON)', alignLabelWithHint: true),
              style: AppTextStyles.mono.copyWith(fontSize: 12),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _bodyCtrl,
              maxLines: 6,
              decoration: const InputDecoration(labelText: 'الـ Body (JSON)', alignLabelWithHint: true),
              style: AppTextStyles.mono.copyWith(fontSize: 12),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _apiNotesCtrl,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'ملاحظات', alignLabelWithHint: true),
              style: AppTextStyles.bodyMedium,
            ),
          ],
        );
    }
  }
}
