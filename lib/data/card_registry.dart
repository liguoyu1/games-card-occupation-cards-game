import 'card_data.dart';
import 'all_cards.dart';

/// ============================================================
/// 卡牌注册表 — 单例
/// ============================================================
class CardRegistry {
  static final CardRegistry _instance = CardRegistry._internal();
  factory CardRegistry() => _instance;
  CardRegistry._internal();

  final Map<String, CardData> _cards = {};

  void init() {
    for (final card in AllCards.cards) {
      _cards[card.id] = card;
    }
  }

  /// 根据 ID 获取卡牌
  CardData? get(String id) => _cards[id];

  /// 获取全部卡牌
  List<CardData> get allCards => _cards.values.toList();

  /// 获取全部卡牌 ID 列表
  List<String> get allIds => _cards.keys.toList();
}

/// 全局单例实例
final cardRegistry = CardRegistry();
