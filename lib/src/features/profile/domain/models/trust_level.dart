enum TrustLevel {
  newcomer,
  member,
  trusted,
  veteran;

  bool get isLowTrust => this == TrustLevel.newcomer;

  static TrustLevel fromString(String? value) {
    if (value == null) return TrustLevel.newcomer;
    switch (value.toLowerCase()) {
      case 'member':
        return TrustLevel.member;
      case 'trusted':
        return TrustLevel.trusted;
      case 'veteran':
        return TrustLevel.veteran;
      case 'newcomer':
      default:
        return TrustLevel.newcomer;
    }
  }

  String toJson() => name;
}
