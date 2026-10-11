import { z } from "zod";

export const bookingRequestSchema = z.object({
  sevaId: z.string().uuid(),
  bookingDate: z.string().regex(/^\d{4}-\d{2}-\d{2}$/, "Use YYYY-MM-DD"),
  devoteeName: z.string().trim().min(2).max(120),
  phone: z.string().trim().min(8).max(20),
  email: z.string().trim().email().optional().or(z.literal("")),
  gothra: z.string().trim().max(100).optional(),
  nakshatra: z.string().trim().max(100).optional(),
  locale: z.enum(["en", "kn"]).default("en")
});

export type BookingRequest = z.infer<typeof bookingRequestSchema>;
