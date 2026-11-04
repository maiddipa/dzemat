import { Component, inject } from '@angular/core';
import { DzematI18nService, Lang } from './dzemat-i18n.service';
@Component({standalone:true,selector:'app-language-switcher',template:`<nav [attr.aria-label]="i18n.t('language')"><button type="button" (click)="choose('de')" [attr.aria-pressed]="i18n.language()==='de'">🇩🇪 DE</button> <button type="button" (click)="choose('bs')" [attr.aria-pressed]="i18n.language()==='bs'">🇧🇦 BS</button></nav>`})
export class LanguageSwitcherComponent {readonly i18n=inject(DzematI18nService);choose(code:Lang){this.i18n.setLanguage(code);}}
