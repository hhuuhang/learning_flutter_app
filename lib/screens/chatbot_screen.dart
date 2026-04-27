import 'package:flutter/material.dart';

import '../models/chat_message.dart';
import '../services/gemini_chat_service.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  static const _initialApiKey = String.fromEnvironment('GEMINI_API_KEY');

  final _chatService = GeminiChatService();
  final _apiKeyController = TextEditingController(text: _initialApiKey);
  final _modelController = TextEditingController(
    text: GeminiChatService.defaultModel,
  );
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  late List<ChatMessage> _messages;
  bool _isSending = false;
  bool _showSettings = _initialApiKey.isEmpty;

  @override
  void initState() {
    super.initState();
    _messages = [
      ChatMessage(
        id: 'welcome',
        role: ChatRole.assistant,
        text: 'Chào bạn, mình đã sẵn sàng. Hãy thêm Gemini API key rồi gửi '
            'câu hỏi đầu tiên.',
        createdAt: DateTime.now(),
      ),
    ];
  }

  @override
  void dispose() {
    _chatService.dispose();
    _apiKeyController.dispose();
    _modelController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    final userMessage = _createMessage(ChatRole.user, text);
    final pendingMessage = _createMessage(
      ChatRole.assistant,
      'Đang suy nghĩ...',
      isPending: true,
    );

    setState(() {
      _messageController.clear();
      _messages = [..._messages, userMessage, pendingMessage];
      _isSending = true;
    });
    _scrollToBottom();

    try {
      final answer = await _chatService.sendMessage(
        apiKey: _apiKeyController.text,
        model: _modelController.text,
        conversation: _messages.where((message) => !message.isPending).toList(),
      );
      if (!mounted) return;
      _replacePending(answer);
    } on Object catch (error) {
      if (!mounted) return;
      _replacePending(error.toString());
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
        _scrollToBottom();
      }
    }
  }

  void _replacePending(String text) {
    setState(() {
      _messages = [
        for (final message in _messages)
          if (message.isPending)
            message.copyWith(
              text: text,
              isPending: false,
              createdAt: DateTime.now(),
            )
          else
            message,
      ];
    });
  }

  ChatMessage _createMessage(
    ChatRole role,
    String text, {
    bool isPending = false,
  }) {
    final now = DateTime.now();
    return ChatMessage(
      id: '${now.microsecondsSinceEpoch}-${role.name}',
      role: role,
      text: text,
      createdAt: now,
      isPending: isPending,
    );
  }

  void _clearConversation() {
    setState(() {
      _messages = [
        _createMessage(
          ChatRole.assistant,
          'Cuộc trò chuyện đã được làm mới.',
        ),
      ];
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _ChatHeader(
            showSettings: _showSettings,
            onToggleSettings: () {
              setState(() => _showSettings = !_showSettings);
            },
            onClear: _clearConversation,
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: _ApiSettings(
              apiKeyController: _apiKeyController,
              modelController: _modelController,
            ),
            crossFadeState: _showSettings
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 180),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _MessageBubble(message: _messages[index]);
              },
            ),
          ),
          _MessageComposer(
            controller: _messageController,
            isSending: _isSending,
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }
}

class _ChatHeader extends StatelessWidget {
  const _ChatHeader({
    required this.showSettings,
    required this.onToggleSettings,
    required this.onClear,
  });

  final bool showSettings;
  final VoidCallback onToggleSettings;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 8, 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.auto_awesome,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gemini Chat',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                Text(
                  'REST API ready',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: showSettings ? 'Ẩn cấu hình' : 'Cấu hình',
            onPressed: onToggleSettings,
            icon: Icon(showSettings ? Icons.expand_less : Icons.tune),
          ),
          IconButton(
            tooltip: 'Xóa hội thoại',
            onPressed: onClear,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
    );
  }
}

class _ApiSettings extends StatelessWidget {
  const _ApiSettings({
    required this.apiKeyController,
    required this.modelController,
  });

  final TextEditingController apiKeyController;
  final TextEditingController modelController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
      child: Column(
        children: [
          TextField(
            controller: apiKeyController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Gemini API key',
              prefixIcon: Icon(Icons.key),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: modelController,
            decoration: const InputDecoration(
              labelText: 'Model',
              prefixIcon: Icon(Icons.memory),
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == ChatRole.user;
    final colorScheme = Theme.of(context).colorScheme;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isUser ? colorScheme.primary : colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser) ...[
                Icon(
                  Icons.auto_awesome,
                  size: 18,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: SelectableText(
                  message.text,
                  style: TextStyle(
                    color: isUser
                        ? colorScheme.onPrimary
                        : colorScheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageComposer extends StatelessWidget {
  const _MessageComposer({
    required this.controller,
    required this.isSending,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool isSending;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 5,
                textInputAction: TextInputAction.newline,
                decoration: const InputDecoration(
                  hintText: 'Nhập tin nhắn...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 10),
            FilledButton(
              onPressed: isSending ? null : onSend,
              style: FilledButton.styleFrom(
                minimumSize: const Size(52, 52),
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: isSending
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }
}
