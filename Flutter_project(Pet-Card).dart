import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(PetPalApp());
}

// ---------------------------
// Main App & Theme
// ----------------------------
class PetPalApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PetPal+ 💙',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        // Using a blue/teal scheme for the new version
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        scaffoldBackgroundColor: const Color(0xFFF0F8FF), // Light blue background
        fontFamily: 'Roboto',
      ),
      home: PetHomePage(),
    );
  }
}

// ---------------------------
// Model
// ----------------------------
class Pet {
  String name;
  String emoji;
  
  // Feeding stats
  int feedingIntervalDays; // 1 - 7
  DateTime lastFed;

  // Play stats
  int playIntervalDays; // 1 - 7
  DateTime lastPlayed;

  Pet({
    required this.name,
    required this.emoji,
    required this.feedingIntervalDays,
    required this.lastFed,
    required this.playIntervalDays,
    required this.lastPlayed,
  });

  // Calculated properties
  bool get needsFeeding =>
      DateTime.now().difference(lastFed).inDays >= feedingIntervalDays;

  bool get needsPlay =>
      DateTime.now().difference(lastPlayed).inDays >= playIntervalDays;
      
  bool get needsAttention => needsFeeding || needsPlay;
}

// ---------------------------
// Home (Tabs + Shared State)
// ----------------------------
class PetHomePage extends StatefulWidget {
  @override
  State<PetHomePage> createState() => _PetHomePageState();
}

class _PetHomePageState extends State<PetHomePage>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  // Initialize with more detailed pets
  final List<Pet> pets = [
    Pet(
      name: 'Pippin',
      emoji: '🐶',
      feedingIntervalDays: 1,
      lastFed: DateTime.now().subtract(const Duration(hours: 30)), // Needs feeding
      playIntervalDays: 1,
      lastPlayed: DateTime.now().subtract(const Duration(hours: 12)), // Doesn't need play
    ),
    Pet(
      name: 'Mittens',
      emoji: '🐱',
      feedingIntervalDays: 2,
      lastFed: DateTime.now().subtract(const Duration(hours: 12)), // Healthy
      playIntervalDays: 2,
      lastPlayed: DateTime.now().subtract(const Duration(hours: 50)), // Needs play
    ),
     Pet(
      name: 'Bugs',
      emoji: '🐰',
      feedingIntervalDays: 1,
      lastFed: DateTime.now().subtract(const Duration(hours: 10)), // Healthy
      playIntervalDays: 3,
      lastPlayed: DateTime.now().subtract(const Duration(hours: 12)), // Healthy
    ),
  ];

  void _addPet(Pet p) {
    setState(() => pets.add(p));
  }

  void _feedPet(Pet p) {
    setState(() => p.lastFed = DateTime.now());
  }
  
  void _playWithPet(Pet p) {
    setState(() => p.lastPlayed = DateTime.now());
  }

  void _deletePet(Pet p) {
    setState(() => pets.remove(p));
  }

  // Basic derived stats
  int get totalPets => pets.length;
  int get needsFeedingCount => pets.where((p) => p.needsFeeding).length;
  int get needsPlayCount => pets.where((p) => p.needsPlay).length;
  double get averageFeedInterval =>
      pets.isEmpty ? 0 : pets.map((p) => p.feedingIntervalDays).reduce((a, b) => a + b) / pets.length;
  DateTime? get latestFed {
    if (pets.isEmpty) return null;
    pets.sort((a, b) => b.lastFed.compareTo(a.lastFed));
    return pets.first.lastFed;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          MyPetsTab(
            pets: pets,
            onAdd: () async {
              final p = await showDialog<Pet>(
                context: context,
                builder: (c) => AddPetDialog(),
              );
              if (p != null) _addPet(p);
            },
            onFeed: _feedPet,
            onPlay: _playWithPet,
            onDelete: _deletePet,
          ),
          StatsTab(
            pets: pets,
            totalPets: totalPets,
            needsFeedingCount: needsFeedingCount,
            needsPlayCount: needsPlayCount,
            averageFeedInterval: averageFeedInterval,
            latestFed: latestFed,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue.shade800,
        unselectedItemColor: Colors.grey[600],
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.pets), label: 'My Pets'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Stats'),
        ],
      ),
    );
  }
}

// ---------------------------
// My Pets Tab (Grid)
// ----------------------------
class MyPetsTab extends StatefulWidget {
  final List<Pet> pets;
  final VoidCallback onAdd;
  final void Function(Pet) onFeed;
  final void Function(Pet) onPlay;
  final void Function(Pet) onDelete;

  const MyPetsTab({
    required this.pets,
    required this.onAdd,
    required this.onFeed,
    required this.onPlay,
    required this.onDelete,
  });

  @override
  State<MyPetsTab> createState() => _MyPetsTabState();
}

class _MyPetsTabState extends State<MyPetsTab> with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pets = widget.pets;
    return SafeArea(
      child: Column(
        children: [
          // Header area
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'My Pets',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.blue.shade900),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: widget.onAdd,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Pet'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    elevation: 8,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
          // Quick summary row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                _StatChip(
                  emoji: '🐾',
                  label: '${pets.length}',
                  subtitle: 'Total',
                  color: Colors.blue.shade700,
                ),
                const SizedBox(width: 10),
                _StatChip(
                  emoji: '🍽️',
                  label: '${pets.where((p) => p.needsFeeding).length}',
                  subtitle: 'Needs Feed',
                  color: Colors.orange.shade700,
                ),
                const SizedBox(width: 10),
                _StatChip(
                  emoji: '🎾',
                  label: '${pets.where((p) => p.needsPlay).length}',
                  subtitle: 'Needs Play',
                  color: Colors.green.shade700,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: pets.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('No pets yet', style: TextStyle(fontSize: 20, color: Colors.grey[700], fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          Text('Tap "Add Pet" to start tracking your furry friends 🐕',
                              textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: 220,
                            child: ElevatedButton.icon(
                              onPressed: widget.onAdd,
                              icon: const Icon(Icons.add),
                              label: const Text('Add your first pet'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade600,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.95,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                    ),
                    itemCount: pets.length,
                    itemBuilder: (context, i) {
                      final p = pets[i];
                      final delay = (i * 80);
                      return FadeScaleTile(
                        delayMs: delay,
                        child: PetCard(
                          pet: p,
                          onFeed: () => widget.onFeed(p),
                          onPlay: () => widget.onPlay(p),
                          onDelete: () => widget.onDelete(p),
                        ),
                      );
                    },
                  ),
          )
        ],
      ),
    );
  }
}

// ---------------------------
// Pet Card (hover/press overlay)
// ----------------------------
class PetCard extends StatefulWidget {
  final Pet pet;
  final VoidCallback onFeed;
  final VoidCallback onPlay;
  final VoidCallback onDelete;

  const PetCard({
    required this.pet,
    required this.onFeed,
    required this.onPlay,
    required this.onDelete,
  });

  @override
  State<PetCard> createState() => _PetCardState();
}

class _PetCardState extends State<PetCard> with SingleTickerProviderStateMixin {
  bool _hover = false;
  bool _overlayVisible = false;
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleOverlay() {
    setState(() {
      _overlayVisible = !_overlayVisible;
      if (_overlayVisible) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.pet;
    final needsAttention = p.needsAttention;
    
    // Determine status text (priority: Feed > Play > Happy)
    String statusText;
    Color statusColor;
    if (p.needsFeeding) {
      statusText = '🍽️ Needs Feeding';
      statusColor = Colors.red.shade700;
    } else if (p.needsPlay) {
      statusText = '🎾 Needs Play';
      statusColor = Colors.orange.shade800;
    } else {
      statusText = '✨ Happy Pet';
      statusColor = Colors.blue.shade700;
    }

    final baseColor = needsAttention ? Colors.red.shade50 : Colors.blue.shade50;
    final accent = needsAttention ? Colors.red.shade700 : Colors.blue.shade800;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: _toggleOverlay,
        onLongPress: _toggleOverlay,
        child: AnimatedScale(
          scale: _hover || _overlayVisible ? 1.04 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutBack,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.shade200.withOpacity(0.5),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              children: [
                // 🐾 Main card content
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.white,
                      child: Text(p.emoji, style: const TextStyle(fontSize: 32)),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      p.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: accent,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      statusText,
                      style: TextStyle(color: statusColor, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _TinyIconButton(
                            icon: Icons.restaurant,
                            label: 'Fed',
                            onTap: widget.onFeed),
                        const SizedBox(width: 8),
                        _TinyIconButton(
                            icon: Icons.sports_tennis,
                            label: 'Played',
                            onTap: widget.onPlay),
                      ],
                    ),
                  ],
                ),

                // 📝 Overlay info
                Positioned.fill(
                  child: FadeTransition(
                    opacity: _controller,
                    child: IgnorePointer(
                      ignoring: !_overlayVisible,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.97),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              p.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Last fed: ${p.lastFed.toLocal().toString().split(' ')[0]}',
                              style: const TextStyle(fontSize: 13),
                            ),
                            Text(
                              '(Every ${p.feedingIntervalDays} days)',
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Last played: ${p.lastPlayed.toLocal().toString().split(' ')[0]}',
                              style: const TextStyle(fontSize: 13),
                            ),
                            Text(
                              '(Every ${p.playIntervalDays} days)',
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                            const SizedBox(height: 10),
                            // Moved Delete button here
                            TextButton.icon(
                              onPressed: () {
                                _toggleOverlay(); // Close overlay first
                                widget.onDelete(); // Then delete
                              },
                              icon: Icon(Icons.delete_forever, color: Colors.red.shade600),
                              label: Text('Remove Pet', style: TextStyle(color: Colors.red.shade600)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------
// Small helper widgets
// ----------------------------
class _TinyIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _TinyIconButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              Icon(icon, size: 16, color: Colors.blue.shade700),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String emoji;
  final dynamic label;
  final String subtitle;
  final Color color;

  const _StatChip({required this.emoji, required this.label, required this.subtitle, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.12), blurRadius: 12, offset: const Offset(0, 8)),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(backgroundColor: color.withOpacity(0.12), child: Text(emoji)),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$label', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Colors.grey[900])),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            )
          ],
        ),
      ),
    );
  }
}

// ---------------------------
// Add Pet Dialog
// ----------------------------
class AddPetDialog extends StatefulWidget {
  @override
  State<AddPetDialog> createState() => _AddPetDialogState();
}

class _AddPetDialogState extends State<AddPetDialog> {
  final TextEditingController _nameController = TextEditingController();
  int _feedInterval = 1; // Default feeding interval: 1 day
  int _playInterval = 1; // Default play interval: 1 day
  
  // ✅ UPDATED: 15 pet emojis
  final List<String> _emojis = [
    '🐶', '🐱', '🐰', '🐹', '🐠', '🦜', '🐢', '🐍', 
    '🦎', '🐸', '🐁', '🐔', '🐖', '🐴', '🐑'
  ];
  String _selectedEmoji = '🐶';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Pet'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Pet name'),
            ),
            const SizedBox(height: 16),
            // ✅ UPDATED: The Wrap will now show all 15 emojis
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: _emojis.map((e) {
                final selected = e == _selectedEmoji;
                return ChoiceChip(
                  label: Text(e, style: const TextStyle(fontSize: 20)),
                  selected: selected,
                  onSelected: (_) => setState(() => _selectedEmoji = e),
                  elevation: selected ? 6 : 2,
                  selectedColor: Colors.blue.shade100,
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            // Feeding Slider
            const Text('Feed every...'),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    min: 1, max: 7, divisions: 6,
                    value: _feedInterval.toDouble(),
                    label: '$_feedInterval days',
                    onChanged: (v) => setState(() => _feedInterval = v.round()),
                  ),
                ),
                Text('$_feedInterval d'),
              ],
            ),
            // Play Slider
            const Text('Play with every...'),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    min: 1, max: 7, divisions: 6,
                    value: _playInterval.toDouble(),
                    label: '$_playInterval days',
                    onChanged: (v) => setState(() => _playInterval = v.round()),
                  ),
                ),
                Text('$_playInterval d'),
              ],
            )
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            final name = _nameController.text.trim();
            if (name.isEmpty) return;
            // Set lastFed/Played randomly in the past
            final now = DateTime.now();
            final p = Pet(
              name: name,
              emoji: _selectedEmoji,
              feedingIntervalDays: _feedInterval,
              playIntervalDays: _playInterval,
              lastFed: now.subtract(Duration(days: Random().nextInt(max(1, _feedInterval)))),
              lastPlayed: now.subtract(Duration(days: Random().nextInt(max(1, _playInterval)))),
            );
            Navigator.pop(context, p);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade700,
            foregroundColor: Colors.white,
          ),
          child: const Text('Add'),
        )
      ],
    );
  }
}

// ---------------------------
// Stats Tab (NOW STATEFUL with TabController)
// ----------------------------
class StatsTab extends StatefulWidget {
  final List<Pet> pets;
  final int totalPets;
  final int needsFeedingCount;
  final int needsPlayCount;
  final double averageFeedInterval;
  final DateTime? latestFed;

  const StatsTab({
    required this.pets,
    required this.totalPets,
    required this.needsFeedingCount,
    required this.needsPlayCount,
    required this.averageFeedInterval,
    required this.latestFed,
  });

  @override
  State<StatsTab> createState() => _StatsTabState();
}

class _StatsTabState extends State<StatsTab> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // produce counts for intervals 1..7 for FEEDING
  List<int> _feedIntervalCounts() {
    final counts = List<int>.filled(7, 0); // 7 days max
    for (var p in widget.pets) {
      final idx = p.feedingIntervalDays.clamp(1, 7) - 1;
      counts[idx] += 1;
    }
    return counts;
  }
  
  // produce counts for intervals 1..7 for PLAYING
  List<int> _playIntervalCounts() {
    final counts = List<int>.filled(7, 0); // 7 days max
    for (var p in widget.pets) {
      final idx = p.playIntervalDays.clamp(1, 7) - 1;
      counts[idx] += 1;
    }
    return counts;
  }

  @override
  Widget build(BuildContext context) {
    final feedCounts = _feedIntervalCounts();
    final maxFeedCount = feedCounts.isEmpty ? 1 : feedCounts.reduce(max);
    
    final playCounts = _playIntervalCounts();
    final maxPlayCount = playCounts.isEmpty ? 1 : playCounts.reduce(max);

    return SafeArea(
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Dashboard',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.blue.shade900,
                    ),
                  ),
                ),
                Icon(Icons.show_chart, color: Colors.blue.shade700),
              ],
            ),
          ),

          // Stat cards
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: _LargeStatCard(
                    title: 'Total Pets',
                    value: '${widget.totalPets}',
                    emoji: '🐾',
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _LargeStatCard(
                    title: 'Needs Feed',
                    value: '${widget.needsFeedingCount}',
                    emoji: '🍽️',
                    color: Colors.orange.shade700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: _LargeStatCard(
                    title: 'Needs Play',
                    value: '${widget.needsPlayCount}',
                    emoji: '🎾',
                    color: Colors.green.shade700,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _LargeStatCard(
                    title: 'Avg Feed Int.',
                    value: widget.totalPets == 0
                        ? '-'
                        : '${widget.averageFeedInterval.toStringAsFixed(1)} d',
                    emoji: '⏱️',
                    color: Colors.teal.shade700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Bar chart header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Pet Activity Intervals (days)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ),
          ),
          
          // TabBar for switching charts
          TabBar(
            controller: _tabController,
            labelColor: Colors.blue.shade800,
            unselectedLabelColor: Colors.grey[600],
            indicatorColor: Colors.blue.shade700,
            tabs: const [
              Tab(text: 'Feeding', icon: Icon(Icons.restaurant)),
              Tab(text: 'Playing', icon: Icon(Icons.sports_tennis)),
            ],
          ),

          // TabBarView with charts
          Expanded(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
              child: TabBarView(
                controller: _tabController,
                children: [
                  // ✅ Feeding Chart (This will now display correctly)
                  _buildChart(feedCounts, maxFeedCount, Colors.blue.shade600),
                  // ✅ Play Chart (This will also display correctly)
                  _buildChart(playCounts, maxPlayCount, Colors.green.shade600),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build a chart container
  Widget _buildChart(List<int> counts, int maxCount, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade200.withOpacity(0.3),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(7, (i) {
                        final count = counts[i];
                        final label = '${i + 1}d';
                        final heightFactor = maxCount == 0 ? 0.0 : (count / maxCount);
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: _AnimatedBar(
                            label: label,
                            count: count,
                            heightFactor: heightFactor,
                            color: color,
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Interval (days)', style: TextStyle(color: Colors.grey)),
                      Text('Max: $maxCount', style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------
// Animated vertical bar widget
// ----------------------------
class _AnimatedBar extends StatelessWidget {
  final String label;
  final int count;
  final double heightFactor; // 0..1
  final Color color;
  const _AnimatedBar({required this.label, required this.count, required this.heightFactor, required this.color});

  @override
  Widget build(BuildContext context) {
    final barHeight = 160.0; // Fixed height for consistency
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: heightFactor),
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOutBack,
          builder: (context, val, child) {
            return Container(
              width: 28,
              height: barHeight * val.clamp(0.0, 1.0),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 6))],
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        Text('$count', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

// ---------------------------
// Large stat card for Dashboard
// ----------------------------
class _LargeStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String emoji;
  final Color color;

  const _LargeStatCard({required this.title, required this.value, required this.emoji, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 92,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: color.withOpacity(0.14), blurRadius: 18, offset: const Offset(0, 8))]),
      child: Row(
        children: [
          CircleAvatar(radius: 28, backgroundColor: color.withOpacity(0.12), child: Text(emoji, style: const TextStyle(fontSize: 22))),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text(title, style: const TextStyle(color: Colors.grey)),
            ],
          )
        ],
      ),
    );
  }
}

// ---------------------------
// FadeScaleTile - small entrance animation
// ----------------------------
class FadeScaleTile extends StatefulWidget {
  final Widget child;
  final int delayMs;
  const FadeScaleTile({required this.child, required this.delayMs});

  @override
  State<FadeScaleTile> createState() => _FadeScaleTileState();
}

class _FadeScaleTileState extends State<FadeScaleTile> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    _anim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: ScaleTransition(scale: _anim, child: widget.child),
    );
  }
}