import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stock_app/src/models/trade_response.dart';
import 'package:stock_app/src/utils/colors/app_colors.dart';
import 'package:stock_app/src/utils/constants/ui_constants.dart';
import 'package:stock_app/src/utils/services/ai_service.dart';

// ---------------------------------------------------------------------------
// Entry point – show as a bottom sheet
// ---------------------------------------------------------------------------

Future<void> showAiChatPanel(
  BuildContext context, {
  required int scanId,
  required String scanDate,
  required double? portfolioSize,
  required List<Trade> trades,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder:
        (_) => AiChatPanel(
          scanId: scanId,
          scanDate: scanDate,
          portfolioSize: portfolioSize,
          trades: trades,
        ),
  );
}

// ---------------------------------------------------------------------------
// Panel widget
// ---------------------------------------------------------------------------

class AiChatPanel extends StatefulWidget {
  final int scanId;
  final String scanDate;
  final double? portfolioSize;
  final List<Trade> trades;

  const AiChatPanel({
    super.key,
    required this.scanId,
    required this.scanDate,
    required this.portfolioSize,
    required this.trades,
  });

  @override
  State<AiChatPanel> createState() => _AiChatPanelState();
}

class _AiChatPanelState extends State<AiChatPanel> {
  final AiService _aiService = AiService();
  final TextEditingController _inputCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final FocusNode _focusNode = FocusNode();

  // Each message: {role: "user"|"assistant"|"system", content: "..."}
  final List<_ChatMsg> _messages = [];
  bool _isLoading = false;
  bool _initialised = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _sendInitialAnalysis());
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // ── Build API messages list ───────────────────────────────────────────────

  List<Map<String, String>> _buildHistory() {
    return _messages
        .where((m) => m.role != 'system')
        .map((m) => {'role': m.role, 'content': m.content})
        .toList();
  }

  List<Map<String, dynamic>> _tradesToJson() {
    return widget.trades.map((t) => t.toJson()).toList();
  }

  // ── First message: ask GPT to summarise the recommendations ──────────────

  Future<void> _sendInitialAnalysis() async {
    if (_initialised) return;
    _initialised = true;
    setState(() {
      _isLoading = true;
      _messages.add(
        _ChatMsg(
          role: 'user',
          content:
              'Please analyse these ${widget.trades.length} recommendations and give me a brief summary: which looks strongest, what the total risk is, and your overall take.',
        ),
      );
    });
    await _callAI();
  }

  // ── Send a follow-up from the user ────────────────────────────────────────

  Future<void> _send() async {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty || _isLoading) return;

    setState(() {
      _messages.add(_ChatMsg(role: 'user', content: text));
      _isLoading = true;
    });
    _inputCtrl.clear();
    _scrollToBottom();
    await _callAI();
  }

  // ── Core API call ─────────────────────────────────────────────────────────

  Future<void> _callAI() async {
    try {
      final response = await _aiService.chat(
        scanId: widget.scanId,
        scanDate: widget.scanDate,
        portfolioSize: widget.portfolioSize,
        trades: _tradesToJson(),
        messages: _buildHistory(),
      );

      if (response.statusCode == 200) {
        final reply =
            (response.data is Map)
                ? (response.data['reply'] ?? '').toString()
                : response.data.toString();
        setState(
          () => _messages.add(_ChatMsg(role: 'assistant', content: reply)),
        );
      } else {
        final err =
            (response.data is Map)
                ? (response.data['detail'] ?? 'AI request failed')
                : 'AI request failed';
        setState(
          () => _messages.add(_ChatMsg(role: 'error', content: err.toString())),
        );
      }
    } catch (e) {
      log('AI chat error: $e');
      setState(
        () => _messages.add(
          _ChatMsg(
            role: 'error',
            content: 'Failed to reach AI service. Check your connection.',
          ),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ── UI ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    return Container(
      height: screenH * 0.78,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHandle(),
          _buildHeader(),
          const Divider(height: 1),
          Expanded(child: _buildMessageList()),
          if (_isLoading) _buildTypingIndicator(),
          const Divider(height: 1),
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 4),
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.grey300,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: UIConstants.paddingXXL,
        vertical: UIConstants.paddingM,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              ),
              borderRadius: BorderRadius.circular(UIConstants.radiusS),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: UIConstants.spacingL),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI Trading Assistant',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: UIConstants.fontXL,
                  ),
                ),
                Text(
                  'Scan #${widget.scanId} · ${widget.trades.length} recommendations',
                  style: TextStyle(
                    color: AppColors.grey500,
                    fontSize: UIConstants.fontM,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.grey600),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    if (_messages.isEmpty && _isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Color(0xFF6366F1)),
            SizedBox(height: 16),
            Text('AI is analysing your recommendations…'),
          ],
        ),
      );
    }
    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.symmetric(
        horizontal: UIConstants.paddingXXL,
        vertical: UIConstants.paddingL,
      ),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        return _MessageBubble(msg: _messages[index]);
      },
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: UIConstants.paddingXXL,
        vertical: UIConstants.paddingS,
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 14,
            ),
          ),
          const SizedBox(width: 8),
          const _TypingDots(),
        ],
      ),
    );
  }

  Widget _buildInput() {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: UIConstants.paddingXXL,
          right: UIConstants.paddingXXL,
          top: UIConstants.paddingM,
          bottom:
              MediaQuery.of(context).viewInsets.bottom > 0
                  ? UIConstants.paddingM
                  : UIConstants.paddingL,
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _inputCtrl,
                focusNode: _focusNode,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  hintText: 'Ask about these recommendations…',
                  hintStyle: TextStyle(color: AppColors.grey400),
                  filled: true,
                  fillColor: AppColors.grey100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(UIConstants.radiusM),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: UIConstants.paddingL,
                    vertical: UIConstants.paddingM,
                  ),
                ),
                onSubmitted: (_) => _send(),
                maxLines: null,
              ),
            ),
            const SizedBox(width: UIConstants.spacingL),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: Material(
                color: _isLoading ? AppColors.grey300 : const Color(0xFF6366F1),
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: _isLoading ? null : _send,
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Message bubble
// ---------------------------------------------------------------------------

class _MessageBubble extends StatelessWidget {
  final _ChatMsg msg;

  const _MessageBubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    final isUser = msg.role == 'user';
    final isError = msg.role == 'error';

    if (isUser) {
      return Padding(
        padding: const EdgeInsets.only(bottom: UIConstants.spacingL, left: 48),
        child: Align(
          alignment: Alignment.centerRight,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: UIConstants.paddingL,
              vertical: UIConstants.paddingM,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1),
              borderRadius: BorderRadius.circular(UIConstants.radiusM),
            ),
            child: Text(
              msg.content,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ),
      );
    }

    // Assistant or error
    return Padding(
      padding: const EdgeInsets.only(bottom: UIConstants.spacingXXXL),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isError)
            Container(
              width: 28,
              height: 28,
              margin: const EdgeInsets.only(
                right: UIConstants.spacingL,
                top: 2,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 14,
              ),
            )
          else
            Container(
              width: 28,
              height: 28,
              margin: const EdgeInsets.only(
                right: UIConstants.spacingL,
                top: 2,
              ),
              decoration: const BoxDecoration(
                color: AppColors.errorLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                color: AppColors.error,
                size: 16,
              ),
            ),
          Expanded(
            child: GestureDetector(
              onLongPress:
                  isError
                      ? null
                      : () {
                        Clipboard.setData(ClipboardData(text: msg.content));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Copied to clipboard'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: UIConstants.paddingL,
                  vertical: UIConstants.paddingM,
                ),
                decoration: BoxDecoration(
                  color: isError ? AppColors.errorLight : AppColors.grey100,
                  borderRadius: BorderRadius.circular(UIConstants.radiusM),
                ),
                child: Text(
                  msg.content,
                  style: TextStyle(
                    fontSize: 14,
                    color: isError ? AppColors.error : AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Typing animation (three bouncing dots)
// ---------------------------------------------------------------------------

class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final delay = i / 3;
            final phase = (_ctrl.value + delay) % 1.0;
            final opacity = phase < 0.5 ? phase * 2 : (1 - phase) * 2;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: const Color(
                  0xFF6366F1,
                ).withValues(alpha: 0.3 + opacity * 0.7),
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Chat message data class
// ---------------------------------------------------------------------------

class _ChatMsg {
  final String role;
  final String content;

  _ChatMsg({required this.role, required this.content});
}
