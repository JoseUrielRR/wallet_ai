import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/user_card.dart';
import '../../domain/repositories/card_repository.dart';
import '../../data/repositories/local_card_repository.dart';

final cardRepositoryProvider = Provider<ICardRepository>((ref) {
  return LocalCardRepository();
});

final cardsStreamProvider = StreamProvider<List<UserCard>>((ref) {
  final repo = ref.watch(cardRepositoryProvider);
  return repo.watchCards();
});

class CardsNotifier extends Notifier<AsyncValue<List<UserCard>>> {
  late final ICardRepository _repository;

  @override
  AsyncValue<List<UserCard>> build() {
    _repository = ref.watch(cardRepositoryProvider);
    _loadCards();
    return const AsyncValue.loading();
  }

  Future<void> _loadCards() async {
    try {
      final cards = await _repository.getCards();
      state = AsyncValue.data(cards);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> saveCard(UserCard card) async {
    await _repository.saveCard(card);
    await _loadCards();
  }

  Future<void> deleteCard(String id) async {
    await _repository.deleteCard(id);
    await _loadCards();
  }

  Future<void> toggleCardStatus(String id) async {
    final currentCards = state.value ?? [];
    final card = currentCards.firstWhere((c) => c.id == id);
    final newStatus = card.status == 'active' ? 'paused' : 'active';
    await _repository.saveCard(card.copyWith(status: newStatus));
    await _loadCards();
  }

  Future<void> resetToDemo() async {
    await _repository.resetToDemoData();
    await _loadCards();
  }

  Future<void> clearAll() async {
    await _repository.clearAllCards();
    await _loadCards();
  }
}

final cardsProvider = NotifierProvider<CardsNotifier, AsyncValue<List<UserCard>>>(CardsNotifier.new);
