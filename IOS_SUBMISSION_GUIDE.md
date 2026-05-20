# iOS App Store 提交指南

## 环境要求

- macOS 13+
- Xcode 15+
- Flutter 3.11+
- Apple Developer 账号（$99/年）

## Bundle ID 配置

当前配置：
- Bundle ID: `com.occupationcards.occupationCards`
- 应用名: `职业卡牌`
- 最低 iOS: 12.0

## 提交步骤

### 1. 更新 iOS 配置

编辑 `ios/Runner/Info.plist`：
```xml
<key>CFBundleDisplayName</key>
<string>职业卡牌</string>
<key>CFBundleShortVersionString</key>
<string>1.0.0</string>
<key>CFBundleVersion</key>
<string>1</string>
```

### 2. 创建 App Store Connect 应用

1. 登录 [App Store Connect](https://appstoreconnect.apple.com)
2. 我的 App → "+" → 新建 App
3. 填写：
   - 平台：iOS
   - 名称：职业卡牌
   - 主要语言：简体中文
   - 套装 ID：com.occupationcards.occupationCards
   - SKU：occupation-cards-001
4. 创建后填写价格/销售范围

### 3. 构建发布版本

```bash
flutter build ipa --release
# 或手动签名
flutter build ios --release --no-codesign
```

### 4. 在 Xcode 中上传

1. 打开 `ios/Runner.xcworkspace`
2. Product → Archive
3. 在 Organizer 中选择分发方式：
   - App Store Connect（直接上传）
   - Ad Hoc（测试分发）
4. 上传到 App Store Connect

### 5. App Store Connect 配置

1. App 预览截图（6.7 英寸，1290×2796）：
   - 战斗界面截图
   - 主菜单截图
   - 牌库图鉴截图

2. App 描述：
```
职业卡牌是一款精品集换式卡牌游戏（CCG），包含 32 张精心设计的职业卡牌。

【游戏特色】
★ 16 种职业角色 — 程序员、医生、律师、设计师等现实职业
★ 8 种关键词机制 — 冲锋、嘲讽、圣盾、战吼、亡语、风怒、冻结、潜行
★ 精美视觉效果 — 深空商务风 UI，稀有度发光特效
★ AI 对战 — 智能出牌与攻击
★ 跨平台支持 — iPhone/iPad 完美适配

适合喜欢策略卡牌游戏的玩家。
```

3. 关键词（最多 170 字符）：
```
卡牌游戏,炉石,集换式卡牌,CCG,职业卡牌,对战,策略游戏,棋牌游戏,桌游
```

4. 类别：卡牌游戏 / 策略游戏

### 6. 提交审核

- 审核时间：通常 1-2 天
- 审核备注：说明游戏内容，无内购，无特殊权限需求

## 常见问题

### App Store 被拒原因

1. **年龄分级**：设置为 9+（卡牌游戏通常为 9+）
2. **截图尺寸**：必须包含 6.7/6.5/5.5 英寸截图
3. **内购**：如需内购需接入 IAP
4. **第三方登录**：如接入需提供账号删除机制

### 权限

当前应用无需特殊权限，仅需要：
- 网络权限（更新/排行榜）
