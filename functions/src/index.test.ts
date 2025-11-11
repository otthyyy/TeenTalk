import {
  TRUST_SCORE_CONFIG,
  calculateTrustLevel,
  clampScore,
  applyTrustScoreDelta,
} from "./functions/trustScore";

describe("Trust Score Utilities", () => {
  it("calculates trust levels for key thresholds", () => {
    expect(calculateTrustLevel(0)).toBe("newcomer");
    expect(calculateTrustLevel(TRUST_SCORE_CONFIG.NEWCOMER_MAX)).toBe("newcomer");
    expect(calculateTrustLevel(TRUST_SCORE_CONFIG.NEWCOMER_MAX + 1)).toBe("member");
    expect(calculateTrustLevel(TRUST_SCORE_CONFIG.MEMBER_MAX)).toBe("member");
    expect(calculateTrustLevel(TRUST_SCORE_CONFIG.MEMBER_MAX + 1)).toBe("trusted");
    expect(calculateTrustLevel(TRUST_SCORE_CONFIG.TRUSTED_MAX)).toBe("trusted");
    expect(calculateTrustLevel(TRUST_SCORE_CONFIG.TRUSTED_MAX + 1)).toBe("veteran");
    expect(calculateTrustLevel(TRUST_SCORE_CONFIG.MAX_SCORE)).toBe("veteran");
  });

  it("clamps scores within 0-100", () => {
    expect(clampScore(-10)).toBe(TRUST_SCORE_CONFIG.MIN_SCORE);
    expect(clampScore(0)).toBe(0);
    expect(clampScore(50)).toBe(50);
    expect(clampScore(100)).toBe(100);
    expect(clampScore(150)).toBe(TRUST_SCORE_CONFIG.MAX_SCORE);
  });

  it("applies positive deltas and updates levels", () => {
    const result = applyTrustScoreDelta(48, TRUST_SCORE_CONFIG.POST_APPROVED);
    expect(result.previousScore).toBe(48);
    expect(result.previousLevel).toBe("member");
    expect(result.newScore).toBe(50);
    expect(result.newLevel).toBe("member");
  });

  it("applies negative deltas and updates levels", () => {
    const result = applyTrustScoreDelta(42, TRUST_SCORE_CONFIG.POST_FLAGGED);
    expect(result.previousScore).toBe(42);
    expect(result.previousLevel).toBe("member");
    expect(result.newScore).toBe(37);
    expect(result.newLevel).toBe("newcomer");
  });

  it("clamps high deltas at maximum score", () => {
    const result = applyTrustScoreDelta(98, 10);
    expect(result.newScore).toBe(TRUST_SCORE_CONFIG.MAX_SCORE);
    expect(result.newLevel).toBe("veteran");
  });

  it("clamps negative deltas at minimum score", () => {
    const result = applyTrustScoreDelta(2, -10);
    expect(result.newScore).toBe(TRUST_SCORE_CONFIG.MIN_SCORE);
    expect(result.newLevel).toBe("newcomer");
  });

  it("exposes consistent configuration", () => {
    expect(TRUST_SCORE_CONFIG.INITIAL_SCORE).toBeGreaterThanOrEqual(TRUST_SCORE_CONFIG.MIN_SCORE);
    expect(TRUST_SCORE_CONFIG.INITIAL_SCORE).toBeLessThanOrEqual(TRUST_SCORE_CONFIG.MAX_SCORE);
    expect(TRUST_SCORE_CONFIG.NEWCOMER_MAX).toBeLessThan(TRUST_SCORE_CONFIG.MEMBER_MAX);
    expect(TRUST_SCORE_CONFIG.MEMBER_MAX).toBeLessThan(TRUST_SCORE_CONFIG.TRUSTED_MAX);
    expect(TRUST_SCORE_CONFIG.TRUSTED_MAX).toBeLessThan(TRUST_SCORE_CONFIG.MAX_SCORE);
  });
});
