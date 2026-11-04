import {
  Component,
  OnDestroy,
  OnInit,
  signal
} from '@angular/core';

import {
  CommonModule
} from '@angular/common';

import {
  FormsModule
} from '@angular/forms';

import {
  HttpClient
} from '@angular/common/http';

import {
  catchError,
  finalize,
  forkJoin,
  map,
  of,
  switchMap,
  take
} from 'rxjs';

import {
  PhotoService
} from '../../core/photo.service';

import {
  environment
} from '../../../environments/environment';

interface Gallery {
  name: string;
  tag: string;
}

interface GalleryJsonObject {
  name?: string;
  tag?: string;
}

type GalleryJsonItem =
  | string
  | GalleryJsonObject;

type GalleriesJsonResponse =
  | GalleryJsonItem[]
  | {
      galleries?: GalleryJsonItem[];
    };

interface WorkerResponse {
  success: boolean;
  galleries?: Gallery[];
  cloudinaryUrl?: string;
  error?: string;
}

@Component({
  selector: 'app-upload',
  standalone: true,

  imports: [
    CommonModule,
    FormsModule
  ],

  templateUrl: './upload.component.html',
  styleUrl: './upload.component.scss'
})
export class UploadComponent
  implements OnInit, OnDestroy {

  readonly busy =
    signal(false);

  readonly error =
    signal('');

  readonly success =
    signal('');

  readonly previewUrls =
    signal<string[]>([]);

  readonly selectedFiles =
    signal<File[]>([]);

  caption = '';
  newFolderName = '';
  selectedFolder = '';

  /*
   * Token se unosi u password polje.
   * Ne upisivati stvarni token u TypeScript.
   */
  updateToken = '';

  folders: string[] = [];

  user: any = null;

  private readonly galleriesJsonUrl =
    'https://res.cloudinary.com/dgyy4rc34/raw/upload/v1790158917/dg9t9evbpzgdis4kmgnu.json';

  private readonly galleryWorkerUrl =
    'https://dzemat.mdipa1991.workers.dev/';

  constructor(
    private readonly photos: PhotoService,
    private readonly http: HttpClient
  ) {}

  ngOnInit(): void {
    this.loadFolders();
  }

  ngOnDestroy(): void {
    this.clearPreviewUrls();
  }

  /*
   * Učitava foldere iz Cloudinary JSON-a.
   */
  loadFolders(): void {
    const url =
      `${this.galleriesJsonUrl}` +
      `?refresh=${Date.now()}`;

    console.log(
      'Učitavam foldere:',
      url
    );

    this.http
      .get<GalleriesJsonResponse>(url)
      .pipe(
        take(1),

        map(response => {
          const items =
            Array.isArray(response)
              ? response
              : response.galleries ?? [];

          return items
            .map(item => {
              if (
                typeof item === 'string'
              ) {
                return item.trim();
              }

              return (
                item.tag ??
                item.name ??
                ''
              ).trim();
            })
            .filter(folder =>
              folder.length > 0
            );
        }),

        catchError(loadError => {
          console.error(
            'Could not load folders:',
            loadError
          );

          return of([] as string[]);
        })
      )
      .subscribe(folders => {
        this.folders =
          this.removeDuplicates(folders);

        const defaultFolder =
          environment.cloudinary.defaultFolder ||
          'Galerija';

        if (
          this.folders.length === 0
        ) {
          this.folders = [
            defaultFolder
          ];
        }

        if (
          !this.selectedFolder ||
          !this.folders.includes(
            this.selectedFolder
          )
        ) {
          this.selectedFolder =
            this.folders[0];
        }

        console.log(
          'Dostupni folderi:',
          this.folders
        );
      });
  }

  /*
   * Novi folder se odmah prikazuje lokalno.
   * U Cloudinary JSON ulazi nakon uploada.
   */
  createFolder(): void {
    const folder =
      this.newFolderName.trim();

    if (!folder) {
      this.error.set(
        'Unesite naziv foldera.'
      );

      return;
    }

    const existingFolder =
      this.folders.find(
        item =>
          item.toLowerCase() ===
          folder.toLowerCase()
      );

    if (existingFolder) {
      this.selectedFolder =
        existingFolder;
    } else {
      this.folders =
        this.moveFolderToBeginning(
          this.folders,
          folder
        );

      this.selectedFolder =
        folder;
    }

    this.newFolderName = '';
    this.error.set('');
    this.success.set('');
  }

  /*
   * Uklanja folder samo iz trenutne liste.
   * Ne briše slike iz Cloudinaryja.
   */
  deleteFolder(folder: string): void {
    if (
      folder.toLowerCase() ===
      'novosti'
    ) {
      this.error.set(
        'Novosti se ne mogu ukloniti.'
      );

      return;
    }

    const defaultFolder =
      environment.cloudinary.defaultFolder ||
      'Galerija';

    if (
      folder === defaultFolder
    ) {
      this.error.set(
        'Glavna galerija se ne može ukloniti.'
      );

      return;
    }

    this.folders =
      this.folders.filter(
        item =>
          item !== folder
      );

    if (
      this.selectedFolder === folder
    ) {
      this.selectedFolder =
        this.folders[0] ??
        defaultFolder;
    }

    this.error.set('');
  }

  /*
   * Izbor više slika.
   */
  onFileSelected(event: Event): void {
    const input =
      event.target as HTMLInputElement;

    const files =
      Array.from(
        input.files ?? []
      );

    this.error.set('');
    this.success.set('');

    this.clearPreviewUrls();

    if (files.length === 0) {
      this.selectedFiles.set([]);
      return;
    }

    const maxFileSize =
      8 * 1024 * 1024;

    const invalidType =
      files.find(
        file =>
          !file.type.startsWith(
            'image/'
          )
      );

    if (invalidType) {
      this.error.set(
        `"${invalidType.name}" nije slika.`
      );

      this.selectedFiles.set([]);
      input.value = '';
      return;
    }

    const tooLarge =
      files.find(
        file =>
          file.size > maxFileSize
      );

    if (tooLarge) {
      this.error.set(
        `"${tooLarge.name}" je veća od 8 MB.`
      );

      this.selectedFiles.set([]);
      input.value = '';
      return;
    }

    this.selectedFiles.set(files);

    const urls =
      files.map(file =>
        URL.createObjectURL(file)
      );

    this.previewUrls.set(urls);

    console.log(
      'Izabrane slike:',
      files
    );
  }

  /*
   * Uklanja jednu sliku prije uploada.
   */
  removeSelectedFile(index: number): void {
    const files = [
      ...this.selectedFiles()
    ];

    const urls = [
      ...this.previewUrls()
    ];

    const removedUrl =
      urls[index];

    if (removedUrl) {
      URL.revokeObjectURL(
        removedUrl
      );
    }

    files.splice(index, 1);
    urls.splice(index, 1);

    this.selectedFiles.set(files);
    this.previewUrls.set(urls);
  }

  /*
   * Uploaduje sve izabrane slike.
   */
  submit(): void {
    const files =
      this.selectedFiles();

    const folderName =
      this.selectedFolder.trim();

    const token =
      this.updateToken.trim();

    if (files.length === 0) {
      this.error.set(
        'Izaberite jednu ili više slika.'
      );

      return;
    }

    if (!folderName) {
      this.error.set(
        'Izaberite folder.'
      );

      return;
    }

    if (!token) {
      this.error.set(
        'Unesite administratorski UPDATE_TOKEN.'
      );

      return;
    }

    this.busy.set(true);
    this.error.set('');
    this.success.set('');

    const userName =
      this.getUserName();

    console.log(
      '=========================='
    );

    console.log(
      'MULTIPLE UPLOAD'
    );

    console.log(
      'Broj slika:',
      files.length
    );

    console.log(
      'Folder:',
      folderName
    );

    console.log(
      '=========================='
    );

    const uploadRequests =
      files.map(file =>
        this.photos.upload(
          file,
          this.caption,
          userName,
          folderName
        )
      );

    forkJoin(uploadRequests)
      .pipe(
        /*
         * Nakon svih slika,
         * Worker ažurira JSON samo jednom.
         */
        switchMap(
          uploadedPhotos =>
            this.updateGalleryJson(
              folderName,
              token
            ).pipe(
              map(workerResponse => ({
                uploadedPhotos,
                workerResponse,
                jsonUpdated: true
              })),

              catchError(workerError => {
                console.error(
                  'JSON update failed:',
                  workerError
                );

                return of({
                  uploadedPhotos,
                  workerResponse: null,
                  jsonUpdated: false
                });
              })
            )
        ),

        finalize(() => {
          this.busy.set(false);
        })
      )
      .subscribe({
        next: result => {
          const uploadedCount =
            result.uploadedPhotos.length;

          if (result.jsonUpdated) {
            this.success.set(
              `${uploadedCount} slika je uploadovano. Lista galerija je ažurirana.`
            );

            this.folders =
              this.moveFolderToBeginning(
                this.folders,
                folderName
              );
          } else {
            this.error.set(
              `${uploadedCount} slika je uploadovano, ali JSON nije ažuriran.`
            );
          }

          this.caption = '';

          this.clearPreviewUrls();

          this.selectedFiles.set([]);

          window.setTimeout(
            () => this.loadFolders(),
            1000
          );
        },

        error: uploadError => {
          console.error(
            'Upload failed:',
            uploadError
          );

          this.error.set(
            'Jedna ili više slika nisu uploadovane.'
          );
        }
      });
  }

  private updateGalleryJson(
    folderName: string,
    token: string
  ) {
    return this.http.post<WorkerResponse>(
      this.galleryWorkerUrl,
      {
        name: folderName,
        tag: folderName
      },
      {
        headers: {
          Authorization:
            `Bearer ${token}`
        }
      }
    );
  }

  private getUserName(): string {
    if (
      typeof this.user === 'string'
    ) {
      return (
        this.user.trim() ||
        'Nepoznat korisnik'
      );
    }

    if (
      this.user &&
      typeof this.user === 'object'
    ) {
      return String(
        this.user.name ??
        this.user.displayName ??
        this.user.userName ??
        this.user.email ??
        'Nepoznat korisnik'
      );
    }

    return 'Nepoznat korisnik';
  }

  private clearPreviewUrls(): void {
    for (
      const url of
      this.previewUrls()
    ) {
      URL.revokeObjectURL(url);
    }

    this.previewUrls.set([]);
  }

  private removeDuplicates(
    folders: string[]
  ): string[] {
    const result: string[] = [];

    for (const folder of folders) {
      const exists =
        result.some(
          item =>
            item.toLowerCase() ===
            folder.toLowerCase()
        );

      if (!exists) {
        result.push(folder);
      }
    }

    return result;
  }

  /*
   * Novi folder ide na početak.
   * Maksimalno 10 foldera.
   * Novosti se nikada ne uklanjaju.
   */
  private moveFolderToBeginning(
    folders: string[],
    newFolder: string
  ): string[] {
    const updated =
      folders.filter(
        folder =>
          folder.toLowerCase() !==
          newFolder.toLowerCase()
      );

    updated.unshift(newFolder);

    while (updated.length > 10) {
      const removableIndex =
        this.findLastRemovableFolder(
          updated
        );

      if (removableIndex === -1) {
        break;
      }

      updated.splice(
        removableIndex,
        1
      );
    }

    return updated;
  }

  private findLastRemovableFolder(
    folders: string[]
  ): number {
    for (
      let index =
        folders.length - 1;

      index >= 0;

      index--
    ) {
      if (
        folders[index].toLowerCase() !==
        'novosti'
      ) {
        return index;
      }
    }

    return -1;
  }
}