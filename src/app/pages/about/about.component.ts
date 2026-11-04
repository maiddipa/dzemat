import {
  Component
} from '@angular/core';

import {
  CommonModule
} from '@angular/common';

@Component({
  selector: 'app-about',
  standalone: true,
  imports: [
    CommonModule
  ],
  templateUrl: './about.component.html',
  styleUrl: './about.component.css'
})
export class AboutComponent {

  readonly mosque = {
    name: 'Džemat Bochum',
    description:
      'Džemat Bochum okuplja muslimane iz Bochuma i okoline. '
      + 'Organizujemo namaze, mektebsku nastavu, predavanja, '
      + 'druženja i humanitarne aktivnosti.',

    address: 'Primjerstraße 10, 44787 Bochum',
    phone: '+49 123 4567890',
    email: 'info@dzemat-bochum.de',
    website: 'https://dzemat-bochum.de',

    facebook:
      'https://www.facebook.com/',

    instagram:
      'https://www.instagram.com/',

    paypal:
      'https://www.paypal.com/donate'
  };

  readonly activities: string[] = [
    'Dnevni namazi',
    'Džuma-namaz',
    'Mektebska nastava',
    'Predavanja',
    'Druženja',
    'Humanitarne aktivnosti'
  ];

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
    this.openLink(
      this.mosque.paypal
    );
  }
}