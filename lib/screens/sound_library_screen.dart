import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/sound.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';
import '../widgets/glassmorphism_widgets.dart';

class SoundLibraryScreen extends StatefulWidget {
  final String initialCategory;

  const SoundLibraryScreen({Key? key, this.initialCategory = 'All'}) : super(key: key);

  @override
  State<SoundLibraryScreen> createState() => SoundLibraryScreenState();
}

class SoundLibraryScreenState extends State<SoundLibraryScreen> {
  late String _selectedCategory;
  late final ScrollController _scrollController;

  static const Map<String, IconData> _baseCategoryIcons = {
    'All': Icons.all_inclusive,
    'Rain': Icons.water_drop,
    'Nature': Icons.nature,
    'Wind': Icons.air,
    'Fire': Icons.local_fire_department,
    'Cafe': Icons.local_cafe,
    'White Noise': Icons.surround_sound,
    'Ambient': Icons.spa,
    'Ocean': Icons.waves,
    'Fantasy': Icons.auto_awesome,
  };

  Color _categoryAccent(String category) {
    switch (category) {
      case 'Rain':
        return Colors.blue;
      case 'Ocean':
        return Colors.lightBlue;
      case 'Nature':
        return Colors.green;
      case 'Wind':
        return Colors.cyan;
      case 'Fire':
        return Colors.orange;
      case 'Cafe':
        return Colors.brown;
      case 'White Noise':
        return Colors.indigo;
      case 'Ambient':
        return Colors.teal;
      case 'Fantasy':
        return Colors.deepPurpleAccent;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  List<String> _deriveCategories(List<Sound> sounds) {
    final categories = sounds.map((s) => s.category).toSet().toList();
    categories.sort();
    
    // Put All first, then Fantasy, then the rest
    final result = <String>['All'];
    if (categories.contains('Fantasy')) {
      result.add('Fantasy');
    }
    for (final cat in categories) {
      if (cat != 'Fantasy') {
        result.add(cat);
      }
    }
    return result;
  }

  List<Sound> _filtered(List<Sound> sounds) {
    if (_selectedCategory == 'All') return sounds;
    return sounds.where((s) => s.category == _selectedCategory).toList();
  }

  @override
  void initState() {
    super.initState();
    final availableCategories = _deriveCategories(StorageService.getAllSounds());
    _selectedCategory = availableCategories.contains(widget.initialCategory)
        ? widget.initialCategory
        : 'All';
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void selectCategory(String category) {
    final sounds = StorageService.getAllSounds();
    final availableCategories = _deriveCategories(sounds);
    final resolvedCategory = availableCategories.contains(category) ? category : 'All';

    setState(() {
      _selectedCategory = resolvedCategory;
    });
    jumpToTop();
  }

  void jumpToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.secondary;
    // Performance: Use Selector to only rebuild when playing states change
    return Selector<AudioPlayerService, Map<String, bool>>(
      selector: (_, service) => service.playingStates,
      builder: (context, playingStates, _) {
        final audioService = context.read<AudioPlayerService>();
        return _buildLibraryContent(context, theme, accent, audioService, playingStates);
      },
    );
  }
  
  Widget _buildLibraryContent(
    BuildContext context,
    ThemeData theme,
    Color accent,
    AudioPlayerService audioService,
    Map<String, bool> playingStates,
  ) {

    final sounds = StorageService.getAllSounds();
    final categories = _deriveCategories(sounds);
    final visible = _filtered(sounds);
    final categoryIcons = _buildCategoryIconMap(categories);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Library',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        forceMaterialTransparency: true,
      ),
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          // Use ClampingScrollPhysics for smoother scrolling (like professional music apps)
          physics: const ClampingScrollPhysics(),
          // Increase cache extent for better pre-rendering
          cacheExtent: 1000,
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildHeader(theme),
                  const SizedBox(height: 4),
                  _buildCategoryFilter(theme, categories, categoryIcons),
                  const SizedBox(height: 16),
                ]),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 240),
              sliver: _buildSliverGrid(theme, accent, audioService, visible, categoryIcons, playingStates),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, IconData> _buildCategoryIconMap(List<String> categories) {
    final icons = Map<String, IconData>.from(_baseCategoryIcons);
    for (final category in categories) {
      icons.putIfAbsent(category, () => Icons.music_note);
    }
    return icons;
  }

  Widget _buildHeader(ThemeData theme) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(Icons.library_music, color: theme.iconTheme.color?.withOpacity(0.8)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Explore ambient sounds', style: theme.textTheme.titleMedium),
                Text(
                  'Mix, match, and fine-tune to your mood',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter(
    ThemeData theme,
    List<String> categories,
    Map<String, IconData> categoryIcons,
  ) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(categories.length, (index) {
            final cat = categories[index];
            final selected = _selectedCategory == cat;
            return Padding(
              padding: EdgeInsets.only(right: index == categories.length - 1 ? 0 : 8),
              child: ChoiceChip(
                avatar: categoryIcons.containsKey(cat)
                    ? Icon(
                        categoryIcons[cat],
                        size: 18,
                      )
                    : null,
                label: Text(
                  cat,
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
                ),
                selected: selected,
                showCheckmark: false,
                onSelected: (_) => selectCategory(cat),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: const VisualDensity(horizontal: -2, vertical: -3),
                labelPadding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildSliverGrid(
    ThemeData theme,
    Color accent,
    AudioPlayerService audioService,
    List<Sound> visible,
    Map<String, IconData> categoryIcons,
    Map<String, bool> playingStates,
  ) {
    // Performance: Optimize SliverGrid with better delegate settings
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.20,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final sound = visible[index];
          final isPlaying = playingStates[sound.id] ?? false;
          final catAccent = _categoryAccent(sound.category);
          final iconData = categoryIcons[sound.category] ?? Icons.music_note;
          
          // Cache expensive computations
          final gradientColors = [
            catAccent.withOpacity(0.25),
            catAccent.withOpacity(0.12),
          ];
          
          return RepaintBoundary(
            key: ValueKey('sound_${sound.id}'), // Stable keys for better performance
            child: GlassCard(
          isSelected: isPlaying,
          accentColor: catAccent,
          padding: const EdgeInsets.all(8),
          onTap: () async {
            await audioService.initializeSound(sound);
            await audioService.toggleSound(sound.id);
            setState(() {});
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    )
                  ],
                ),
                child: Icon(
                  iconData,
                  size: 22,
                  color: theme.iconTheme.color?.withOpacity(0.85),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                sound.name,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: catAccent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: catAccent.withOpacity(0.3), width: 1),
                    ),
                    child: Text(
                      sound.category,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: catAccent,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  if (sound.isPremium) ...[
                    const SizedBox(width: 5),
                    Icon(Icons.workspace_premium, color: catAccent.withOpacity(0.9), size: 14),
                  ],
                  if (sound.id == 'tavern') ...[
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: catAccent.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: catAccent.withOpacity(0.35),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.auto_awesome, size: 12, color: catAccent),
                          const SizedBox(width: 3),
                          Text(
                            'Spécial',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: catAccent,
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        );
        },
        // Optimize grid scrolling performance
        addAutomaticKeepAlives: false,
        addRepaintBoundaries: true, // Keep repaint boundaries for grid items
        childCount: visible.length,
      ),
    );
  }
}
