/** Store all amounts as integer paise; never use floating-point for money. */
export function rupeesToPaise(rupees: number): number {
  if (!Number.isFinite(rupees) || rupees < 0) throw new Error("Amount must be a non-negative finite number");
  return Math.round(rupees * 100);
}

export function formatINR(paise: number, locale = "en-IN"): string {
  if (!Number.isSafeInteger(paise)) throw new Error("Amount must be integer paise");
  return new Intl.NumberFormat(locale, { style: "currency", currency: "INR" }).format(paise / 100);
}
