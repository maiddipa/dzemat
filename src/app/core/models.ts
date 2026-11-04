export interface AppUser {
  id: string;
  name: string;
  email: string;
  picture?: string | null;
}

export interface Photo {
  publicId: string;
  url: string;

  width?: number;
  height?: number;
  format?: string;

  caption?: string;
  userName?: string;
  uploadedAtUtc?: string;
}
