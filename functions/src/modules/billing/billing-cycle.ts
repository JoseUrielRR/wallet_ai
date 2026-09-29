export interface UserCardData {
  id: string;
  userId: string;
  statementClosingDay: number;
  paymentDueDay: number;
  daysBetweenCutoffAndDue?: number;
  adjustForHolidays?: boolean;
}

export function isLeapYear(year: number): boolean {
  if (year % 400 === 0) return true;
  if (year % 100 === 0) return false;
  return year % 4 === 0;
}

export function getDaysInMonth(year: number, month: number): number {
  switch (month) {
    case 1: case 3: case 5: case 7: case 8: case 10: case 12:
      return 31;
    case 4: case 6: case 9: case 11:
      return 30;
    case 2:
      return isLeapYear(year) ? 29 : 28;
    default:
      throw new Error(`Invalid month: ${month}`);
  }
}

export function createNormalizedDate(year: number, month: number, targetDay: number): Date {
  const maxDays = getDaysInMonth(year, month);
  const day = Math.min(targetDay, maxDays);
  return new Date(Date.UTC(year, month - 1, day));
}

export function adjustForWeekend(date: Date): Date {
  const dayOfWeek = date.getUTCDay(); // 0 is Sunday, 6 is Saturday
  const adjusted = new Date(date.getTime());
  if (dayOfWeek === 6) {
    adjusted.setUTCDate(adjusted.getUTCDate() + 2);
  } else if (dayOfWeek === 0) {
    adjusted.setUTCDate(adjusted.getUTCDate() + 1);
  }
  return adjusted;
}
