import { AfterViewInit, Component, ElementRef, ViewChild, signal } from '@angular/core';
import { Router } from '@angular/router';
import { environment } from '../../../environments/environment';
import { AuthService } from '../../core/auth.service';

@Component({
  selector: 'app-login',
  templateUrl: './login.component.html',
  styleUrl: './login.component.scss'
})
export class LoginComponent implements AfterViewInit {
  @ViewChild('googleButton') googleButton?: ElementRef<HTMLDivElement>;
  readonly error = signal('');
  readonly busy = signal(false);

  constructor(
    private readonly auth: AuthService,
    private readonly router: Router
  ) {}

  ngAfterViewInit(): void {
    if (this.auth.isLoggedIn()) {
      void this.router.navigateByUrl('/upload');
      return;
    }
    this.renderGoogleButton(0);
  }

  private renderGoogleButton(attempt: number): void {
    const google = window.google?.accounts?.id;
    const element = this.googleButton?.nativeElement;

    if (!google || !element) {
      if (attempt < 30) setTimeout(() => this.renderGoogleButton(attempt + 1), 150);
      else this.error.set('Google Sign-In script could not be loaded.');
      return;
    }

    if (environment.googleClientId.startsWith('YOUR_')) {
      this.error.set('Set your Google Web Client ID in src/environments/environment.ts first.');
      return;
    }

    google.initialize({
      client_id: environment.googleClientId,
      callback: response => this.handleCredential(response.credential)
    });

    google.renderButton(element, {
      theme: 'outline',
      size: 'large',
      shape: 'pill',
      text: 'signin_with',
      width: 280
    });
  }

  private handleCredential(credential: string): void {
    this.busy.set(true);
    this.error.set('');

    try {
      this.auth.loginWithGoogleCredential(credential);
      void this.router.navigateByUrl('/upload');
    } catch (error) {
      this.busy.set(false);
      this.error.set(error instanceof Error ? error.message : 'Google login failed.');
    }
  }
}
