/**
 * Same email pattern the driver/parent mobile app uses for its own profile
 * forms, so admin-entered emails are held to the same standard.
 */
const EMAIL_PATTERN = /^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/;

/** Digits only (spaces/dashes/parentheses stripped), optional leading +, 9-15 digits. */
const PHONE_PATTERN = /^\+?\d{9,15}$/;

export function isValidEmail(value: string): boolean {
  return EMAIL_PATTERN.test(value.trim());
}

export function isValidPhone(value: string): boolean {
  const stripped = value.trim().replace(/[\s()-]/g, '');
  return PHONE_PATTERN.test(stripped);
}
