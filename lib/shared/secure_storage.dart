import 'dart:convert';

import 'package:des_mobile_admin_v3/shared/mock_data.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ManageStorage {
  static createProfile({dynamic value, String? key}) async {
    FlutterSecureStorage storage = const FlutterSecureStorage();
    await storage.write(key: 'profileCategory', value: key);
    await storage.write(
      key: 'profileImageUrl',
      value: value?['imageUrl'] ?? '',
    );

    await storage.write(key: 'profileCode', value: value['code']);
    await storage.write(key: 'profileData', value: json.encode(value));
  }

  static createSecureStorage({dynamic key, String? value}) async {
    FlutterSecureStorage storage = const FlutterSecureStorage();
    await storage.write(key: key, value: value);
  }

  static dynamic getMockProfileData() async {
    FlutterSecureStorage storage = const FlutterSecureStorage();
    var data = await storage.read(key: 'profileData') ?? '';
    if (data.isEmpty) {
      // for test
      await mockCreateProfileData();
      getMockProfileData();
    } else {
      var result = json.decode(data);
      return result;
    }
  }

  static deleteStorageAll() {
    FlutterSecureStorage storage = const FlutterSecureStorage();
    storage.deleteAll();
  }

  static deleteStorage(key) {
    FlutterSecureStorage storage = const FlutterSecureStorage();
    storage.delete(key: key);
  }

  static read(String key) async {
    FlutterSecureStorage storage = const FlutterSecureStorage();
    return await storage.read(key: key) ?? '';
  }

  static readDynamic(String key) async {
    FlutterSecureStorage storage = const FlutterSecureStorage();
    var result = await storage.read(key: key) ?? '';
    return json.decode(result);
  }
}
