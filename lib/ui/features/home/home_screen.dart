import 'package:awesome_period_tracker/app/core/extensions/build_context_extensions.dart';
import 'package:awesome_period_tracker/app/theme/app_assets.dart';
import 'package:awesome_period_tracker/app/theme_provider.dart';
import 'package:awesome_period_tracker/ui/common_widgets/cards/app_card.dart';
import 'package:awesome_period_tracker/ui/features/home/home_state_manager.dart';
import 'package:awesome_period_tracker/ui/features/home/widgets/calendar.dart';
import 'package:awesome_period_tracker/ui/features/home/widgets/cycle_insights.dart';
import 'package:awesome_period_tracker/ui/features/home/widgets/info_cards.dart';
import 'package:awesome_period_tracker/ui/features/home/widgets/symptoms_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late HomeStateManager _stateManager;

  /// Set to `true` to show theme switcher in app bar.
  final _showThemeSwitcher = false;

  @override
  void initState() {
    super.initState();
    _stateManager = GetIt.I()..initialize();
  }

  @override
  void dispose() {
    _stateManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          _buildCalendarSection(),
          _buildCardsSection(),
          _buildSymptoms(),
          _buildCycleInsightsSection(),
          const SliverToBoxAdapter(child: SafeArea(child: SizedBox.shrink())),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      toolbarHeight: 40,
      automaticallyImplyLeading: false,
      leading: _showThemeSwitcher ? _buildThemeModeSwitcher() : null,
      title: AnimatedSwitcher(
        duration: const Duration(milliseconds: 450),
        child: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: SvgPicture.asset(AppAssets.mainIconLong, height: 28),
        ),
      ),
    );
  }

  Widget _buildThemeModeSwitcher() {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: GetIt.I<ThemeModeManager>().notifier,
      builder: (context, state, _) => AnimatedSwitcher(
        duration: const Duration(milliseconds: 450),
        child: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: IconButton(
            icon: Icon(
              state == ThemeMode.dark
                  ? Icons.brightness_7_rounded
                  : Icons.brightness_4_rounded,
              color: context.colorScheme.onSurface.withAlpha(153),
            ),
            onPressed: GetIt.I<ThemeModeManager>().toggleTheme,
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
        child: AppCard(
          child: ValueListenableBuilder<HomeState>(
            valueListenable: _stateManager.notifier,
            builder: (context, state, _) => Calendar(
              onDaySelected: (date, _) =>
                  _stateManager.changeSelectedDateAndReinitialize(date: date),
              selectedDate: state.selectedDate,
              cycleEvents: state.forecast?.events ?? [],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardsSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 16, 8, 0),
        child: InfoCards(_stateManager),
      ),
    );
  }

  Widget _buildSymptoms() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 14, 8, 0),
        child: SymptomsSection(_stateManager),
      ),
    );
  }

  Widget _buildCycleInsightsSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 18, 8, 0),
        child: CycleInsights(_stateManager),
      ),
    );
  }
}
