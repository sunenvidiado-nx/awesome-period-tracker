enum CyclePhase {
  menstruation,
  follicular,
  ovulation,
  luteal;

  CyclePhase get nextPhase => switch (this) {
        CyclePhase.menstruation => CyclePhase.follicular,
        CyclePhase.follicular => CyclePhase.ovulation,
        CyclePhase.ovulation => CyclePhase.luteal,
        CyclePhase.luteal => CyclePhase.menstruation,
      };
}
