import { Component, inject } from '@angular/core';
import { DzematI18nService } from '../../shared/dzemat-i18n.service';
import { DzematContactsComponent } from '../../shared/contacts-section.component';

import {
  CommonModule
} from '@angular/common';

@Component({
  selector: 'app-about',
  standalone: true,
  imports: [
    CommonModule,
    DzematContactsComponent
  ],
  templateUrl: './about.component.html',
  styleUrl: './about.component.css'
})
export class AboutComponent {
  readonly i18n=inject(DzematI18nService);

  readonly mosque = {
    name: 'Džemat Bochum',
    description:
      'Džemat Bochum okuplja muslimane iz Bochuma i okoline. '
      + 'Organizujemo namaze, mektebsku nastavu, predavanja, '
      + 'druženja i humanitarne aktivnosti.',

    address: 'Hochstraße 92, 44866 Bochum',
    phone: '0177 7540425',
    email: 'ikc-bb@outlook.de',
    website: 'https://dzematbochum.de',

    facebook:
      'https://www.facebook.com/',

    instagram:
      'https://www.instagram.com/',

    paypal:
      'https://www.paypal.com/donate'
  };

  readonly activities = [
    'prayer', 'friday', 'school', 'talks', 'meetings', 'charity'
  ] as const;

  openLink(url: string): void {
    window.open(
      url,
      '_blank',
      'noopener,noreferrer'
    );
  }

  openEmail(): void {
    window.location.href =
      `mailto:${this.mosque.email}`;
  }

  openPhone(): void {
    const cleanPhone =
      this.mosque.phone.replace(
        /[^+\d]/g,
        ''
      );

    window.location.href =
      `tel:${cleanPhone}`;
  }

  openMap(): void {
    const address =
      encodeURIComponent(
        this.mosque.address
      );

    window.open(
      `https://www.google.com/maps/search/?api=1&query=${address}`,
      '_blank',
      'noopener,noreferrer'
    );
  }

  donate(): void {
    this.openEmail();
  }
}