import 'package:flutter/foundation.dart';

class Store {
  final String id;
  final String name;
  final String address;
  final String ownerName;
  final String contactNumber;

  Store({
    required this.id,
    required this.name,
    required this.address,
    required this.ownerName,
    required this.contactNumber,
  });

  factory Store.fromMap(Map<String, dynamic> map) {
    return Store(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      ownerName: map['ownerName'] ?? '',
      contactNumber: map['contactNumber'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'ownerName': ownerName,
      'contactNumber': contactNumber,
    };
  }
}

class StoreProvider with ChangeNotifier {
  Store? _selectedStore;
  final List<Store> _stores = [
    Store(
      id: '1',
      name: '순대국',
      address: '서울시 강남구',
      ownerName: '',
      contactNumber: '',
    ),
  ];

  StoreProvider() {
    _selectedStore = _stores.first;
  }

  Store? get selectedStore => _selectedStore;
  List<Store> get stores => _stores;

  void selectStore(Store store) {
    _selectedStore = store;
    notifyListeners();
  }

  void addStore(Store store) {
    _stores.add(store);
    notifyListeners();
  }

  void removeStore(String storeId) {
    _stores.removeWhere((store) => store.id == storeId);
    if (_selectedStore?.id == storeId) {
      _selectedStore = _stores.isNotEmpty ? _stores.first : null;
    }
    notifyListeners();
  }
}
