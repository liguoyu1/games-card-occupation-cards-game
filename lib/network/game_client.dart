import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class NetworkClient {
  WebSocketChannel? _channel;
  String? _playerId;   // 暂存服务端分配的ID
  final _listeners = <void Function(String, dynamic)>[];

  bool get isConnected => _channel != null;

  void connect(String host, int port) {
    _channel = WebSocketChannel.connect(Uri.parse('ws://$host:$port/ws'));
    _channel!.stream.listen(
      (data) => _handleMessage(jsonDecode(data)),
      onDone: () => _notify('disconnected', null),
      onError: (e) => _notify('error', '连接错误: $e'),
    );
  }

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
  }

  void send(Map<String, dynamic> msg) {
    if (_channel == null) return;
    _channel!.sink.add(jsonEncode(msg));
  }

  // 高层次的 API
  void requestMatch() => send({'type': 'match'});
  void playCard(int index) => send({'type': 'play_card', 'cardIndex': index});
  void attackMinion(int fromIdx, int toIdx) => send({'type': 'attack_minion', 'fromIdx': fromIdx, 'toIdx': toIdx});
  void attackHero(int fromIdx) => send({'type': 'attack_hero', 'fromIdx': fromIdx});
  void endTurn() => send({'type': 'end_turn'});

  // 监听
  void addListener(void Function(String, dynamic) listener) => _listeners.add(listener);
  void removeListener(void Function(String, dynamic) listener) => _listeners.remove(listener);

  void _handleMessage(Map<String, dynamic> msg) {
    final type = msg['type'] as String;
    switch (type) {
      case 'match_waiting':
        _notify('match_waiting', msg);
        break;
      case 'match_found':
        _notify('match_found', MatchFoundInfo(
          roomId: msg['roomId'] as String,
          opponentId: msg['opponentId'] as String,
          goingFirst: msg['goingFirst'] as bool,
        ));
        break;
      case 'game_state':
        _notify('game_state', GameStateMessage.fromJson(msg));
        break;
      case 'game_over':
        _notify('game_over', GameOverInfo(
          winner: msg['winner'] as String,
          reason: msg['reason'] as String? ?? '',
        ));
        break;
      case 'action_error':
        _notify('action_error', msg['message'] as String? ?? '操作失败');
        break;
      case 'opponent_disconnected':
        _notify('opponent_disconnected', null);
        break;
      case 'error':
        _notify('error', msg['message'] as String? ?? '未知错误');
        break;
      default:
        _notify('unknown', msg);
    }
  }

  void _notify(String type, dynamic data) {
    for (final l in List.from(_listeners)) {
      l(type, data);
    }
  }
}

// ===== 消息类型 =====

class MatchFoundInfo {
  final String roomId;
  final String opponentId;
  final bool goingFirst;
  MatchFoundInfo({required this.roomId, required this.opponentId, required this.goingFirst});
}

class GameStateMessage {
  final GameState state;
  GameStateMessage.fromJson(Map<String, dynamic> json)
      : state = GameState.fromJson(json['state'] as Map<String, dynamic>);
}

class GameState {
  final PlayerView playerView;
  final PlayerView enemyView;

  GameState({required this.playerView, required this.enemyView});

  factory GameState.fromJson(Map<String, dynamic> json) {
    return GameState(
      playerView: PlayerView.fromJson(json['playerView'] as Map<String, dynamic>),
      enemyView: PlayerView.fromJson(json['enemyView'] as Map<String, dynamic>),
    );
  }
}

class PlayerView {
  final String playerId;
  final int health;
  final int maxMana;
  final int currentMana;
  final int handCount;
  final int deckCount;
  final List<dynamic> hand;
  final List<MinionView> minions;

  PlayerView({
    required this.playerId, required this.health,
    required this.maxMana, required this.currentMana,
    required this.handCount, required this.deckCount,
    required this.hand, required this.minions,
  });

  factory PlayerView.fromJson(Map<String, dynamic> json) {
    return PlayerView(
      playerId: json['playerId'] as String,
      health: json['health'] as int,
      maxMana: (json['maxMana'] as int?) ?? 0,
      currentMana: (json['currentMana'] as int?) ?? 0,
      handCount: json['handCount'] as int,
      deckCount: json['deckCount'] as int,
      hand: (json['hand'] as List<dynamic>?) ?? [],
      minions: ((json['minions'] as List<dynamic>?) ?? [])
          .map((e) => MinionView.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class MinionView {
  final String id;
  final String name;
  final int attack;
  final int health;
  final int currentAttack;
  final int currentHealth;
  final int maxHealth;
  final bool hasTaunt;
  final bool hasDivineShield;
  final bool isFrozen;
  final List<String> keywords;

  MinionView({
    required this.id, required this.name,
    required this.attack, required this.health,
    required this.currentAttack, required this.currentHealth,
    required this.maxHealth,
    required this.hasTaunt, required this.hasDivineShield,
    required this.isFrozen, required this.keywords,
  });

  factory MinionView.fromJson(Map<String, dynamic> json) {
    final card = json['card'] as Map<String, dynamic>;
    return MinionView(
      id: card['id'] as String,
      name: card['name'] as String,
      attack: (card['attack'] as num?)?.toInt() ?? 0,
      health: (card['health'] as num?)?.toInt() ?? 0,
      currentAttack: (json['currentAttack'] as num?)?.toInt() ?? 0,
      currentHealth: (json['currentHealth'] as num?)?.toInt() ?? 0,
      maxHealth: (json['maxHealth'] as num?)?.toInt() ?? 0,
      hasTaunt: json['hasTaunt'] as bool? ?? false,
      hasDivineShield: json['hasDivineShield'] as bool? ?? false,
      isFrozen: json['isFrozen'] as bool? ?? false,
      keywords: (card['keywords'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }
}

class GameOverInfo {
  final String winner;
  final String reason;
  GameOverInfo({required this.winner, required this.reason});
}
