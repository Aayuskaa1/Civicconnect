import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:civic_connect/app/theme/my_theme.dart';
import 'package:civic_connect/app/theme/app_typography.dart';
import 'package:civic_connect/app/theme/app_spacing.dart';
import 'package:civic_connect/features/chat/domain/entities/chat_message.dart';
import 'package:civic_connect/features/chat/presentation/view_model/chat_view_model.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();

  static const _suggestions = [
    'What is CivicConnect?',
    'How do I use this app?',
    'Explain all tabs',
    'How do I report an issue?',
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 100,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _send([String? preset]) async {
    final text = preset ?? _controller.text;
    _controller.clear();
    await ref.read(chatViewModelProvider.notifier).send(text);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatViewModelProvider);
    ref.listen(chatViewModelProvider, (previous, next) {
      if (previous?.messages.length != next.messages.length ||
          previous?.isSending != next.isSending) {
        _scrollToBottom();
      }
    });

    final showSuggestions = chatState.messages.length <= 2;

    return Scaffold(
      backgroundColor: MyTheme.background,
      appBar: AppBar(
        backgroundColor: MyTheme.surface,
        elevation: 0,
        titleSpacing: AppSpacing.md,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: MyTheme.primaryLight,
                borderRadius: BorderRadius.circular(MyTheme.radiusSm),
                border: Border.all(color: MyTheme.border),
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: MyTheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ask AI',
                    style: AppTypography.titleSm(MyTheme.textPrimary),
                  ),
                  Text(
                    'CivicConnect assistant',
                    style: AppTypography.caption(MyTheme.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Clear chat',
            onPressed: () =>
                ref.read(chatViewModelProvider.notifier).clearChat(),
            icon: const Icon(Icons.refresh_rounded, color: MyTheme.primary),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: MyTheme.border),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              itemCount:
                  chatState.messages.length + (chatState.isSending ? 1 : 0),
              itemBuilder: (context, index) {
                if (chatState.isSending &&
                    index == chatState.messages.length) {
                  return const _TypingBubble();
                }
                return _MessageBubble(message: chatState.messages[index]);
              },
            ),
          ),
          if (showSuggestions)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.xs,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Suggested questions',
                    style: AppTypography.overline(MyTheme.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: _suggestions.map((suggestion) {
                      return ActionChip(
                        label: Text(
                          suggestion,
                          style: AppTypography.caption(MyTheme.primary),
                        ),
                        backgroundColor: MyTheme.surface,
                        side: const BorderSide(color: MyTheme.border),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(MyTheme.radiusSm),
                        ),
                        onPressed: chatState.isSending
                            ? null
                            : () => _send(suggestion),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: MyTheme.surface,
              border: const Border(top: BorderSide(color: MyTheme.border)),
              boxShadow: [
                BoxShadow(
                  color: MyTheme.shadow.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      minLines: 1,
                      maxLines: 4,
                      enabled: !chatState.isSending,
                      style: AppTypography.body(MyTheme.textPrimary),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) {
                        if (!chatState.isSending) _send();
                      },
                      decoration: InputDecoration(
                        hintText: 'Ask a question about the app…',
                        hintStyle:
                            AppTypography.body(MyTheme.textSecondary),
                        filled: true,
                        fillColor: MyTheme.lightBg,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(MyTheme.radiusMd),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(MyTheme.radiusMd),
                          borderSide:
                              const BorderSide(color: MyTheme.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(MyTheme.radiusMd),
                          borderSide: const BorderSide(
                            color: MyTheme.primary,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Material(
                    color: chatState.isSending
                        ? MyTheme.disabled
                        : MyTheme.primary,
                    borderRadius: BorderRadius.circular(MyTheme.radiusMd),
                    child: InkWell(
                      onTap: chatState.isSending ? null : () => _send(),
                      borderRadius:
                          BorderRadius.circular(MyTheme.radiusMd),
                      child: const SizedBox(
                        width: 48,
                        height: 48,
                        child: Icon(
                          Icons.send_rounded,
                          color: MyTheme.textOnPrimary,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    if (isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.78,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: MyTheme.primary,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(MyTheme.radiusLg),
              topRight: Radius.circular(MyTheme.radiusLg),
              bottomLeft: Radius.circular(MyTheme.radiusLg),
              bottomRight: Radius.circular(4),
            ),
            boxShadow: [
              BoxShadow(
                color: MyTheme.primary.withValues(alpha: 0.22),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: SelectableText(
            message.content,
            style: AppTypography.body(MyTheme.textOnPrimary),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: MyTheme.primaryLight,
              borderRadius: BorderRadius.circular(MyTheme.radiusSm),
              border: Border.all(color: MyTheme.border),
            ),
            child: const Icon(
              Icons.auto_awesome,
              size: 16,
              color: MyTheme.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.78,
              ),
              padding: AppSpacing.cardPadding,
              decoration: AppDecorations.card(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Assistant',
                    style: AppTypography.overline(MyTheme.primary),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  SelectableText(
                    message.content,
                    style: AppTypography.body(MyTheme.textPrimary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: MyTheme.primaryLight,
              borderRadius: BorderRadius.circular(MyTheme.radiusSm),
              border: Border.all(color: MyTheme.border),
            ),
            child: const Icon(
              Icons.auto_awesome,
              size: 16,
              color: MyTheme.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: AppDecorations.card(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: MyTheme.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Preparing a full answer…',
                  style: AppTypography.bodySm(MyTheme.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
