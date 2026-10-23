import { Component, inject, signal } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { ThemeService } from './services/theme.service';

@Component({
  selector: 'app-root',
  imports: [RouterOutlet],
  templateUrl: './app.html',
  styleUrl: './app.scss'
})
export class App {
  // Injecting applies the saved/system theme immediately on bootstrap,
  // before any route (including login) renders.
  private themeService = inject(ThemeService);
  protected readonly title = signal('login-app');
}
