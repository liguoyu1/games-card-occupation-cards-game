import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'game/battle_game.dart';
import 'game/network_battle_game.dart';
import 'screens/main_menu_screen.dart';
import 'screens/collection_screen.dart';
import 'screens/matchmaking_screen.dart';
import 'game/constants.dart';

void main() {
  runApp(const OccupationCardsApp());
}

class OccupationCardsApp extends StatelessWidget {
  const OccupationCardsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '职业卡牌',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.primaryBg,
        colorScheme: const ColorScheme.dark(primary: AppColors.accent, secondary: AppColors.accent),
      ),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  FlameGame? _currentGame;
  bool _isMenu = true;

  @override
  void initState() {
    super.initState();
    _showMainMenu();
  }

  void _showMainMenu() {
    setState(() {
      _isMenu = true;
      _currentGame = MainMenuGame(
        onStartGame: _startBattle,
        onCollection: _showCollection,
        onOnlineBattle: _startOnlineMatchmaking,
      );
    });
  }

  void _startBattle() {
    setState(() {
      _isMenu = false;
      _currentGame = BattleGame();
    });
  }

  void _showCollection() {
    setState(() {
      _isMenu = false;
      _currentGame = CollectionGame();
    });
  }

  void _startOnlineMatchmaking() {
    setState(() {
      _isMenu = false;
      _currentGame = MatchmakingGame(
        onMatched: () {
          // 匹配成功后跳转到联网战斗
        },
        onBack: _showMainMenu,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentGame == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: AppColors.primaryBg,
      body: Stack(
        children: [
          GameWidget(game: _currentGame!).flutterViewportFixedResolution(
            GameDimensions.worldWidth,
            GameDimensions.worldHeight,
          ),
          if (!_isMenu)
            Positioned(
              top: 40,
              left: 20,
              child: GestureDetector(
                onTap: _showMainMenu,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                  ),
                  child: const Text('← 返回', style: TextStyle(color: AppColors.accent, fontSize: 12)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

extension GameWidgetViewport on GameWidget {
  Widget flutterViewportFixedResolution(double width, double height) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scaleX = constraints.maxWidth / width;
        final scaleY = constraints.maxHeight / height;
        final scale = scaleX < scaleY ? scaleX : scaleY;
        return Center(
          child: SizedBox(
            width: width * scale,
            height: height * scale,
            child: FittedBox(
              fit: BoxFit.contain,
              child: SizedBox(width: width, height: height, child: this),
            ),
          ),
        );
      },
    );
  }
}
