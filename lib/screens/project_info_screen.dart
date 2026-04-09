import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/glowing_card.dart';

class ProjectInfoScreen extends StatelessWidget {
  const ProjectInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              _buildHeader(),
              const SizedBox(height: 30),
              _buildProjectStatus(),
              const SizedBox(height: 24),
              _buildSectionTitle('PROJE ÖZETİ'),
              _buildProjectDescription(),
              const SizedBox(height: 24),
              _buildSectionTitle('GELİŞTİRME YOL HARİTASI'),
              _buildRoadmap(),
              const SizedBox(height: 100), // Space for bottom bar
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PROJE VERİLERİ',
          style: TextStyle(
            fontFamily: 'Orbitron',
            fontSize: 10,
            letterSpacing: 4,
            color: AppTheme.accentCyan,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'NEON STRIKE: ORIGINS',
          style: TextStyle(
            fontFamily: 'Orbitron',
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 2,
          width: 60,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget _buildProjectStatus() {
    return Row(
      children: [
        _statusItem('MOTOR', 'UNREAL 5.3', AppTheme.accentCyan),
        const SizedBox(width: 12),
        _statusItem('TÜR', 'CYBER-RPG', AppTheme.accentPurple),
        const SizedBox(width: 12),
        _statusItem('AŞAMA', 'ALFA-ÖNCESİ', AppTheme.accentGold),
      ],
    );
  }

  Widget _statusItem(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Rajdhani',
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: color.withOpacity(0.7),
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'Orbitron',
          fontSize: 11,
          letterSpacing: 2,
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }

  Widget _buildProjectDescription() {
    return GlowingCard(
      glowColor: AppTheme.accentCyan,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Neon Strike: Origins, 2088 yılında geçen yüksek tempolu bir siberpunk RPG\'sidir. Oyuncular, Neon-İstanbul\'un neon ışıklı sokaklarında gezinen asi bir veri hırsızını canlandırır.',
              style: TextStyle(
                fontFamily: 'Rajdhani',
                fontSize: 15,
                color: AppTheme.textPrimary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                _tag('Siberpunk'),
                _tag('Aksiyon-RPG'),
                _tag('Tek Oyunculu'),
                _tag('Açık Dünya'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _tag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.bgElevated,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderGlow),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Rajdhani',
          fontSize: 10,
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }

  Widget _buildRoadmap() {
    return Column(
      children: [
        _roadmapItem('TEMEL MEKANİKLER', '90%', AppTheme.accentCyan, true),
        _roadmapItem('DÜNYA TASARIMI', '45%', AppTheme.accentPurple, false),
        _roadmapItem('GÖREV SİSTEMİ', '20%', AppTheme.accentGold, false),
        _roadmapItem('YAPAY ZEKA', '10%', AppTheme.accentPink, false),
      ],
    );
  }

  Widget _roadmapItem(String title, String progress, Color color, bool isDone) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppTheme.borderGlow),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [
                BoxShadow(color: color.withOpacity(0.5), blurRadius: 4),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      progress,
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: double.parse(progress.replaceAll('%', '')) / 100,
                    backgroundColor: AppTheme.bgDeep,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
