import 'package:flutter/material.dart';

/// Breakpoint constant for switching between small and large window layouts.
const double largeScreenMinWidth = 600.0;

/// Maximum content width on large displays to prevent unnatural horizontal stretching.
const double maxContentWidth = 1100.0;

void main() {
  runApp(const EnglishFunApp());
}

class EnglishFunApp extends StatelessWidget {
  const EnglishFunApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'English Fun: Adaptive Lesson',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF5E8E),
          primary: const Color(0xFFFF5E8E),
          secondary: const Color(0xFF6C5CE7),
        ),
        scaffoldBackgroundColor: const Color(0xFFFFF6F9),
        useMaterial3: true,
      ),
      home: const AdaptiveEnglishLessonScreen(),
    );
  }
}

enum GrammarCategory { all, simple, continuous, prepositions }

class LessonPassage {
  final int id;
  final String title;
  final GrammarCategory category;
  final String badgeLabel;
  final String mainEmoji;
  final String topAccentEmoji;
  final String bottomAccentEmoji;
  final Color badgeBgColor;
  final Color accentColor;
  final String passageText;
  final String question;
  final List<String> options;
  final int correctOptionIndex;

  const LessonPassage({
    required this.id,
    required this.title,
    required this.category,
    required this.badgeLabel,
    required this.mainEmoji,
    required this.topAccentEmoji,
    required this.bottomAccentEmoji,
    required this.badgeBgColor,
    required this.accentColor,
    required this.passageText,
    required this.question,
    required this.options,
    required this.correctOptionIndex,
  });
}

class AdaptiveEnglishLessonScreen extends StatefulWidget {
  const AdaptiveEnglishLessonScreen({super.key});

  @override
  State<AdaptiveEnglishLessonScreen> createState() =>
      _AdaptiveEnglishLessonScreenState();
}

class _AdaptiveEnglishLessonScreenState
    extends State<AdaptiveEnglishLessonScreen> {
  GrammarCategory _selectedCategory = GrammarCategory.all;
  final Map<int, int> _selectedAnswers = {};

  List<LessonPassage> get _filteredPassages {
    if (_selectedCategory == GrammarCategory.all) {
      return _allPassages;
    }
    return _allPassages
        .where((p) => p.category == _selectedCategory)
        .toList();
  }

  int get _starsEarned {
    int count = 0;
    for (final passage in _allPassages) {
      if (_selectedAnswers[passage.id] == passage.correctOptionIndex) {
        count++;
      }
    }
    return count;
  }

  void _selectAnswer(int passageId, int optionIndex) {
    setState(() {
      _selectedAnswers[passageId] = optionIndex;
    });
  }

  void _resetAll() {
    setState(() {
      _selectedAnswers.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Use MediaQuery.sizeOf(context) to inspect overall window dimensions cleanly.
    final Size windowSize = MediaQuery.sizeOf(context);
    final bool isCompactHeight = windowSize.height < 500;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF6C5CE7),
        foregroundColor: Colors.white,
        elevation: 2,
        title: Row(
          children: [
            const Text('🌈 ', style: TextStyle(fontSize: 22)),
            const Flexible(
              child: Text(
                'English Fun: Adaptive Grammar Lesson',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 6.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE066),
                borderRadius: BorderRadius.circular(999),
              ),
              alignment: Alignment.center,
              child: Text(
                '⭐ $_starsEarned / ${_allPassages.length}',
                style: const TextStyle(
                  color: Color(0xFF6B4C00),
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: _resetAll,
            tooltip: 'Reset all answers',
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      // Wrap the main content area in a LayoutBuilder to make layout decisions
      // strictly from parent BoxConstraints rather than device orientation or hardware type.
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          if (constraints.maxWidth > largeScreenMinWidth) {
            return _buildLargeScreenLayout(
              constraints: constraints,
              isCompactHeight: isCompactHeight,
            );
          } else {
            return _buildSmallScreenLayout();
          }
        },
      ),
    );
  }

  /// Large-screen layout (`constraints.maxWidth > 600`):
  /// Places a navigation sidebar and a constrained responsive `GridView.builder` side-by-side.
  Widget _buildLargeScreenLayout({
    required BoxConstraints constraints,
    required bool isCompactHeight,
  }) {
    final passages = _filteredPassages;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: 230,
          child: _CategorySidebar(
            selectedCategory: _selectedCategory,
            starsEarned: _starsEarned,
            totalStars: _allPassages.length,
            isCompactHeight: isCompactHeight,
            onSelectCategory: (cat) {
              setState(() => _selectedCategory = cat);
            },
          ),
        ),
        const VerticalDivider(width: 1, thickness: 1),
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: maxContentWidth),
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 520,
                  mainAxisExtent: 265,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: passages.length,
                itemBuilder: (context, index) {
                  final passage = passages[index];
                  return _LessonPassageCard(
                    passage: passage,
                    selectedOption: _selectedAnswers[passage.id],
                    onSelectOption: (opt) => _selectAnswer(passage.id, opt),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Small-screen layout (`constraints.maxWidth <= 600`):
  /// Uses a top horizontal category bar and a lazy-rendered `ListView.builder`.
  Widget _buildSmallScreenLayout() {
    final passages = _filteredPassages;

    return Column(
      children: [
        _CompactCategoryBar(
          selectedCategory: _selectedCategory,
          onSelectCategory: (cat) {
            setState(() => _selectedCategory = cat);
          },
        ),
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                itemCount: passages.length,
                itemBuilder: (context, index) {
                  final passage = passages[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: _LessonPassageCard(
                      passage: passage,
                      selectedOption: _selectedAnswers[passage.id],
                      onSelectOption: (opt) => _selectAnswer(passage.id, opt),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Sidebar used in `_buildLargeScreenLayout`.
class _CategorySidebar extends StatelessWidget {
  final GrammarCategory selectedCategory;
  final int starsEarned;
  final int totalStars;
  final bool isCompactHeight;
  final ValueChanged<GrammarCategory> onSelectCategory;

  const _CategorySidebar({
    required this.selectedCategory,
    required this.starsEarned,
    required this.totalStars,
    required this.isCompactHeight,
    required this.onSelectCategory,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalStars == 0 ? 0.0 : starsEarned / totalStars;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!isCompactHeight) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B9D), Color(0xFF8E54E9)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '👧 Your Progress',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFFFFE066),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$starsEarned of $totalStars Stars Earned',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          const Text(
            'GRAMMAR TOPICS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Color(0xFF636E72),
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              children: [
                _SidebarFilterTile(
                  label: '🌟 All Passages (25)',
                  isSelected: selectedCategory == GrammarCategory.all,
                  onTap: () => onSelectCategory(GrammarCategory.all),
                ),
                _SidebarFilterTile(
                  label: '⏰ Present Simple',
                  isSelected: selectedCategory == GrammarCategory.simple,
                  onTap: () => onSelectCategory(GrammarCategory.simple),
                ),
                _SidebarFilterTile(
                  label: '🎬 Present Continuous',
                  isSelected: selectedCategory == GrammarCategory.continuous,
                  onTap: () => onSelectCategory(GrammarCategory.continuous),
                ),
                _SidebarFilterTile(
                  label: '📍 Prepositions',
                  isSelected: selectedCategory == GrammarCategory.prepositions,
                  onTap: () => onSelectCategory(GrammarCategory.prepositions),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarFilterTile extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarFilterTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Material(
        color: isSelected ? const Color(0xFFEDE9FE) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected
                    ? const Color(0xFF5F27CD)
                    : const Color(0xFF2D3436),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Horizontal filter chips for small screens.
class _CompactCategoryBar extends StatelessWidget {
  final GrammarCategory selectedCategory;
  final ValueChanged<GrammarCategory> onSelectCategory;

  const _CompactCategoryBar({
    required this.selectedCategory,
    required this.onSelectCategory,
  });

  @override
  Widget build(BuildContext context) {
    final items = <(GrammarCategory, String)>[
      (GrammarCategory.all, '🌟 All (25)'),
      (GrammarCategory.simple, '⏰ Simple'),
      (GrammarCategory.continuous, '🎬 Continuous'),
      (GrammarCategory.prepositions, '📍 Prepositions'),
    ];

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: items.map((item) {
            final isSelected = selectedCategory == item.$1;
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ChoiceChip(
                label: Text(item.$2),
                selected: isSelected,
                onSelected: (_) => onSelectCategory(item.$1),
                selectedColor: const Color(0xFF6C5CE7),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF2D3436),
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

/// Individual passage card with a compact, kid-friendly illustration badge
/// that sits beside the passage text using `Row` and `Expanded`.
class _LessonPassageCard extends StatelessWidget {
  final LessonPassage passage;
  final int? selectedOption;
  final ValueChanged<int> onSelectOption;

  const _LessonPassageCard({
    required this.passage,
    required this.selectedOption,
    required this.onSelectOption,
  });

  @override
  Widget build(BuildContext context) {
    final bool isAnswered = selectedOption != null;
    final bool isCorrect =
        isAnswered && selectedOption == passage.correctOptionIndex;

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: isCorrect
              ? const Color(0xFF00B894)
              : const Color(0xFFF1E4EE),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header row with number badge, flexible title, and topic pill
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF5E8E), Color(0xFF6C5CE7)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${passage.id}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    passage.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: Color(0xFF2D3436),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: passage.badgeBgColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    passage.badgeLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: passage.accentColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Story row: Compact 72x72 kid-friendly illustration + Expanded text
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF9FD),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF0EAF8)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _KidSceneThumbnail(passage: passage),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      passage.passageText,
                      style: const TextStyle(
                        fontSize: 13.5,
                        height: 1.4,
                        color: Color(0xFF343A40),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Question & feedback header
            Row(
              children: [
                Expanded(
                  child: Text(
                    '❓ ${passage.question}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF4A3B7C),
                    ),
                  ),
                ),
                if (isAnswered)
                  Text(
                    isCorrect ? '✅ +1 ⭐' : '💡 Try again!',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: isCorrect
                          ? const Color(0xFF00896C)
                          : const Color(0xFFD63031),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Adaptive option pills using LayoutBuilder for narrow vs wide cards
            LayoutBuilder(
              builder: (context, optionConstraints) {
                final bool useHorizontalRow = optionConstraints.maxWidth >= 340;
                if (useHorizontalRow) {
                  return Row(
                    children: List.generate(passage.options.length, (i) {
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: i < passage.options.length - 1 ? 6.0 : 0,
                          ),
                          child: _OptionPill(
                            label: passage.options[i],
                            isSelected: selectedOption == i,
                            isCorrect: i == passage.correctOptionIndex,
                            onTap: () => onSelectOption(i),
                          ),
                        ),
                      );
                    }),
                  );
                } else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: List.generate(passage.options.length, (i) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6.0),
                        child: _OptionPill(
                          label: passage.options[i],
                          isSelected: selectedOption == i,
                          isCorrect: i == passage.correctOptionIndex,
                          onTap: () => onSelectOption(i),
                        ),
                      );
                    }),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact 72x72 kid-friendly illustration badge so artwork never takes excessive space.
class _KidSceneThumbnail extends StatelessWidget {
  final LessonPassage passage;

  const _KidSceneThumbnail({required this.passage});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: passage.badgeBgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: passage.accentColor.withValues(alpha: 0.35),
          width: 2,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 4,
            right: 5,
            child: Text(
              passage.topAccentEmoji,
              style: const TextStyle(fontSize: 13),
            ),
          ),
          Positioned(
            bottom: 4,
            left: 5,
            child: Text(
              passage.bottomAccentEmoji,
              style: const TextStyle(fontSize: 13),
            ),
          ),
          Text(
            passage.mainEmoji,
            style: const TextStyle(fontSize: 30),
          ),
        ],
      ),
    );
  }
}

class _OptionPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isCorrect;
  final VoidCallback onTap;

  const _OptionPill({
    required this.label,
    required this.isSelected,
    required this.isCorrect,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor = Colors.white;
    Color borderColor = const Color(0xFFEBE3F2);
    Color textColor = const Color(0xFF2D3436);

    if (isSelected) {
      if (isCorrect) {
        bgColor = const Color(0xFFE8FBF6);
        borderColor = const Color(0xFF00B894);
        textColor = const Color(0xFF006D57);
      } else {
        bgColor = const Color(0xFFFFF0F0);
        borderColor = const Color(0xFFFF7675);
        textColor = const Color(0xFFC0392B);
      }
    }

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor, width: 1.8),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}

const List<LessonPassage> _allPassages = [
  LessonPassage(
    id: 1,
    title: 'Present Simple: Daily Routines',
    category: GrammarCategory.simple,
    badgeLabel: 'Routine',
    mainEmoji: '🚌',
    topAccentEmoji: '☀️',
    bottomAccentEmoji: '🎒',
    badgeBgColor: Color(0xFFFFF3BF),
    accentColor: Color(0xFFE67700),
    passageText:
        'My name is Lily. I wake up at 7:00 AM every day. I brush my teeth and have breakfast. Then I go to school by bus.',
    question: 'What does Lily do every day?',
    options: [
      'She plays football',
      'She wakes up at 7:00 AM',
      'She goes by car',
    ],
    correctOptionIndex: 1,
  ),
  LessonPassage(
    id: 2,
    title: "Present Continuous: What's Happening Now?",
    category: GrammarCategory.continuous,
    badgeLabel: 'Now',
    mainEmoji: '🎨',
    topAccentEmoji: '🖍️',
    bottomAccentEmoji: '🌈',
    badgeBgColor: Color(0xFFF3D9FA),
    accentColor: Color(0xFF5F27CD),
    passageText:
        'Look! Lily is drawing a picture. She is using colored pencils. Her friend Tom is running outside.',
    question: 'What is Lily doing?',
    options: ['She is sleeping', 'She is drawing', 'She is eating'],
    correctOptionIndex: 1,
  ),
  LessonPassage(
    id: 3,
    title: 'Prepositions: Where Is It?',
    category: GrammarCategory.prepositions,
    badgeLabel: 'Place',
    mainEmoji: '🐱',
    topAccentEmoji: '🪑',
    bottomAccentEmoji: '⚽',
    badgeBgColor: Color(0xFFFFE3E3),
    accentColor: Color(0xFF0097E6),
    passageText:
        'Lily is in the kitchen. The cat is on the table. The ball is under the chair. The book is next to the lamp.',
    question: 'Where is the cat?',
    options: ['on the table', 'in the kitchen', 'under the chair'],
    correctOptionIndex: 0,
  ),
  LessonPassage(
    id: 4,
    title: 'Present Simple vs Present Continuous',
    category: GrammarCategory.continuous,
    badgeLabel: 'Compare',
    mainEmoji: '🍫',
    topAccentEmoji: '⚽',
    bottomAccentEmoji: '😋',
    badgeBgColor: Color(0xFFD3F9D8),
    accentColor: Color(0xFF2B8A3E),
    passageText:
        'I like chocolate (general truth). I am eating chocolate now (happening now). My brother is playing football right now.',
    question: 'Which sentence is for something happening now?',
    options: [
      'I like chocolate',
      'I am eating chocolate',
      'My brother plays football',
    ],
    correctOptionIndex: 1,
  ),
  LessonPassage(
    id: 5,
    title: 'Prepositions Adventure',
    category: GrammarCategory.prepositions,
    badgeLabel: 'Movement',
    mainEmoji: '🌳',
    topAccentEmoji: '🌷',
    bottomAccentEmoji: '🦆',
    badgeBgColor: Color(0xFFD0EBFF),
    accentColor: Color(0xFF1971C2),
    passageText:
        'Tom is walking to the park. He goes through the gate. He jumps over the fence. He looks at the flowers.',
    question: 'Where is Tom walking?',
    options: ['to the park', 'through the gate', 'over the fence'],
    correctOptionIndex: 0,
  ),
  LessonPassage(
    id: 6,
    title: 'Present Simple: Hobbies',
    category: GrammarCategory.simple,
    badgeLabel: 'Hobbies',
    mainEmoji: '⚽',
    topAccentEmoji: '📚',
    bottomAccentEmoji: '🖌️',
    badgeBgColor: Color(0xFFE7F5FF),
    accentColor: Color(0xFF1864AB),
    passageText:
        'Tom loves playing football. He plays every weekend. His sister reads books in the library.',
    question: 'What does Tom love?',
    options: ['playing football', 'reading books', 'drawing pictures'],
    correctOptionIndex: 0,
  ),
  LessonPassage(
    id: 7,
    title: 'Present Continuous: Actions Now',
    category: GrammarCategory.continuous,
    badgeLabel: 'Actions',
    mainEmoji: '🐶',
    topAccentEmoji: '🐱',
    bottomAccentEmoji: '🐦',
    badgeBgColor: Color(0xFFFFF0F6),
    accentColor: Color(0xFFC2255C),
    passageText:
        'The dog is barking. The cat is sleeping. The baby is crying. The birds are flying in the garden.',
    question: 'What is the dog doing?',
    options: ['is barking', 'is sleeping', 'is crying'],
    correctOptionIndex: 0,
  ),
  LessonPassage(
    id: 8,
    title: 'Prepositions: Location',
    category: GrammarCategory.prepositions,
    badgeLabel: 'Location',
    mainEmoji: '👟',
    topAccentEmoji: '🛏️',
    bottomAccentEmoji: '🧸',
    badgeBgColor: Color(0xFFF8F0FC),
    accentColor: Color(0xFF9C36B5),
    passageText:
        'The book is on the shelf. The cup is in the cupboard. The shoes are under the bed. The toy is behind the sofa.',
    question: 'Where are the shoes?',
    options: ['on the shelf', 'in the cupboard', 'under the bed'],
    correctOptionIndex: 2,
  ),
  LessonPassage(
    id: 9,
    title: 'Present Simple: Family',
    category: GrammarCategory.simple,
    badgeLabel: 'Family',
    mainEmoji: '🏥',
    topAccentEmoji: '🚌',
    bottomAccentEmoji: '🎸',
    badgeBgColor: Color(0xFFE6FCF5),
    accentColor: Color(0xFF099268),
    passageText:
        'My mom works at a hospital. My dad drives a bus. My sister studies at university. My brother plays guitar.',
    question: 'Where does mom work?',
    options: ['at a hospital', 'at a school', 'at home'],
    correctOptionIndex: 0,
  ),
  LessonPassage(
    id: 10,
    title: 'Present Continuous: Weather',
    category: GrammarCategory.continuous,
    badgeLabel: 'Weather',
    mainEmoji: '🌧️',
    topAccentEmoji: '⛅',
    bottomAccentEmoji: '☂️',
    badgeBgColor: Color(0xFFE7F5FF),
    accentColor: Color(0xFF1971C2),
    passageText:
        'It is raining outside. The wind is blowing. The sun is shining through the clouds. The children are running home.',
    question: 'What is happening outside?',
    options: ['It is snowing', 'It is raining', 'It is sunny'],
    correctOptionIndex: 1,
  ),
  LessonPassage(
    id: 11,
    title: 'Prepositions: Time & Place',
    category: GrammarCategory.prepositions,
    badgeLabel: 'Time',
    mainEmoji: '⏰',
    topAccentEmoji: '🥞',
    bottomAccentEmoji: '🚂',
    badgeBgColor: Color(0xFFFFF9DB),
    accentColor: Color(0xFFE67700),
    passageText:
        "We eat breakfast in the morning. We sleep at night. The meeting is on Monday. The train leaves at 3 o'clock.",
    question: 'When do we eat breakfast?',
    options: ['in the morning', 'at night', 'on Monday'],
    correctOptionIndex: 0,
  ),
  LessonPassage(
    id: 12,
    title: 'Present Simple: School',
    category: GrammarCategory.simple,
    badgeLabel: 'School',
    mainEmoji: '🏫',
    topAccentEmoji: '🔔',
    bottomAccentEmoji: '📖',
    badgeBgColor: Color(0xFFFFF4E6),
    accentColor: Color(0xFFD9480F),
    passageText:
        'Students learn English. Teachers teach math. The bell rings at 8:00. Children play in the playground.',
    question: 'What do students learn?',
    options: ['English', 'Math', 'Science'],
    correctOptionIndex: 0,
  ),
  LessonPassage(
    id: 13,
    title: 'Present Continuous: Friends',
    category: GrammarCategory.continuous,
    badgeLabel: 'Friends',
    mainEmoji: '🎤',
    topAccentEmoji: '🎵',
    bottomAccentEmoji: '💃',
    badgeBgColor: Color(0xFFF3F0FF),
    accentColor: Color(0xFF5F3DC4),
    passageText:
        'Sarah is singing a song. Mark is dancing. Emma is reading a book. Jake is writing a letter.',
    question: 'What is Sarah doing?',
    options: ['is singing', 'is dancing', 'is reading'],
    correctOptionIndex: 0,
  ),
  LessonPassage(
    id: 14,
    title: 'Prepositions: Direction',
    category: GrammarCategory.prepositions,
    badgeLabel: 'Direction',
    mainEmoji: '🐦',
    topAccentEmoji: '🏠',
    bottomAccentEmoji: '🐟',
    badgeBgColor: Color(0xFFE3FAFC),
    accentColor: Color(0xFF0C8599),
    passageText:
        'The boy walks to school. The bird flies over the house. The fish swims through the water.',
    question: 'Where does the boy walk?',
    options: ['to school', 'over the house', 'through the water'],
    correctOptionIndex: 0,
  ),
  LessonPassage(
    id: 15,
    title: 'Present Simple: Animals',
    category: GrammarCategory.simple,
    badgeLabel: 'Animals',
    mainEmoji: '🦁',
    topAccentEmoji: '🐶',
    bottomAccentEmoji: '🐱',
    badgeBgColor: Color(0xFFFFF9DB),
    accentColor: Color(0xFFE67700),
    passageText:
        'Lions roar. Birds sing. Dogs bark. Cats meow. Fish swim. Snakes hiss.',
    question: 'What do dogs do?',
    options: ['roar', 'bark', 'meow'],
    correctOptionIndex: 1,
  ),
  LessonPassage(
    id: 16,
    title: 'Present Continuous: Kitchen',
    category: GrammarCategory.continuous,
    badgeLabel: 'Kitchen',
    mainEmoji: '👩‍🍳',
    topAccentEmoji: '🍲',
    bottomAccentEmoji: '🥕',
    badgeBgColor: Color(0xFFFFE8CC),
    accentColor: Color(0xFFD9480F),
    passageText:
        'Mom is cooking dinner. Dad is washing dishes. Sister is setting the table. Brother is cutting vegetables.',
    question: 'What is mom doing?',
    options: ['is cooking', 'is washing', 'is setting'],
    correctOptionIndex: 0,
  ),
  LessonPassage(
    id: 17,
    title: 'Prepositions: Around Home',
    category: GrammarCategory.prepositions,
    badgeLabel: 'Home',
    mainEmoji: '🛋️',
    topAccentEmoji: '🪞',
    bottomAccentEmoji: '🕰️',
    badgeBgColor: Color(0xFFF3D9FA),
    accentColor: Color(0xFF862E9C),
    passageText:
        'The lamp is near the bed. The mirror is opposite the door. The carpet is under the table. The clock is on the wall.',
    question: 'Where is the mirror?',
    options: ['near the bed', 'opposite the door', 'under the table'],
    correctOptionIndex: 1,
  ),
  LessonPassage(
    id: 18,
    title: 'Present Simple: Sports',
    category: GrammarCategory.simple,
    badgeLabel: 'Sports',
    mainEmoji: '🏀',
    topAccentEmoji: '🏊',
    bottomAccentEmoji: '🏃',
    badgeBgColor: Color(0xFFEBFBEE),
    accentColor: Color(0xFF2B8A3E),
    passageText:
        'Boys play football. Girls play basketball. Children swim in the pool. Everyone enjoys sports.',
    question: 'What do girls play?',
    options: ['football', 'basketball', 'tennis'],
    correctOptionIndex: 1,
  ),
  LessonPassage(
    id: 19,
    title: 'Present Continuous: Playground',
    category: GrammarCategory.continuous,
    badgeLabel: 'Playground',
    mainEmoji: '🛝',
    topAccentEmoji: '🎠',
    bottomAccentEmoji: '🎈',
    badgeBgColor: Color(0xFFFFF0F6),
    accentColor: Color(0xFFC2255C),
    passageText:
        'Children are swinging on the swings. Boys are sliding down the slide. Girls are jumping rope.',
    question: 'What are children doing?',
    options: ['are swinging', 'are sliding', 'are jumping'],
    correctOptionIndex: 0,
  ),
  LessonPassage(
    id: 20,
    title: 'Prepositions: In the Park',
    category: GrammarCategory.prepositions,
    badgeLabel: 'Park',
    mainEmoji: '🦆',
    topAccentEmoji: '⛲',
    bottomAccentEmoji: '🌳',
    badgeBgColor: Color(0xFFE6FCF5),
    accentColor: Color(0xFF099268),
    passageText:
        'We sit on the bench. We walk along the path. We play near the fountain. We feed ducks by the pond.',
    question: 'Where do we sit?',
    options: ['on the bench', 'along the path', 'near the fountain'],
    correctOptionIndex: 0,
  ),
  LessonPassage(
    id: 21,
    title: 'Present Simple: Food',
    category: GrammarCategory.simple,
    badgeLabel: 'Food',
    mainEmoji: '🍎',
    topAccentEmoji: '🥛',
    bottomAccentEmoji: '🍽️',
    badgeBgColor: Color(0xFFFFF5F5),
    accentColor: Color(0xFFC92A2A),
    passageText:
        "I eat breakfast at 8:00. I drink milk. I like apples. I don't like spicy food. I have dinner with my family.",
    question: 'What does she drink?',
    options: ['milk', 'juice', 'water'],
    correctOptionIndex: 0,
  ),
  LessonPassage(
    id: 22,
    title: 'Present Continuous: Hospital',
    category: GrammarCategory.continuous,
    badgeLabel: 'Helping',
    mainEmoji: '🩺',
    topAccentEmoji: '🚑',
    bottomAccentEmoji: '💊',
    badgeBgColor: Color(0xFFE7F5FF),
    accentColor: Color(0xFF1864AB),
    passageText:
        'The doctor is examining a patient. The nurse is giving medicine. The patient is resting.',
    question: 'What is the doctor doing?',
    options: ['is examining', 'is giving', 'is resting'],
    correctOptionIndex: 0,
  ),
  LessonPassage(
    id: 23,
    title: 'Prepositions: School Supplies',
    category: GrammarCategory.prepositions,
    badgeLabel: 'Supplies',
    mainEmoji: '✏️',
    topAccentEmoji: '📏',
    bottomAccentEmoji: '💻',
    badgeBgColor: Color(0xFFFFF9DB),
    accentColor: Color(0xFFE67700),
    passageText:
        'The pencil is in the case. The eraser is on the desk. The ruler is next to the book. The paper is under the laptop.',
    question: 'Where is the pencil?',
    options: ['in the case', 'on the desk', 'next to the book'],
    correctOptionIndex: 0,
  ),
  LessonPassage(
    id: 24,
    title: 'Present Simple: Transportation',
    category: GrammarCategory.simple,
    badgeLabel: 'Travel',
    mainEmoji: '🚲',
    topAccentEmoji: '🚗',
    bottomAccentEmoji: '🚆',
    badgeBgColor: Color(0xFFF3F0FF),
    accentColor: Color(0xFF5F3DC4),
    passageText:
        'I walk to school. My mom drives a car. My dad takes the bus. My sister rides a bike. We travel by train.',
    question: 'How does my sister travel?',
    options: ['rides a bike', 'drives a car', 'takes the bus'],
    correctOptionIndex: 0,
  ),
  LessonPassage(
    id: 25,
    title: 'Present Continuous: Beach',
    category: GrammarCategory.continuous,
    badgeLabel: 'Beach',
    mainEmoji: '🏖️',
    topAccentEmoji: '🏰',
    bottomAccentEmoji: '🌊',
    badgeBgColor: Color(0xFFE3FAFC),
    accentColor: Color(0xFF0C8599),
    passageText:
        'Children are building sandcastles. People are swimming. Families are sunbathing. Waves are crashing.',
    question: 'What are children doing?',
    options: ['are building', 'are swimming', 'are sunbathing'],
    correctOptionIndex: 0,
  ),
];
