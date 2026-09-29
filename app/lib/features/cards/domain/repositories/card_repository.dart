import '../models/user_card.dart';

abstract class ICardRepository {
  Future<List<UserCard>> getCards();
  Stream<List<UserCard>> watchCards();
  Future<UserCard?> getCardById(String id);
  Future<void> saveCard(UserCard card);
  Future<void> deleteCard(String id);
  Future<void> resetToDemoData();
  Future<void> clearAllCards();
}
