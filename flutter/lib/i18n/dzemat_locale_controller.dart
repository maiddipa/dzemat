import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
class DzematLocaleController extends ChangeNotifier{
 DzematLocaleController._();static final instance=DzematLocaleController._();String code='de';bool get isGerman => code == 'de';
 String t(String key){const tr={'de':{'home':'Startseite','gallery':'Galerie','news':'Aktuelles','about':'Über uns','contacts':'Ansprechpersonen','privacy':'Datenschutz','imprint':'Impressum'},'bs':{'home':'Početna','gallery':'Galerija','news':'Novosti','about':'O nama','contacts':'Kontakt osobe','privacy':'Datenschutz','imprint':'Impressum'}};return tr[code]?[key]??key;}
 Future<void> load()async{try{final p=await SharedPreferences.getInstance();code=p.getString('dzemat.language')=='bs'?'bs':'de';}catch(_){code='de';}notifyListeners();}
 Future<void> setLanguage(String value)async{if(value!='de'&&value!='bs')return;code=value;notifyListeners();try{final p=await SharedPreferences.getInstance();await p.setString('dzemat.language',value);}catch(_){}}
}
