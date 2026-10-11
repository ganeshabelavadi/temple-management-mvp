import { describe, expect, it } from "vitest";
import { bookingRequestSchema } from "./booking";

describe("booking request validation", () => {
  it("accepts a well-formed booking request", () => {
    const result = bookingRequestSchema.safeParse({
      sevaId: "e4eaaaf2-d142-4f03-9e2a-123456789abc",
      bookingDate: "2026-11-01",
      devoteeName: "Example Devotee",
      phone: "+919876543210",
      email: "devotee@example.com",
      locale: "kn"
    });
    expect(result.success).toBe(true);
  });

  it("rejects invalid UUID and missing devotee name", () => {
    const result = bookingRequestSchema.safeParse({
      sevaId: "not-a-uuid",
      bookingDate: "2026-11-01",
      devoteeName: "",
      phone: "12345678"
    });
    expect(result.success).toBe(false);
  });
});
