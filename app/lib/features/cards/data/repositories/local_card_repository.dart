import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/user_card.dart';
import '../../domain/repositories/card_repository.dart';
import '../mock/demo_cards_data.dart';

class LocalCardRepository implements ICardRepository {
  static const String _storageKey = 'wallet_ai_user_cards_v1';
  final _cardsStreamController = StreamController<List<UserCard>>.broadcast();
  List<UserCard> _cachedCards = [];
  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(jsonString);
        _cachedCards = decoded
            .map((item) => UserCard.fromMap(item as Map<String, dynamic>))
            .toList();
      } else {
        _cachedCards = [];
        await _saveToDisk();
      }
    } catch (_) {
      _cachedCards = [];
    }
    _initialized = true;
    _cardsStreamController.add(_cachedCards);
  }

  Future<void> _saveToDisk() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _cachedCards.map((c) => c.toMap()).toList();
      await prefs.setString(_storageKey, jsonEncode(jsonList));
    } catch (_) {
      // Ignorar fallos de persistencia en entornos de test puros sin mock de prefs
    }
  }

  @override
  Future<List<UserCard>> getCards() async {
    await _ensureInitialized();
    return List.unmodifiable(_cachedCards);
  }

  @override
  Stream<List<UserCard>> watchCards() {
    _ensureInitialized();
    // Emitir valor inicial si ya está listo
    if (_initialized) {
      Timer.run(() => _cardsStreamController.add(List.unmodifiable(_cachedCards)));
    }
    return _cardsStreamController.stream;
  }

  @override
  Future<UserCard?> getCardById(String id) async {
    await _ensureInitialized();
    try {
      return _cachedCards.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveCard(UserCard card) async {
    await _ensureInitialized();
    final index = _cachedCards.indexWhere((c) => c.id == card.id);
    if (index >= 0) {
      _cachedCards[index] = card.copyWith(updatedAt: DateTime.now());
    } else {
      _cachedCards.add(card);
    }
    await _saveToDisk();
    _cardsStreamController.add(List.unmodifiable(_cachedCards));
  }

  @override
  Future<void> deleteCard(String id) async {
    await _ensureInitialized();
    _cachedCards.removeWhere((c) => c.id == id);
    await _saveToDisk();
    _cardsStreamController.add(List.unmodifiable(_cachedCards));
  }

  @override
  Future<void> resetToDemoData() async {
    _cachedCards = List.from(DemoCardsData.initialDemoCards);
    await _saveToDisk();
    _cardsStreamController.add(List.unmodifiable(_cachedCards));
  }

  @override
  Future<void> clearAllCards() async {
    _cachedCards.clear();
    await _saveToDisk();
    _cardsStreamController.add(List.unmodifiable(_cachedCards));
  }
}
