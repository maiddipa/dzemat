import { Routes } from '@angular/router';

export const routes: Routes = [
  {
    path: '',
    loadComponent: () =>
      import('./pages/home/home.component')
        .then(m => m.HomeComponent)
  },
  {
    path: 'upload',
    loadComponent: () =>
      import('./pages/upload/upload.component')
        .then(m => m.UploadComponent)
  },
  {
    path: 'login',
    loadComponent: () =>
      import('./pages/login/login.component')
        .then(m => m.LoginComponent)
  },
  {
  path: 'about',
  loadComponent: () =>
    import(
      './pages/about/about.component'
    ).then(
      component =>
        component.AboutComponent
    )
  },
  {
    path: '**',
    redirectTo: ''
  }
];