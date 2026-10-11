export type JournalLineInput = {
  accountId: string;
  debitPaise: number;
  creditPaise: number;
};

export function validateJournalLines(lines: JournalLineInput[]): { valid: boolean; debitPaise: number; creditPaise: number; reason?: string } {
  if (lines.length < 2) return { valid: false, debitPaise: 0, creditPaise: 0, reason: "A journal needs at least two lines" };
  let debitPaise = 0;
  let creditPaise = 0;

  for (const line of lines) {
    if (!line.accountId) return { valid: false, debitPaise, creditPaise, reason: "Every line needs an account" };
    if (!Number.isSafeInteger(line.debitPaise) || !Number.isSafeInteger(line.creditPaise)) {
      return { valid: false, debitPaise, creditPaise, reason: "Amounts must be integer paise" };
    }
    if (line.debitPaise < 0 || line.creditPaise < 0) {
      return { valid: false, debitPaise, creditPaise, reason: "Amounts cannot be negative" };
    }
    if ((line.debitPaise > 0) === (line.creditPaise > 0)) {
      return { valid: false, debitPaise, creditPaise, reason: "Each line must have either debit or credit, not both or neither" };
    }
    debitPaise += line.debitPaise;
    creditPaise += line.creditPaise;
    if (!Number.isSafeInteger(debitPaise) || !Number.isSafeInteger(creditPaise)) {
      return { valid: false, debitPaise, creditPaise, reason: "Journal total exceeds safe integer range" };
    }
  }

  if (debitPaise <= 0 || debitPaise !== creditPaise) {
    return { valid: false, debitPaise, creditPaise, reason: "Debit and credit totals must be equal and greater than zero" };
  }
  return { valid: true, debitPaise, creditPaise };
}
