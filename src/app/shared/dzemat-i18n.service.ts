import { Injectable, signal } from '@angular/core';
export type Lang='de'|'bs';
const translations={
 de:{home:'Startseite',about:'Über uns',gallery:'Galerie',upload:'Hochladen',login:'Mit Google anmelden',logout:'Abmelden',
 welcome:'Willkommen',description:'Džemat Bochum verbindet Muslime in Bochum und Umgebung. Wir organisieren Gebete, Mekteb-Unterricht, Vorträge und Begegnungen.',
 location:'Standort anzeigen',aboutTitle:'Über unsere Gemeinde',aboutP1:'Wir pflegen islamische Werte, Gemeinschaft und gegenseitige Unterstützung.',aboutP2:'Besonders wichtig sind uns Kinder, Jugendliche und Familien.',
 activities:'Unsere Aktivitäten',prayer:'Tägliche Gebete',friday:'Freitagsgebet',school:'Mekteb-Unterricht',talks:'Vorträge',meetings:'Gemeinschaftstreffen',charity:'Humanitäre Aktivitäten',
 contact:'Kontakt',contactHeading:'Besuchen Sie uns oder schreiben Sie uns',address:'Adresse',phone:'Telefon',email:'E-Mail',website:'Webseite',
 support:'Unterstützen Sie uns',supportTitle:'Spenden für die Gemeindearbeit',supportText:'Für Spendeninformationen kontaktieren Sie bitte den Džemat direkt.',contactDonation:'Kontakt zu Spenden',
 contacts:'Ansprechpersonen',peopleIntro:'Kontaktpersonen und ihre Aufgaben im Džemat',noPeople:'Weitere Ansprechpersonen werden ergänzt.',errorContacts:'Die Kontaktliste ist zurzeit nicht erreichbar.',generalContact:'Allgemeiner Kontakt',
 galleryIntro:'Wählen Sie eine Galerie aus und sehen Sie sich die Bilder an.',gallerySelect:'Galerie auswählen',refresh:'Aktualisieren',loading:'Wird geladen …',retry:'Erneut versuchen',zoom:'Für Vollbild klicken',publishedBy:'Veröffentlicht von:',noPhotos:'Keine Bilder gefunden.',
 privacy:'Datenschutz',imprint:'Impressum',language:'Sprache'},
 bs:{home:'Početna',about:'O nama',gallery:'Galerija',upload:'Upload slika',login:'Prijava putem Googlea',logout:'Odjava',
 welcome:'Dobro došli',description:'Džemat Bochum okuplja muslimane iz Bochuma i okoline. Organizujemo namaze, mektebsku nastavu, predavanja i druženja.',
 location:'Prikaži lokaciju',aboutTitle:'O našem džematu',aboutP1:'Naš cilj je njegovanje islamskih vrijednosti, zajedništva i međusobnog pomaganja.',aboutP2:'Posebnu pažnju posvećujemo djeci, mladima i porodicama.',
 activities:'Naše aktivnosti',prayer:'Dnevni namazi',friday:'Džuma-namaz',school:'Mektebska nastava',talks:'Predavanja',meetings:'Druženja',charity:'Humanitarne aktivnosti',
 contact:'Kontakt',contactHeading:'Posjetite nas ili nam se javite',address:'Adresa',phone:'Telefon',email:'E-mail',website:'Web-stranica',
 support:'Podržite naš rad',supportTitle:'Donacije za rad džemata',supportText:'Za informacije o donacijama kontaktirajte džemat direktno.',contactDonation:'Kontakt za donacije',
 contacts:'Kontakt osobe',peopleIntro:'Kontakt osobe i njihove dužnosti u džematu',noPeople:'Spisak kontakt-osoba će biti dopunjen.',errorContacts:'Spisak kontakt-osoba trenutno nije dostupan.',generalContact:'Opći kontakt',
 galleryIntro:'Izaberite galeriju i pregledajte slike.',gallerySelect:'Izaberite galeriju',refresh:'Osvježi',loading:'Učitavanje …',retry:'Pokušaj ponovo',zoom:'Kliknite za punu veličinu',publishedBy:'Objavio:',noPhotos:'Nema pronađenih slika.',
 privacy:'Datenschutz',imprint:'Impressum',language:'Jezik'}
} as const;
export type Word=keyof typeof translations.de;
@Injectable({providedIn:'root'})
export class DzematI18nService {
 private readonly state=signal<Lang>(this.stored());
 readonly language=this.state.asReadonly();
 t(key:Word):string{return translations[this.state()][key];}
 setLanguage(lang:Lang){this.state.set(lang);try{localStorage.setItem('dzemat.language',lang);document.documentElement.lang=lang;}catch{}}
 private stored():Lang{try{return typeof localStorage!=='undefined'&&localStorage.getItem('dzemat.language')==='bs'?'bs':'de';}catch{return 'de';}}
}
