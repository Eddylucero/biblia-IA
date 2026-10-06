import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'widgets/ai_message_card.dart';
import 'widgets/chat_message_bubble.dart';
import 'widgets/suggested_prompts.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();

  void _sendMessage([String? text]) {
    final query = text ?? _controller.text.trim();
    if (query.isNotEmpty) {
      _controller.clear();
      // Aquí se conectará con el BibleRepository o IA Service
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgSurface,
      appBar: AppBar(
        backgroundColor: AppColors.bgSurface.withValues(alpha: 0.85),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => Navigator.maybePop(context),
        ),
        titleSpacing: 0,
        title: const Row(
          children: [
            Text(
              'Consulta IA Teológica',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.bookmark_border,
              color: AppColors.onSurfaceVariant,
            ),
            onPressed: () {},
          ),
          const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.surfaceContainerLow,
              child: Icon(
                Icons.person,
                size: 20,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Subheader Status Bar
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 6.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'CONECTADO',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '•',
                      style: TextStyle(color: AppColors.outline, fontSize: 10),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.cloud_done,
                      size: 14,
                      color: AppColors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'modo offline listo',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    InkWell(
                      onTap: () {},
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.edit_note,
                              size: 16,
                              color: AppColors.onSurfaceVariant,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Nuevo',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert, size: 18),
                      color: AppColors.onSurfaceVariant,
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Central Date Indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Hoy · Estudio Teológico y Paz Interior',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Stream de mensajes
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              children: [
                const UserMessageBubble(
                  message: '¿Qué dice la Biblia sobre el miedo y la ansiedad?',
                  time: '09:42 AM',
                ),
                const SizedBox(height: 16),
                const AiMessageCard(
                  reflectionText:
                      'Según las Escrituras, el miedo es una emoción humana natural, pero se nos invita a no dejar que controle nuestras decisiones ni nuble nuestra paz. Dios nos recuerda constantemente que Su presencia y Su amor echan fuera todo temor.',
                  verses: [
                    VerseItem(
                      reference: 'Isaías 41:10',
                      category: 'Profecía de Consuelo',
                      text:
                          'No temas, porque yo estoy contigo; no desmayes, porque yo soy tu Dios que te esfuerzo; siempre te ayudaré, siempre te sustentaré con la diestra de mi justicia.',
                    ),
                    VerseItem(
                      reference: 'Salmos 23:4',
                      category: 'Cántico Davídico',
                      text:
                          'Aunque ande en valle de sombra de muerte, no temeré mal alguno, porque tú estarás conmigo; tu vara y tu cayado me infundirán aliento.',
                    ),
                    VerseItem(
                      reference: '2 Timoteo 1:7',
                      category: 'Epístola Paulina',
                      text:
                          'Porque no nos ha dado Dios espíritu de cobardía, sino de poder, de amor y de dominio propio.',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SuggestedPrompts(
                  onPromptSelect: (text) {
                    _controller.text = text;
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // Input Bar Flotante
          Container(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryContainer.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.mic,
                          color: AppColors.onSurfaceVariant,
                        ),
                        onPressed: () {},
                      ),
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: const InputDecoration(
                            hintText: 'Escribe tu pregunta bíblica...',
                            hintStyle: TextStyle(
                              color: AppColors.outline,
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                          onSubmitted: (val) => _sendMessage(val),
                        ),
                      ),
                      InkWell(
                        onTap: () => _sendMessage(),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.send,
                            color: AppColors.secondaryFixed,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.verified_user,
                      size: 12,
                      color: AppColors.outline,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Respuestas fundamentadas exclusivamente en el canon bíblico',
                      style: TextStyle(fontSize: 10, color: AppColors.outline),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
