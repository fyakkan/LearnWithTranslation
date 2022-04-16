import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInData with ChangeNotifier {
  //Shared preferences nesnesi oluşmuşsa aynı nesneyi tekrar çağırıyoruz yoksa sıfırdan oluşturuyoruz
  static SharedPreferences? _prefs;
  static initialize() async {
    if (_prefs != null) {
      return _prefs;
    } else {
      _prefs = await SharedPreferences.getInstance();
    }
  }

  //Shared prefs üzerine mail adresini kayıt ediyoruz
  static Future<void> saveMail(String mail) async {
    await _prefs?.setString('mail', mail);
  }

  //Shared prefs üzerine şifreyi kayıt ediyoruz
  static Future<void> savePassword(String password) async {
    await _prefs?.setString("password", password);
  }

  //Shared üzerinde kayıtlı olan bütün verileri siler
  static Future<void> sharedClear() async {
    await _prefs?.clear();
  }

  //Login bilgisini tutar
  static Future<void> login() async {
    await _prefs?.setBool('login', true);
  }

  //Kayıtlı veri varsa alıyoruz yoksa boş değer atıyoruz
  static String? get getMail => _prefs?.getString("mail") ?? "";
  static String? get getPassword => _prefs?.getString("password") ?? "";
  static bool get getLogin => _prefs?.getBool('login') ?? false;
}
