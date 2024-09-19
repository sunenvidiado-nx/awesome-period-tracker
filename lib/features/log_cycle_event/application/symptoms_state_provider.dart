import 'package:awesome_period_tracker/core/constants/strings.dart';
import 'package:awesome_period_tracker/features/log_cycle_event/data/symptoms_repository.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'symptoms_state_provider.mapper.dart';

@MappableClass()
class SymptomsState with SymptomsStateMappable {
  final List<String> symptoms;
  final List<String> selected;

  const SymptomsState({required this.symptoms, required this.selected});
}

class SymptomsStateProvider
    extends AutoDisposeFamilyAsyncNotifier<SymptomsState, String> {
  @override
  Future<SymptomsState> build(String arg) async {
    final selected = arg.split(Strings.symptomSeparator);
    final symptoms = await ref.read(symptomsRepositoryProvider).get();

    return SymptomsState(symptoms: symptoms, selected: selected);
  }

  void toggleSymptom(String symptom) {
    if (state.asData!.value.selected.contains(symptom)) {
      state = AsyncData(
        state.asData!.value.copyWith(
          selected: state.asData!.value.selected
              .where((element) => element != symptom)
              .toList(),
        ),
      );
    } else {
      state = AsyncData(
        state.asData!.value.copyWith(
          selected: [...state.asData!.value.selected, symptom],
        ),
      );
    }
  }
}

final symptomsStateProvider = AutoDisposeAsyncNotifierProviderFamily<
    SymptomsStateProvider, SymptomsState, String>(
  SymptomsStateProvider.new,
);
