class FirestoreCollections {
  FirestoreCollections._();

  static const String users = 'users';

  static String userDoc(String userId) => '$users/$userId';

  static String cards(String userId) => '$users/$userId/cards';
  static String cardDoc(String userId, String cardId) => '$users/$userId/cards/$cardId';

  static String purchases(String userId) => '$users/$userId/purchases';
  static String purchaseDoc(String userId, String purchaseId) => '$users/$userId/purchases/$purchaseId';

  static String loans(String userId) => '$users/$userId/loans';
  static String loanDoc(String userId, String loanId) => '$users/$userId/loans/$loanId';

  static String preferences(String userId) => '$users/$userId/preferences/user_preferences';
}
