import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'widgets/profile_header_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgSurface,
      appBar: AppBar(
        backgroundColor: AppColors.bgSurface,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.auto_stories,
                size: 18,
                color: AppColors.secondaryFixed,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Perfil',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.onSurfaceVariant),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera de Sección
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AJUSTES & CUENTA',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                        letterSpacing: 1.1,
                      ),
                    ),
                    Text(
                      'Mi perfil',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.tune,
                    size: 20,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),

            // Tarjeta de Usuario
            const ProfileHeaderCard(
              name: 'Ana Martínez',
              email: 'ana.martinez@email.com',
              streakDays: 42,
              avatarUrl: 'assets/img/perfil.jpeg',
            ),

            const SizedBox(height: 24),

            // Grupo 1: Contenido y Actividad
            _buildSectionHeader('CONTENIDO Y ACTIVIDAD'),
            _buildGroupCard([
              _buildListTile(
                icon: Icons.favorite_border,
                title: 'Mis versículos favoritos',
                subtitle: 'Salmos, Proverbios y notas',
                trailingBadge: '24 versículos',
                onTap: () {},
              ),
              const Divider(height: 1, indent: 56),
              _buildListTile(
                icon: Icons.chat_bubble_outline,
                title: 'Historial de preguntas',
                subtitle: 'Tus consultas bíblicas recientes',
                onTap: () => Navigator.of(context).pushNamed('/history'),
              ),
              const Divider(height: 1, indent: 56),
              _buildProgressListTile(
                icon: Icons.auto_stories_outlined,
                title: 'Historial de lectura',
                progressText: 'Evangelios 85%',
                progressValue: 0.85,
                onTap: () {},
              ),
            ]),

            const SizedBox(height: 24),

            // Grupo 2: Preferencias
            _buildSectionHeader('PREFERENCIAS'),
            _buildGroupCard([
              _buildListTile(
                icon: Icons.format_size,
                title: 'Configuración de lectura',
                subtitle: 'Tamaño de letra, espaciado y fuente',
                trailingText: 'Newsreader',
                onTap: () {},
              ),
              const Divider(height: 1, indent: 56),
              // Selector de Tema
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.palette_outlined,
                        size: 20,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tema de la aplicación',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurface,
                            ),
                          ),
                          Text(
                            'Tono pergamino cálido',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => setState(() => _isDarkMode = false),
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: !_isDarkMode
                                    ? AppColors.surfaceContainerLowest
                                    : Colors.transparent,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.wb_sunny,
                                size: 16,
                                color: AppColors.secondary,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => setState(() => _isDarkMode = true),
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: _isDarkMode
                                    ? AppColors.surfaceContainerLowest
                                    : Colors.transparent,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.dark_mode,
                                size: 16,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, indent: 56),
              _buildListTile(
                icon: Icons.download_for_offline_outlined,
                title: 'Descargas automáticas',
                subtitle: 'Sincronizar comentarios offline',
                trailingBadge: 'Actualizado',
                isHighlightBadge: true,
                onTap: () {},
              ),
            ]),

            const SizedBox(height: 24),

            // Grupo 3: Información y Sesión
            _buildSectionHeader('INFORMACIÓN'),
            _buildGroupCard([
              _buildListTile(
                icon: Icons.info_outline,
                title: 'Acerca de Biblia IA',
                subtitle: 'Términos, doctrina y privacidad',
                trailingText: 'v2.4.0',
                onTap: () {},
              ),
              const Divider(height: 1, indent: 56),
              _buildListTile(
                icon: Icons.logout,
                title: 'Cerrar sesión',
                subtitle: 'ana.martinez@email.com',
                onTap: () {},
              ),
            ]),

            const SizedBox(height: 32),

            // Pie contemplativo
            Center(
              child: Column(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.menu_book,
                      size: 18,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '«Lámpara es a mis pies tu palabra»',
                    style: TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const Text(
                    'Salmo 119:105',
                    style: TextStyle(fontSize: 11, color: AppColors.outline),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: AppColors.outline,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildGroupCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    String? trailingBadge,
    String? trailingText,
    bool isHighlightBadge = false,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: AppColors.onSurfaceVariant),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingBadge != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isHighlightBadge
                    ? AppColors.secondaryFixed
                    : AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                trailingBadge,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isHighlightBadge
                      ? AppColors.onSecondaryFixed
                      : AppColors.onSurfaceVariant,
                ),
              ),
            ),
          if (trailingText != null)
            Text(
              trailingText,
              style: const TextStyle(fontSize: 12, color: AppColors.outline),
            ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, size: 18, color: AppColors.outline),
        ],
      ),
    );
  }

  Widget _buildProgressListTile({
    required IconData icon,
    required String title,
    required String progressText,
    required double progressValue,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: AppColors.onSurfaceVariant),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
          Text(
            progressText,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.secondary,
            ),
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 6.0),
        child: LinearProgressIndicator(
          value: progressValue,
          backgroundColor: AppColors.surfaceContainer,
          color: AppColors.secondary,
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        size: 18,
        color: AppColors.outline,
      ),
    );
  }
}
