import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';

import {
  Observable,
  catchError,
  map,
  of,
  tap,
  throwError
} from 'rxjs';

export interface Photo {
  publicId: string;
  url: string;
  caption: string;
  userName: string;
  folder: string;
  tags: string[];
  width?: number;
  height?: number;
  format?: string;
}

interface CloudinaryPhoto {
  public_id: string;

  /*
   * Upload odgovor sadrži secure_url,
   * ali JSON tag lista ga nekada ne sadrži.
   */
  secure_url?: string;

  version?: number;
  format?: string;
  width?: number;
  height?: number;
  folder?: string;
  tags?: string[];

  context?: {
    custom?: {
      caption?: string;
      userName?: string;
    };
  };
}

interface CloudinaryListResponse {
  resources?: CloudinaryPhoto[];
  updated_at?: string;
}

@Injectable({
  providedIn: 'root'
})
export class PhotoService {
  private readonly cloudName = 'dgyy4rc34';
  private readonly uploadPreset = 'Dzemat';

  private readonly uploadUrl =
    `https://api.cloudinary.com/v1_1/` +
    `${this.cloudName}/image/upload`;

  constructor(
    private readonly http: HttpClient
  ) {}

  /*
   * Uploaduje sliku.
   * Naziv foldera se koristi i kao tag.
   */
  upload(
    file: File,
    caption: string | null | undefined,
    userName: string | null | undefined,
    folder: string | null | undefined
  ): Observable<Photo> {
    const folderName =
      (folder ?? '').trim();

    const safeCaption =
      (caption ?? '').trim();

    const safeUserName =
      (userName ?? 'Nepoznat korisnik').trim();

    if (!file) {
      return throwError(
        () => new Error('Slika nije izabrana.')
      );
    }

    if (!folderName) {
      return throwError(
        () => new Error(
          'Naziv foldera nije unesen.'
        )
      );
    }

    const formData = new FormData();

    formData.append(
      'file',
      file
    );

    formData.append(
      'upload_preset',
      this.uploadPreset
    );

    // Cloudinary folder folder
    formData.append(
      'folder',
      folderName
    );

    // Naziv foldera automatski postaje tag
    formData.append(
      'tags',
      folderName
    );

    // Naslov i korisničko ime
    formData.append(
      'context',
      `caption=${safeCaption}` +
      `|userName=${safeUserName}`
    );

    console.log('==========================');
    console.log('CLOUDINARY UPLOAD');
    console.log('File:', file.name);
    console.log('Caption:', safeCaption);
    console.log('User:', safeUserName);
    console.log('Folder:', folderName);
    console.log('Tag:', folderName);
    console.log('==========================');

    return this.http
      .post<CloudinaryPhoto>(
        this.uploadUrl,
        formData
      )
      .pipe(
        tap(response => {
          console.log(
                     'Upload successful:',
          response
          );

          console.log(
            'Uploaded public ID:',
            response.public_id
          );

          console.log(
            'Uploaded tags:',
            response.tags
          );
        }),

        map(response =>
          this.convertCloudinaryPhoto(
            response,
            folderName,
            safeCaption,
            safeUserName
          )
        ),

        catchError(error => {
          console.error(
            'Cloudinary upload failed:',
            error
          );

          return throwError(() => error);
        })
      );
  }

  /*
   * Folder i tag imaju isti naziv.
   */
  getPhotosByFolder(
    folder: string | null | undefined
  ): Observable<Photo[]> {
    return this.getPhotosByTag(folder);
  }

  /*
   * Učitava slike prema Cloudinary tagu.
   */
  getPhotosByTag(
    tag: string | null | undefined
  ): Observable<Photo[]> {
    const tagName =
      (tag ?? '').trim();

    if (!tagName) {
      console.warn('Tag nije unesen.');
      return of([]);
    }

    const encodedTag =
      encodeURIComponent(tagName);

    const cacheBuster =
      Date.now();

    const listUrl =
      `https://res.cloudinary.com/` +
      `${this.cloudName}/image/list/` +
      `${encodedTag}.json` +
      `?v=${cacheBuster}`;

    console.log(
      'Loading Cloudinary folder/tag:',
      tagName
    );

    console.log(
      'Cloudinary list URL:',
      listUrl
    );

    return this.http
      .get<CloudinaryListResponse>(
        listUrl
      )
      .pipe(
        map(response => {
          const resources =
            response.resources ?? [];

          console.log(
            'Original Cloudinary resources:',
            resources
          );

          return resources.map(photo =>
            this.convertCloudinaryPhoto(
              photo,
              tagName
            )
          );
        }),

        tap(photos => {
          console.log(
            `Cloudinary tag "${tagName}":`,
            `${photos.length} slika`
          );

          console.log(
            'Converted photos:',
            photos
          );
        }),

        catchError(error => {
          console.error(
            `Could not load "${tagName}":`,
            error
          );

          return of([]);
        })
      );
  }

  /*
   * Pretvara Cloudinary odgovor u Photo model.
   *
   * public_id  -> publicId
   * secure_url -> url
   *
   * Ako secure_url ne postoji,
   * URL se pravi pomoću:
   * version + public_id + format
   */
  private convertCloudinaryPhoto(
    photo: CloudinaryPhoto,
    fallbackFolder = '',
    fallbackCaption = '',
    fallbackUserName = ''
  ): Photo {
    const encodedPublicId =
      photo.public_id
        .split('/')
        .map(part =>
          encodeURIComponent(part)
        )
        .join('/');

    const versionPart =
      photo.version
        ? `/v${photo.version}`
        : '';

    const formatPart =
      photo.format
        ? `.${photo.format}`
        : '';

    const generatedUrl =
      `https://res.cloudinary.com/` +
      `${this.cloudName}/image/upload/` +
      `f_auto,q_auto` +
      `${versionPart}/` +
      `${encodedPublicId}` +
      `${formatPart}`;

    const imageUrl =
      photo.secure_url?.trim() ||
      generatedUrl;

    const convertedPhoto: Photo = {
      publicId: photo.public_id,
      url: imageUrl,

      caption:
        photo.context?.custom?.caption ??
        fallbackCaption,

      userName:
        photo.context?.custom?.userName ??
        fallbackUserName,

      folder:
        photo.folder ??
        fallbackFolder,

      tags:
        photo.tags ?? [],

      width:
        photo.width,

      height:
        photo.height,

      format:
        photo.format
    };

    console.log(
      'Generated image URL:',
      imageUrl
    );

    return convertedPhoto;
  }
}