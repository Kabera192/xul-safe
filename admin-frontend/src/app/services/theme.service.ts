import { Injectable, signal } from '@angular/core';

export type Theme = 'light' | 'dark';

const STORAGE_KEY = 'xusafe-theme';

/**
 * Applies a `dark-theme` class to <html>, which the global dark-theme
 * override block in styles.scss targets. Most page stylesheets hardcode
 * hex colors rather than the CSS variables in styles.scss, so this is a
 * class-name-targeted override layer rather than a variable swap — see
 * styles.scss for the actual color rules.
 */
@Injectable({ providedIn: 'root' })
export class ThemeService {
  readonly theme = signal<Theme>(this.loadInitial());

  constructor() {
    this.apply(this.theme());
  }

  toggle(): void {
    this.setTheme(this.theme() === 'dark' ? 'light' : 'dark');
  }

  setTheme(theme: Theme): void {
    this.theme.set(theme);
    this.apply(theme);
    try {
      localStorage.setItem(STORAGE_KEY, theme);
    } catch {
      // Private browsing / storage disabled — theme just won't persist.
    }
  }

  private apply(theme: Theme): void {
    document.documentElement.classList.toggle('dark-theme', theme === 'dark');
  }

  private loadInitial(): Theme {
    try {
      const stored = localStorage.getItem(STORAGE_KEY);
      if (stored === 'dark' || stored === 'light') {
        return stored;
      }
    } catch {
      // Private browsing / storage disabled — fall through to system preference.
    }
    return window.matchMedia?.('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
  }
}
