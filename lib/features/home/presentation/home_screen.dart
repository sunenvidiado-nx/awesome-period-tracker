import 'package:awesome_period_tracker/core/app_assets.dart';
import 'package:awesome_period_tracker/core/extensions/date_time_extensions.dart';
import 'package:awesome_period_tracker/core/widgets/cards/app_card.dart';
import 'package:awesome_period_tracker/features/home/application/cycle_forecast_provider.dart';
import 'package:awesome_period_tracker/features/home/presentation/widgets/calendar.dart';
import 'package:awesome_period_tracker/features/home/presentation/widgets/cycle_insights.dart';
import 'package:awesome_period_tracker/features/home/presentation/widgets/info_cards.dart';
import 'package:awesome_period_tracker/features/home/presentation/widgets/symptoms_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late DateTime _selectedDate = DateTime.now().withoutTime();

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
      // TODO Uncomment this code to add a theme switcher to the app bar
      // leading: Consumer(
      //   builder: (context, ref, child) {
      //     final themeMode = ref.watch(themeModeProvider);

      //     return AnimatedSwitcher(
      //       duration: const Duration(milliseconds: 450),
      //       child: Padding(
      //         padding: const EdgeInsets.only(top: 4),
      //         child: IconButton(
      //           icon: Icon(
      //             themeMode == ThemeMode.dark
      //                 ? Icons.brightness_7_rounded
      //                 : Icons.brightness_4_rounded,
      //             color: context.colorScheme.onSurface.withOpacity(0.6),
      //           ),
      //           onPressed: ref.read(themeModeProvider.notifier).toggleTheme,
      //         ),
      //       ),
      //     );
      //   },
      // ),
      title: AnimatedSwitcher(
        duration: const Duration(milliseconds: 450),
        child: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: SvgPicture.asset(AppAssets.mainIconLong, height: 28),
        ),
      ),
    );
  }

  Widget _buildCalendarSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
        child: AppCard(
          child: Consumer(
            builder: (context, ref, child) {
              final state = ref
                  .watch(cycleForecastProvider(DateTime.now().withoutTime()));

              return Calendar(
                onDaySelected: (date, _) => _onDaySelected(date),
                selectedDate: _selectedDate,
                cycleEvents: state.maybeWhen(
                  data: (forecast) => forecast.events,
                  orElse: () => [],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _onDaySelected(DateTime selectedDay) {
    setState(() => _selectedDate = selectedDay);
  }

  Widget _buildCardsSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 16, 8, 0),
        child: InfoCards(_selectedDate),
      ),
    );
  }

  Widget _buildSymptoms() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 14, 8, 0),
        child: SymptomsSection(_selectedDate),
      ),
    );
  }

  Widget _buildCycleInsightsSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 18, 8, 0),
        child: CycleInsights(date: _selectedDate),
      ),
    );
  }
}
