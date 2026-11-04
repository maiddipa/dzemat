# Džemat Bochum – DE/BS integration

Ovo je INTEGRACIJSKI PAKET, ne kompletan Angular ili Flutter projekt. Postojeći GitHub main ima samo angular.json. Ne mijenjati produkciju dok se puni izvorni kod ne doda.

Angular: kopirati web/src/app/shared u lokalni src/app/shared; dodati <app-language-switcher> u header i <app-dzemat-contacts> u AboutPage i povezati prevode s postojećim tekstom. Kopirati web/public/kontakti.json u public.

Flutter: kopirati flutter/lib u postojeći Flutter lib; dodati shared_preferences, http i url_launcher; pozvati await DzematLocaleController.instance.load() prije runApp; uključiti DzematLanguageSwitcher u AppBar, DzematContactPeopleSection i DzematLegalLinks u AboutPage. Ne mijenjati Firebase/APNs/Cloudinary konfiguraciju. Testirati build.

Pravni tekstovi u legal/ su samo NACRTI i nisu spremni za objavu. Potvrditi pravni naziv, predstavnika, infrastrukturu i obradu podataka.

Aktuelni people[] je prazan – objaviti imena i kontakte samo uz odobrenje. Flutter čita /kontakti.json sa dzematbochum.de.
