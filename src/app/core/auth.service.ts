import { Injectable, computed, signal } from '@angular/core';
import { environment } from '../../environments/environment';
import { AppUser } from './models';

interface GoogleIdTokenPayload {
  sub?: string;
  name?: string;
  email?: string;
  picture?: string;
  aud?: string;
  exp?: number;
}

@Injectable({ providedIn: 'root' })
export class AuthService {
  private readonly userKey = 'photowall_google_user';

  readonly user = signal<AppUser | null>(this.readUser());
  readonly isLoggedIn = computed(() => !!this.user());

  loginWithGoogleCredential(credential: string): AppUser {
    const payload = this.decodeJwtPayload<GoogleIdTokenPayload>(credential);

    if (!payload.sub || !payload.email) {
      throw new Error('Google did not return the expected account information.');
    }

    // Client-side checks improve UX, but they are not a substitute for
    // cryptographic server-side verification of the Google ID token.
    if (payload.aud && payload.aud !== environment.googleClientId) {
      throw new Error('This Google credential was issued for a different application.');
    }

    if (payload.exp && payload.exp * 1000 <= Date.now()) {
      throw new Error('The Google credential has expired. Please sign in again.');
    }

    const user: AppUser = {
      id: payload.sub,
      name: payload.name || payload.email,
      email: payload.email,
      picture: payload.picture || null
    };

    localStorage.setItem(this.userKey, JSON.stringify(user));
    this.user.set(user);
    return user;
  }

  logout(): void {
    localStorage.removeItem(this.userKey);
    this.user.set(null);
    window.google?.accounts?.id?.disableAutoSelect?.();
  }

  private readUser(): AppUser | null {
    const value = localStorage.getItem(this.userKey);
    if (!value) return null;

    try {
      return JSON.parse(value) as AppUser;
    } catch {
      localStorage.removeItem(this.userKey);
      return null;
    }
  }

  private decodeJwtPayload<T>(token: string): T {
    const parts = token.split('.');
    if (parts.length !== 3) throw new Error('Invalid Google credential.');

    const base64Url = parts[1];
    const base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/');
    const padded = base64.padEnd(Math.ceil(base64.length / 4) * 4, '=');

    try {
      const binary = atob(padded);
      const bytes = Uint8Array.from(binary, char => char.charCodeAt(0));
      const json = new TextDecoder().decode(bytes);
      return JSON.parse(json) as T;
    } catch {
      throw new Error('Could not read the Google credential.');
    }
  }
}
