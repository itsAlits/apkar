import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class ChatBubbleWidget extends StatefulWidget {
  final bool isThinking;
  final String message;
  final String userQuestion;

  const ChatBubbleWidget({
    super.key,
    required this.isThinking,
    required this.message,
    required this.userQuestion,
  });

  @override
  State<ChatBubbleWidget> createState() => _ChatBubbleWidgetState();
}

class _ChatBubbleWidgetState extends State<ChatBubbleWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _dotController;
  late Animation<double> _dotAnimation;

  @override
  void initState() {
    super.initState();
    _dotController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..repeat(reverse: true);
    _dotAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(_dotController);
  }

  @override
  void dispose() {
    _dotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.4),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryColor,
                ),
                child: const Center(
                  child: Text('🎭', style: TextStyle(fontSize: 14)),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'TAKSU AR (GEMINI AI)',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const Spacer(),
              if (widget.isThinking)
                _buildThinkingIndicator()
              else
                const Icon(
                  Icons.auto_awesome,
                  color: AppTheme.primaryColor,
                  size: 16,
                ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(color: AppTheme.primaryColor.withValues(alpha: 0.15), height: 1),
          const SizedBox(height: 10),
          // Content
          widget.isThinking ? _buildThinkingContent() : _buildResponseContent(),
        ],
      ),
    );
  }

  Widget _buildThinkingIndicator() {
    return AnimatedBuilder(
      animation: _dotAnimation,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryColor.withValues(
                  alpha: i == 0
                      ? _dotAnimation.value
                      : i == 1
                      ? (1.0 - _dotAnimation.value + 0.3).clamp(0.3, 1.0)
                      : _dotAnimation.value * 0.7 + 0.3,
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildThinkingContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Taksu AR sedang merenungkan filosofi...',
          style: TextStyle(
            color: AppTheme.primaryColor,
            fontSize: 13,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: const LinearProgressIndicator(
            minHeight: 2,
            backgroundColor: Colors.white10,
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
          ),
        ),
      ],
    );
  }

  Widget _buildResponseContent() {
    return Text(
      widget.message,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 13.5,
        height: 1.5,
        letterSpacing: 0.2,
      ),
      maxLines: 8,
      overflow: TextOverflow.ellipsis,
    );
  }
}
