import { Component, inject } from '@angular/core';
import { DzematI18nService } from './shared/dzemat-i18n.service';
import { LanguageSwitcherComponent } from './shared/language-switcher.component';
import { RouterLink, RouterOutlet } from '@angular/router';
import { AuthService } from './core/auth.service';

@Component({
  selector: 'app-root',
  imports: [RouterOutlet, RouterLink, LanguageSwitcherComponent],
  templateUrl: './app.component.html',
  styleUrl: './app.component.css'
})
export class AppComponent {
  readonly i18n=inject(DzematI18nService);
  constructor(readonly auth: AuthService) {}
}
