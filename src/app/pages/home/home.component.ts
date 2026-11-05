import { DzematI18nService } from '../../shared/dzemat-i18n.service';
import {
  ChangeDetectorRef,
  Component,
  HostListener,
  OnDestroy,
  OnInit
} from '@angular/core';

import {
  CommonModule
} from '@angular/common';

import {
  HttpClient
} from '@angular/common/http';

import {
  catchError,
  finalize,
  map,
  of,
  take
} from 'rxjs';

import {
  Photo,
  PhotoService
} from '../../core/photo.service';

interface Gallery {
  name: string;
  tag: string;
}

interface GalleryObject {
  name?: string;
  tag?: string;
}

type GalleryItem =
  | string
  | GalleryObject;

type GalleriesResponse =
  | GalleryItem[]
  | {
      galleries?: GalleryItem[];
    };

@Component({
  selector: 'app-home',
  standalone: true,

  imports: [
    CommonModule
  ],

  templateUrl: './home.component.html',
  styleUrl: './home.component.css'
})
export class HomeComponent
  implements OnInit, OnDestroy {

  photos: Photo[] = [];
  galleries: Gallery[] = [];

  selectedTag = '';
  selectedPhoto: Photo | null = null;

  currentIndex = 0;

  loadingGalleries = false;
  loadingPhotos = false;

  errorMessage = '';

  private readonly galleriesJsonUrl =
    'https://res.cloudinary.com/dgyy4rc34/raw/upload/v1790158917/dg9t9evbpzgdis4kmgnu.json';

  constructor(
    private readonly http: HttpClient,
    private readonly photoService: PhotoService,
    private readonly changeDetector: ChangeDetectorRef,
    readonly i18n: DzematI18nService
  ) {}

  ngOnInit(): void {
    this.loadGalleries();
  }

  ngOnDestroy(): void {
    document.body.style.overflow = '';
  }

  get loading(): boolean {
    return (
      this.loadingGalleries ||
      this.loadingPhotos
    );
  }

  get currentPhoto(): Photo | null {
    if (this.photos.length === 0) {
      return null;
    }

    if (
      this.currentIndex < 0 ||
      this.currentIndex >=
        this.photos.length
    ) {
      this.currentIndex = 0;
    }

    return this.photos[
      this.currentIndex
    ];
  }

  /*
   * Učitava galerije iz Cloudinary JSON fajla.
   */
  loadGalleries(): void {
    this.loadingGalleries = true;
    this.errorMessage = '';

    const url =
      `${this.galleriesJsonUrl}` +
      `?refresh=${Date.now()}`;

    console.log(
      'Učitavam galleries JSON:',
      url
    );

    this.http
      .get<GalleriesResponse>(url)
      .pipe(
        take(1),

        map(response => {
          const items: GalleryItem[] =
            Array.isArray(response)
              ? response
              : response.galleries ?? [];

          return items
            .map(item =>
              this.convertGallery(item)
            )
            .filter(
              (gallery): gallery is Gallery =>
                gallery !== null
            );
        }),

        catchError(error => {
          console.error(
            'Greška pri učitavanju JSON-a:',
            error
          );

          this.errorMessage =
            'Lista galerija se nije mogla učitati.';

          return of([] as Gallery[]);
        }),

        finalize(() => {
          this.loadingGalleries = false;
          this.changeDetector.detectChanges();
        })
      )
      .subscribe(galleries => {
        this.galleries = galleries;

        console.log(
          'Učitane galerije:',
          this.galleries
        );

        if (
          this.galleries.length === 0
        ) {
          this.photos = [];
          this.currentIndex = 0;

          if (!this.errorMessage) {
            this.errorMessage =
              'JSON ne sadrži galerije.';
          }

          this.changeDetector.detectChanges();
          return;
        }

        const selectedExists =
          this.galleries.some(
            gallery =>
              gallery.tag ===
              this.selectedTag
          );

        if (!selectedExists) {
          this.selectedTag =
            this.galleries[0].tag;
        }

        this.changeDetector.detectChanges();
        this.loadPhotos();
      });
  }

  private convertGallery(
    item: GalleryItem
  ): Gallery | null {
    if (typeof item === 'string') {
      const tag =
        item.trim();

      if (!tag) {
        return null;
      }

      return {
        name: tag,
        tag
      };
    }

    const tag =
      (item.tag ?? '').trim();

    if (!tag) {
      return null;
    }

    const name =
      (item.name ?? tag).trim();

    return {
      name,
      tag
    };
  }

  /*
   * Promjena galerije.
   */
  selectGallery(event: Event): void {
    const select =
      event.target as HTMLSelectElement;

    this.selectedTag =
      (select.value ?? '').trim();

    this.currentIndex = 0;
    this.selectedPhoto = null;

    console.log(
      'Izabrana galerija:',
      this.selectedTag
    );

    this.loadPhotos();
  }

  /*
   * Učitava slike prema Cloudinary tagu.
   */
  loadPhotos(): void {
    const tag =
      (this.selectedTag ?? '').trim();

    if (!tag) {
      this.photos = [];
      this.currentIndex = 0;
      this.loadingPhotos = false;

      this.errorMessage =
        'Galerija nije izabrana.';

      this.changeDetector.detectChanges();
      return;
    }

    this.loadingPhotos = true;
    this.errorMessage = '';

    this.photos = [];
    this.currentIndex = 0;

    this.changeDetector.detectChanges();

    console.log(
      'HOME: učitavam tag:',
      tag
    );

    this.photoService
      .getPhotosByTag(tag)
      .pipe(
        take(1),

        finalize(() => {
          this.loadingPhotos = false;
          this.changeDetector.detectChanges();

          console.log(
            'HOME: učitavanje završeno'
          );
        })
      )
      .subscribe({
        next: photos => {
          this.photos =
            photos ?? [];

          this.currentIndex = 0;

          console.log(
            'HOME: primljene slike:',
            this.photos
          );

          if (
            this.photos.length === 0
          ) {
            this.errorMessage =
              `Galerija "${tag}" nema slika.`;
          }

          this.changeDetector.detectChanges();
        },

        error: error => {
          console.error(
            'Greška pri učitavanju slika:',
            error
          );

          this.photos = [];
          this.currentIndex = 0;

          this.errorMessage =
            'Slike se nisu mogle učitati.';

          this.changeDetector.detectChanges();
        }
      });
  }

  /*
   * Prethodna slika.
   */
  previousPhoto(): void {
    if (
      this.photos.length === 0
    ) {
      return;
    }

    this.currentIndex =
      this.currentIndex === 0
        ? this.photos.length - 1
        : this.currentIndex - 1;

    this.updateOpenedPhoto();
  }

  /*
   * Sljedeća slika.
   */
  nextPhoto(): void {
    if (
      this.photos.length === 0
    ) {
      return;
    }

    this.currentIndex =
      this.currentIndex ===
      this.photos.length - 1
        ? 0
        : this.currentIndex + 1;

    this.updateOpenedPhoto();
  }

  goToPhoto(index: number): void {
    if (
      index < 0 ||
      index >= this.photos.length
    ) {
      return;
    }

    this.currentIndex = index;
    this.updateOpenedPhoto();
  }

  openPhoto(photo: Photo): void {
    const photoIndex =
      this.photos.findIndex(
        item =>
          item.publicId ===
          photo.publicId
      );

    if (photoIndex >= 0) {
      this.currentIndex =
        photoIndex;
    }

    this.selectedPhoto =
      photo;

    document.body.style.overflow =
      'hidden';
  }

  closePhoto(): void {
    this.selectedPhoto = null;

    document.body.style.overflow =
      '';
  }

  private updateOpenedPhoto(): void {
    if (
      this.selectedPhoto &&
      this.currentPhoto
    ) {
      this.selectedPhoto =
        this.currentPhoto;
    }
  }

  /*
   * Uklanja f_auto,q_auto kako bi modal
   * koristio originalnu sliku.
   */
  getFullSizeUrl(url: string): string {
    return url.replace(
      '/image/upload/f_auto,q_auto/',
      '/image/upload/'
    );
  }

  reloadAll(): void {
    this.loadGalleries();
  }

  reloadPhotos(): void {
    this.loadPhotos();
  }

  imageError(event: Event): void {
    const image =
      event.target as HTMLImageElement;

    console.error(
      'Slika se nije mogla prikazati:',
      image.src
    );
  }

  trackGallery(
    index: number,
    gallery: Gallery
  ): string {
    return gallery.tag;
  }

  trackPhoto(
    index: number,
    photo: Photo
  ): string {
    return photo.publicId;
  }

  /*
   * Escape zatvara veliku sliku.
   * Strelice mijenjaju slike.
   */
  @HostListener(
    'document:keydown',
    ['$event']
  )
  handleKeyboard(
    event: KeyboardEvent
  ): void {
    if (event.key === 'Escape') {
      this.closePhoto();
      return;
    }

    if (event.key === 'ArrowLeft') {
      this.previousPhoto();
    }

    if (event.key === 'ArrowRight') {
      this.nextPhoto();
    }
  }
}