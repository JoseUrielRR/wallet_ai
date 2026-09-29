import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/purchase.dart';
import '../../domain/repositories/purchase_repository.dart';

class LocalPurchaseRepository implements IPurchaseRepository {
  static const String _storageKey = 'wallet_ai_user_purchases_v1';
  final _streamController = StreamController<List<Purchase>>.broadcast();
  List<Purchase> _cachedPurchases = [];
  bool _initialized = false;

  static List<Purchase> get _initialDemoPurchases => [
        Purchase(
          id: 'pur_demo_1',
          userId: 'usr_demo',
          cardId: 'card_demo_aurora',
          cardAlias: 'Aurora Black',
          amountCents: 154000, // $1,540.00
          currency: 'MXN',
          category: 'supermarket',
          description: 'Despensa quincenal',
          merchant: 'Super Selecto',
          purchaseDate: DateTime.now().subtract(const Duration(days: 2)),
          billingCycleId: 'cycle_2026_09',
          estimatedRewardCents: 4620, // 3% = $46.20 MXN
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        Purchase(
          id: 'pur_demo_2',
          userId: 'usr_demo',
          cardId: 'card_demo_horizonte',
          cardAlias: 'Horizonte Viajes',
          amountCents: 98000, // $980.00
          currency: 'MXN',
          category: 'fuel',
          description: 'Carga de gasolina magna',
          merchant: 'Gasolinera Central',
          purchaseDate: DateTime.now().subtract(const Duration(days: 5)),
          billingCycleId: 'cycle_2026_09',
          estimatedRewardCents: 2450, // 2.5% = $24.50 MXN
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
        Purchase(
          id: 'pur_demo_3',
          userId: 'usr_demo',
          cardId: 'card_demo_aurora',
          cardAlias: 'Aurora Black',
          amountCents: 65000, // $650.00
          currency: 'MXN',
          category: 'dining',
          description: 'Cena con amigos',
          merchant: 'Bistró Italiano',
          purchaseDate: DateTime.now().subtract(const Duration(days: 7)),
          billingCycleId: 'cycle_2026_09',
          estimatedRewardCents: 2600, // 4% = $26.00 MXN
          createdAt: DateTime.now().subtract(const Duration(days: 7)),
        ),
      ];

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(jsonString);
        _cachedPurchases = decoded
            .map((item) => Purchase.fromMap(item as Map<String, dynamic>))
            .toList();
      } else {
        _cachedPurchases = List.from(_initialDemoPurchases);
        await _saveToDisk();
      }
    } catch (_) {
      _cachedPurchases = List.from(_initialDemoPurchases);
    }
    _initialized = true;
    _streamController.add(_cachedPurchases);
  }

  Future<void> _saveToDisk() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _cachedPurchases.map((p) => p.toMap()).toList();
      await prefs.setString(_storageKey, jsonEncode(jsonList));
    } catch (_) {
      // Ignorar en test puro
    }
  }

  @override
  Future<List<Purchase>> getPurchases() async {
    await _ensureInitialized();
    return List.unmodifiable(_cachedPurchases);
  }

  @override
  Stream<List<Purchase>> watchPurchases() {
    _ensureInitialized();
    if (_initialized) {
      Timer.run(() => _streamController.add(List.unmodifiable(_cachedPurchases)));
    }
    return _streamController.stream;
  }

  @override
  Future<void> savePurchase(Purchase purchase) async {
    await _ensureInitialized();
    final index = _cachedPurchases.indexWhere((p) => p.id == purchase.id);
    if (index >= 0) {
      _cachedPurchases[index] = purchase;
    } else {
      _cachedPurchases.insert(0, purchase); // Más reciente primero
    }
    await _saveToDisk();
    _streamController.add(List.unmodifiable(_cachedPurchases));
  }

  @override
  Future<void> deletePurchase(String id) async {
    await _ensureInitialized();
    _cachedPurchases.removeWhere((p) => p.id == id);
    await _saveToDisk();
    _streamController.add(List.unmodifiable(_cachedPurchases));
  }

  @override
  Future<void> resetToDemoPurchases() async {
    _cachedPurchases = List.from(_initialDemoPurchases);
    await _saveToDisk();
    _streamController.add(List.unmodifiable(_cachedPurchases));
  }

  @override
  Future<void> clearAllPurchases() async {
    _cachedPurchases.clear();
    await _saveToDisk();
    _streamController.add(List.unmodifiable(_cachedPurchases));
  }
}
