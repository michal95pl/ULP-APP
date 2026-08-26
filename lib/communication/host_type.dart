enum HostType {
  stage30('STAGE_3_0'),
  mobile25('MOBILE_2_5'),
  unknown('UNKNOWN');

  final String rawValue;
  const HostType(this.rawValue);

  bool get isStage => this == HostType.stage30;
  bool get isMobile => this == HostType.mobile25;

  static HostType fromString(String? value) {
    return HostType.values.firstWhere(
      (type) => type.rawValue == value,
      orElse: () => HostType.unknown,
    );
  }

  String get name {
    switch (this) {
      case HostType.stage30:
        return 'Stage 3.0';
      case HostType.mobile25:
        return 'Mobile 2.5';
      case HostType.unknown:
        return 'Unknown';
    }
  }

  
}