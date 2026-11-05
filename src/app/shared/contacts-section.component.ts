import { CommonModule } from '@angular/common';
import { Component, OnInit, inject } from '@angular/core';
import { DzematI18nService } from './dzemat-i18n.service';
interface Person{name:string;roleBs:string;roleDe:string;email?:string;phone?:string}
@Component({standalone:true,imports:[CommonModule],selector:'app-dzemat-contacts',template:`<section><h2>{{i18n.t('contacts')}}</h2><article *ngFor="let p of people"><h3>{{p.name}}</h3><p>{{i18n.language()==='de'?p.roleDe:p.roleBs}}</p><a *ngIf="p.email" [href]="'mailto:'+p.email">{{p.email}}</a></article><h3>{{i18n.t('generalContact')}}</h3><p>Hochstraße 92, 44866 Bochum</p><p><a href="mailto:ikc-bb@outlook.de">ikc-bb@outlook.de</a> · 0177 7540425</p></section>`})
export class DzematContactsComponent implements OnInit{readonly i18n=inject(DzematI18nService);people:Person[]=[];async ngOnInit(){try{const r=await fetch('/kontakti.json');const x=await r.json();this.people=Array.isArray(x.people)?x.people:[];}catch{this.people=[];}}}
