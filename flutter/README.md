# Dzemat Bochum Flutter app

Flutter aplikacija sa odvojenim Home i Galerija ekranom.

## Struktura

- Home: nema Cloudinary slika.
- Galerija: prikazuje slike iz Cloudinary taga `DzematBochum`.
- Upravljanje slikama: samo preko Cloudinary web konzole.
- Flutter aplikacija nema upload niti admin funkcije.

## Cloudinary

Cloud name: `dgyy4rc34`
Tag: `DzematBochum`

Lista:
`https://res.cloudinary.com/dgyy4rc34/image/list/DzematBochum.json`

## Pokretanje

```bash
flutter pub get
flutter run
```

Ako dodate ili uklonite sliku/tag u Cloudinary konzoli, otvorite Galeriju i povucite prema dole ili pritisnite refresh.
