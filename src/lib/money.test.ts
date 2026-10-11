import { describe, expect, it } from "vitest";
import { formatINR, rupeesToPaise } from "./money";

describe("money helpers", () => {
  it("converts rupees to integer paise", () => {
    expect(rupeesToPaise(501)).toBe(50100);
    expect(rupeesToPaise(12.34)).toBe(1234);
  });
  it("rejects negative amounts", () => {
    expect(() => rupeesToPaise(-1)).toThrow();
  });
  it("rejects invalid rupee values", () => {
    expect(() => rupeesToPaise(Number.NaN)).toThrow();
  });
  it("formats an INR amount", () => {
    expect(formatINR(50100)).toContain("501");
  });
});
