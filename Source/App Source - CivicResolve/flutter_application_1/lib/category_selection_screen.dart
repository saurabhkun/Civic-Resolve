import 'package:flutter/material.dart';
import 'language_service.dart';
import 'report_details_screen.dart';
import 'help_screen.dart';

class CategorySelectionScreen extends StatefulWidget {
  const CategorySelectionScreen({super.key});

  @override
  State<CategorySelectionScreen> createState() => _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> 
    with TickerProviderStateMixin {
  final LanguageService _languageService = LanguageService();
  String? selectedCategory;
  
  late AnimationController _animationController;
  late AnimationController _staggerController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<ReportCategory> categories = [
    ReportCategory(
      id: 'potholes_roads',
      name: 'Potholes & Roads',
      icon: Icons.construction_rounded,
      color: const Color(0xFF1976D2),
      gradient: const LinearGradient(
        colors: [Color(0xFF1976D2), Color(0xFF1565C0)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      description: 'Road damage, potholes, cracks',
    ),
    ReportCategory(
      id: 'electricity_streetlights',
      name: 'Electricity & Streetlights',
      icon: Icons.lightbulb_rounded,
      color: const Color(0xFFFF9800),
      gradient: const LinearGradient(
        colors: [Color(0xFFFF9800), Color(0xFFF57C00)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      description: 'Power outages, broken lights',
    ),
    ReportCategory(
      id: 'water_drainage',
      name: 'Water & Drainage',
      icon: Icons.water_drop_rounded,
      color: const Color(0xFF00BCD4),
      gradient: const LinearGradient(
        colors: [Color(0xFF00BCD4), Color(0xFF0097A7)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      description: 'Water leaks, poor drainage',
    ),
    ReportCategory(
      id: 'waste_management',
      name: 'Waste Management',
      icon: Icons.recycling_rounded,
      color: const Color(0xFF4CAF50),
      gradient: const LinearGradient(
        colors: [Color(0xFF4CAF50), Color(0xFF388E3C)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      description: 'Garbage collection, recycling',
    ),
    ReportCategory(
      id: 'public_works',
      name: 'Public Works',
      icon: Icons.engineering_rounded,
      color: const Color(0xFF9C27B0),
      gradient: const LinearGradient(
        colors: [Color(0xFF9C27B0), Color(0xFF7B1FA2)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      description: 'Public facilities, maintenance',
    ),
    ReportCategory(
      id: 'parks_trees',
      name: 'Parks & Trees',
      icon: Icons.park_rounded,
      color: const Color(0xFF8BC34A),
      gradient: const LinearGradient(
        colors: [Color(0xFF8BC34A), Color(0xFF689F38)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      description: 'Green spaces, landscaping',
    ),
    ReportCategory(
      id: 'safety_hazard',
      name: 'Safety Hazard',
      icon: Icons.warning_rounded,
      color: const Color(0xFFFF5722),
      gradient: const LinearGradient(
        colors: [Color(0xFFFF5722), Color(0xFFE64A19)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      description: 'Dangerous conditions, hazards',
    ),
    ReportCategory(
      id: 'illegal_encroachment',
      name: 'Illegal Encroachment',
      icon: Icons.block_rounded,
      color: const Color(0xFFD32F2F),
      gradient: const LinearGradient(
        colors: [Color(0xFFD32F2F), Color(0xFFC62828)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      description: 'Unauthorized construction',
    ),
    ReportCategory(
      id: 'vandalism_graffiti',
      name: 'Vandalism & Graffiti',
      icon: Icons.brush_rounded,
      color: const Color(0xFF673AB7),
      gradient: const LinearGradient(
        colors: [Color(0xFF673AB7), Color(0xFF512DA8)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      description: 'Property damage, graffiti',
    ),
    ReportCategory(
      id: 'other',
      name: 'Other',
      icon: Icons.more_horiz_rounded,
      color: const Color(0xFF607D8B),
      gradient: const LinearGradient(
        colors: [Color(0xFF607D8B), Color(0xFF455A64)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      description: 'Issues not listed above',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _languageService.addListener(_onLanguageChanged);
    
    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    // Start animations
    _animationController.forward();
    _staggerController.forward();
  }

  @override
  void dispose() {
    _languageService.removeListener(_onLanguageChanged);
    _animationController.dispose();
    _staggerController.dispose();
    super.dispose();
  }

  void _onLanguageChanged() {
    setState(() {});
  }

  void _handleCategorySelection(ReportCategory category) {
    setState(() {
      selectedCategory = category.id;
    });
    
    // Navigate to report details after a short delay to show selection
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReportDetailsScreen(category: category),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF1976D2),
      brightness: Brightness.light,
    );
    
    return Theme(
      data: ThemeData.from(
        colorScheme: colorScheme,
        useMaterial3: true,
      ),
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: _buildModernAppBar(colorScheme),
        body: AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      // Hero Header Section
                      _buildHeroHeader(colorScheme),
                      
                      // Categories Grid
                      _buildScrollableCategoriesGrid(colorScheme),
                      
                      // Help Information Card
                      _buildHelpCard(colorScheme),
                      
                      // Extra bottom padding for FAB
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        floatingActionButton: selectedCategory != null 
            ? _buildFloatingActionButton(colorScheme)
            : null,
      ),
    );
  }

  PreferredSizeWidget _buildModernAppBar(ColorScheme colorScheme) {
    return AppBar(
      backgroundColor: colorScheme.surface,
      surfaceTintColor: colorScheme.surfaceTint,
      elevation: 0,
      scrolledUnderElevation: 3,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_rounded, color: colorScheme.onSurface),
        onPressed: () => Navigator.pop(context),
        style: IconButton.styleFrom(
          highlightColor: colorScheme.primary.withValues(alpha: 0.1),
          splashFactory: InkRipple.splashFactory,
        ),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.category_rounded,
              color: colorScheme.onPrimaryContainer,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Category',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
                Text(
                  'Step 1 of 3',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          child: IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HelpScreen(),
                ),
              );
            },
            style: IconButton.styleFrom(
              backgroundColor: colorScheme.primaryContainer.withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            icon: Stack(
              children: [
                Icon(
                  Icons.help_outline_rounded,
                  color: colorScheme.onPrimaryContainer,
                  size: 20,
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '?',
                        style: TextStyle(
                          color: colorScheme.onPrimary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroHeader(ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        elevation: 0,
        color: colorScheme.primaryContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.primaryContainer,
                colorScheme.primaryContainer.withValues(alpha: 0.8),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.report_problem_rounded,
                      color: colorScheme.onPrimary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Report a New Issue',
                          style: TextStyle(
                            color: colorScheme.onPrimaryContainer,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Help improve your community by reporting local issues',
                          style: TextStyle(
                            color: colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: colorScheme.surface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_rounded,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Choose the category that best describes your issue for faster resolution',
                        style: TextStyle(
                          color: colorScheme.onPrimaryContainer,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScrollableCategoriesGrid(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          for (int i = 0; i < categories.length; i += 2) ...[
            Row(
              children: [
                Expanded(
                  child: _buildCategoryCard(categories[i], i, colorScheme),
                ),
                const SizedBox(width: 16),
                if (i + 1 < categories.length)
                  Expanded(
                    child: _buildCategoryCard(categories[i + 1], i + 1, colorScheme),
                  )
                else
                  const Expanded(child: SizedBox()),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryCard(ReportCategory category, int index, ColorScheme colorScheme) {
    final isSelected = selectedCategory == category.id;
    
    return AnimatedBuilder(
      animation: _staggerController,
      builder: (context, child) {
        final delay = index * 0.1;
        final progress = Curves.easeOutCubic.transform(
          (((_staggerController.value - delay) / (1.0 - delay)).clamp(0.0, 1.0)),
        );
        
        return Transform.translate(
          offset: Offset(0, (1 - progress) * 50),
          child: Opacity(
            opacity: progress,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.95, end: 1.0),
              duration: const Duration(milliseconds: 200),
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: isSelected ? 1.02 : scale,
                  child: AspectRatio(
                    aspectRatio: 0.9,
                    child: Card(
                      elevation: 0,
                      color: isSelected 
                          ? category.color.withValues(alpha: 0.1)
                          : colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected 
                              ? category.color
                              : colorScheme.outline.withValues(alpha: 0.2),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: InkWell(
                        onTap: () => _handleCategorySelection(category),
                        borderRadius: BorderRadius.circular(20),
                        splashColor: category.color.withValues(alpha: 0.1),
                        highlightColor: category.color.withValues(alpha: 0.05),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Icon with gradient background
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  gradient: isSelected ? category.gradient : null,
                                  color: isSelected ? null : category.color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: isSelected ? [
                                    BoxShadow(
                                      color: category.color.withValues(alpha: 0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ] : [],
                                ),
                                child: Icon(
                                  category.icon,
                                  color: isSelected ? Colors.white : category.color,
                                  size: 32,
                                ),
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Category name
                              Text(
                                category.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                  color: isSelected ? category.color : colorScheme.onSurface,
                                  height: 1.2,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              
                              const SizedBox(height: 8),
                              
                              // Category description
                              Text(
                                category.description,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isSelected 
                                      ? category.color.withValues(alpha: 0.8)
                                      : colorScheme.onSurfaceVariant,
                                  height: 1.3,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              
                              if (isSelected) ...[
                                const SizedBox(height: 12),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: category.color,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.check_rounded,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Selected',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildHelpCard(ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const HelpScreen(),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Card(
          elevation: 0,
          color: colorScheme.secondaryContainer.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: colorScheme.secondary,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    Icons.help_center_outlined,
                    color: colorScheme.onSecondary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Need Help?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Get help with using the app, find the right category, or contact support.',
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: colorScheme.secondary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton(ColorScheme colorScheme) {
    final selectedCat = categories.firstWhere((cat) => cat.id == selectedCategory);
    
    return FloatingActionButton.extended(
      onPressed: () {
        // Navigate to next step with animation
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => 
                ReportDetailsScreen(category: selectedCat),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOutCubic;
              
              var tween = Tween(begin: begin, end: end).chain(
                CurveTween(curve: curve),
              );
              
              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      },
      backgroundColor: selectedCat.color,
      foregroundColor: Colors.white,
      elevation: 6,
      icon: Icon(Icons.arrow_forward_rounded),
      label: Text(
        'Continue',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    );
  }
}

class ReportCategory {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final LinearGradient gradient;
  final String description;

  ReportCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.gradient,
    required this.description,
  });
}