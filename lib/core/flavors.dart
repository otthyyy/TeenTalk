enum Flavor {
  dev,
  prod,
}

extension FlavorExtension on Flavor {
  String get name {
    switch (this) {
      case Flavor.dev:
        return 'DEV';
      case Flavor.prod:
        return 'PROD';
    }
  }

  String get firebaseProjectId {
    switch (this) {
      case Flavor.dev:
        return 'dev-firebase-app';
      case Flavor.prod:
        return 'prod-firebase-app';
    }
  }

  bool get isDevelopment => this == Flavor.dev;
  bool get isProduction => this == Flavor.prod;
}

class FlavorConfig {
  static Flavor _flavor = Flavor.dev;
  
  static Flavor get flavor => _flavor;
  
  static void initialize(Flavor flavor) {
    _flavor = flavor;
  }
}