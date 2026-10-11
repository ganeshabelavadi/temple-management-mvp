import { describe, expect, it } from "vitest";
import { validateJournalLines } from "./accounting";

describe("double-entry journal validation", () => {
  it("accepts a balanced ₹501 cash seva payment", () => {
    expect(validateJournalLines([
      { accountId: "cash", debitPaise: 50100, creditPaise: 0 },
      { accountId: "seva-income", debitPaise: 0, creditPaise: 50100 }
    ])).toMatchObject({ valid: true, debitPaise: 50100, creditPaise: 50100 });
  });

  it("rejects an unbalanced journal", () => {
    expect(validateJournalLines([
      { accountId: "cash", debitPaise: 50100, creditPaise: 0 },
      { accountId: "seva-income", debitPaise: 0, creditPaise: 50000 }
    ]).valid).toBe(false);
  });

  it("rejects a line with both debit and credit", () => {
    expect(validateJournalLines([
      { accountId: "cash", debitPaise: 100, creditPaise: 100 },
      { accountId: "income", debitPaise: 0, creditPaise: 100 }
    ]).valid).toBe(false);
  });

  it("rejects a single-line journal", () => {
    expect(validateJournalLines([{ accountId: "cash", debitPaise: 100, creditPaise: 0 }]).valid).toBe(false);
  });

  it("rejects floating-point amounts", () => {
    expect(validateJournalLines([
      { accountId: "cash", debitPaise: 10.5, creditPaise: 0 },
      { accountId: "income", debitPaise: 0, creditPaise: 10.5 }
    ]).valid).toBe(false);
  });
});
