import 'package:awesome_period_tracker/ui/features/home/home_state_manager.dart';
import 'package:awesome_period_tracker/ui/features/home/widgets/home_calendar.dart';
import 'package:awesome_period_tracker/utils/extensions/build_context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:skeletonizer/skeletonizer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late HomeStateManager _stateManager;

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
          SliverList(
            delegate: SliverChildListDelegate([
              _buildCalendar(),
            ]),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      toolbarHeight: 72,
      centerTitle: false,
      automaticallyImplyLeading: false,
      titleTextStyle: context.primaryTextTheme.headlineLarge,
      title: ValueListenableBuilder(
        valueListenable: _stateManager.notifier,
        builder: (context, state, _) => Skeletonizer(
          enabled: state is LoadingHomeState,
          child: Text(
            switch (state) {
              DataHomeState(userName: final userName) =>
                context.l10n.helloUser(userName),
              LoadingHomeState() => context.l10n.loading,
              _ => context.l10n.veryShortGenericError,
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return ValueListenableBuilder(
      valueListenable: _stateManager.notifier,
      builder: (context, state, _) => HomeCalendar(
        onDaySelected: (selectedDay, _) {
          _stateManager.changeSelectedDate(selectedDay);
        },
        cycleEvents: switch (state) {
          DataHomeState(events: final events) => events,
          _ => [],
        },
        focusedDate: switch (state) {
          DataHomeState(selectedDate: final selectedDate) => selectedDate,
          _ => DateTime.now(),
        },
      ),
    );
  }
}
