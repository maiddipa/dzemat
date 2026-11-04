import { Injectable, signal } from '@angular/core';
export type Lang = 'de' | 'bs';
const strings = {
 de: {home:'Startseite',gallery:'Galerie',news:'Aktuelles',about:'Über uns',contacts:'Ansprechpersonen',language:'Sprache',imprint:'Impressum',privacy:'Datenschutz',generalContact:'Allgemeiner Kontakt'},
 bs: {home:'Početna',gallery:'Galerija',news:'Novosti',about:'O nama',contacts:'Kontakt osobe',language:'Jezik',imprint:'Impressum',privacy:'Datenschutz',generalContact:'Opći kontakt'}
};
export type Word = keyof typeof strings.de;
@Injectable({providedIn:'root'}) export class DzematI18nService {
 private state = signal<Lang>(this.read()); readonly language=this.state.asReadonly();
 t(key:Word){return strings[this.state()][key];}
 setLanguage(value:Lang){this.state.set(value);try{localStorage.setItem('dzemat.language',value);document.documentElement.lang=value;}catch{}}
 private read():Lang{try{return localStorage.getItem('dzemat.language')==='bs'?'bs':'de';}catch{return 'de';}}
}
