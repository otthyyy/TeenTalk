import 'package:flutter_test/flutter_test.dart';
import 'package:teen_talk_app/src/features/profile/domain/models/trust_level.dart';

void main() {
  group('TrustLevel', () {
    test('fromString parses newcomer correctly', () {
      expect(TrustLevel.fromString('newcomer'), TrustLevel.newcomer);
      expect(TrustLevel.fromString('NEWCOMER'), TrustLevel.newcomer);
      expect(TrustLevel.fromString('Newcomer'), TrustLevel.newcomer);
    });

    test('fromString parses member correctly', () {
      expect(TrustLevel.fromString('member'), TrustLevel.member);
      expect(TrustLevel.fromString('MEMBER'), TrustLevel.member);
    });

    test('fromString parses trusted correctly', () {
      expect(TrustLevel.fromString('trusted'), TrustLevel.trusted);
      expect(TrustLevel.fromString('TRUSTED'), TrustLevel.trusted);
    });

    test('fromString parses veteran correctly', () {
      expect(TrustLevel.fromString('veteran'), TrustLevel.veteran);
      expect(TrustLevel.fromString('VETERAN'), TrustLevel.veteran);
    });

    test('fromString returns newcomer for null', () {
      expect(TrustLevel.fromString(null), TrustLevel.newcomer);
    });

    test('fromString returns newcomer for unknown value', () {
      expect(TrustLevel.fromString('unknown'), TrustLevel.newcomer);
      expect(TrustLevel.fromString(''), TrustLevel.newcomer);
    });

    test('toJson returns correct string', () {
      expect(TrustLevel.newcomer.toJson(), 'newcomer');
      expect(TrustLevel.member.toJson(), 'member');
      expect(TrustLevel.trusted.toJson(), 'trusted');
      expect(TrustLevel.veteran.toJson(), 'veteran');
    });

    test('isLowTrust returns true only for newcomer', () {
      expect(TrustLevel.newcomer.isLowTrust, true);
      expect(TrustLevel.member.isLowTrust, false);
      expect(TrustLevel.trusted.isLowTrust, false);
      expect(TrustLevel.veteran.isLowTrust, false);
    });
  });
}
