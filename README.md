
# 网站融合器 (Web Fusion App)

<div align="center">

![App Icon](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Android-green?style=for-the-badge&logo=android)
![License](https://img.shields.io/badge/License-MIT-blue?style=for-the-badge)

一款优雅的 Flutter 应用，将多个网站整合到一个 App 中，支持自定义管理和快速切换。

[功能特点](#✨-功能特点) • [截图展示](#📱-截图展示) • [快速开始](#🚀-快速开始) • [使用指南](#📖-使用指南) • [贡献指南](#🤝-贡献指南)

</div>

---

## ✨ 功能特点

### 核心功能
- 🌐 **多网站融合** - 将多个网站整合到一个应用中
- 🔄 **快速切换** - 底部导航栏一键切换网站
- ⚙️ **灵活管理** - 支持增加、删除、修改网站配置
- 🎨 **自定义图标** - 为每个网站设置专属图标
- 💾 **数据持久化** - 自动保存配置，重启不丢失

### 高级特性
- 🔗 **智能跳转** - 自动识别第三方登录，跳转外部浏览器
- 🌓 **启用/禁用** - 灵活控制网站显示状态
- 📤 **导出/导入** - 支持配置备份和恢复
- 🎯 **WebView 全功能** - 支持 JavaScript、Cookie、本地存储
- 🔐 **OAuth 支持** - 完美支持 Google、GitHub 等第三方登录

### 界面设计
- 🎨 现代化 Material Design 3 风格
- 📋 优雅的卡片式列表设计
- 🎭 流畅的动画和过渡效果
- 💬 友好的操作反馈提示

---


## 🚀 快速开始

### 环境要求

- Flutter SDK: >= 3.0.0
- Dart SDK: >= 3.0.0
- Android Studio / VS Code
- Android SDK (for Android builds)

### 安装步骤

1. **克隆仓库**
```bash
git clone https://github.com/feichaixiaobai/Multi_web_app.git
cd Multi_web_app
```

2. **安装依赖**
```bash
flutter pub get
```

3. **运行应用**
```bash
flutter run
```

### 构建 APK

```bash
# Debug 版本
flutter build apk --debug

# Release 版本
flutter build apk --release

# Split APK（按架构分离）
flutter build apk --split-per-abi
```

生成的 APK 文件位于：`build/app/outputs/flutter-apk/`

---

## 📦 依赖包

```yaml
dependencies:
  flutter:
    sdk: flutter
  webview_flutter: ^4.4.2      # WebView 支持
  shared_preferences: ^2.2.2   # 本地数据存储
  url_launcher: ^6.2.1         # 外部链接启动
```

---

## 📖 使用指南

### 添加网站

1. 点击主界面右上角的 **设置图标**
2. 点击 **新增站点** 按钮
3. 填写网站信息：
   - **网站名称**：如 "Google"
   - **网站URL**：如 "https://www.google.com"
   - **图标URL**（可选）：网站图标地址
4. 点击 **添加** 完成

### 编辑网站

1. 在设置界面点击网站卡片右侧的 **⋮** 菜单
2. 选择 **编辑**
3. 修改网站信息后点击 **保存**

### 删除网站

1. 在设置界面点击网站卡片右侧的 **⋮** 菜单
2. 选择 **删除**
3. 确认删除

### 启用/禁用网站

- 使用网站卡片右侧的 **开关按钮**
- 禁用的网站不会在主界面显示

### 导出/导入配置

#### 导出
1. 点击设置界面顶部的 **导出** 按钮
2. 复制显示的 JSON 配置

#### 导入
1. 点击设置界面顶部的 **导入** 按钮
2. 粘贴之前导出的 JSON 配置
3. 点击 **导入** 完成

---

## 🔧 配置说明

### AndroidManifest.xml 配置

确保 `android/app/src/main/AndroidManifest.xml` 包含以下权限：

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- 网络权限 -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    
    <application
        android:usesCleartextTraffic="true">
        <!-- 其他配置 -->
    </application>
</manifest>
```


## 🎯 技术架构

### 项目结构

```
lib/
├── main.dart                 # 应用入口
```

### 核心技术

- **状态管理**：StatefulWidget
- **数据持久化**：SharedPreferences
- **网页渲染**：WebView Flutter
- **UI 框架**：Material Design 3
- **导航**：Navigator 2.0

---

## 🤝 贡献指南

欢迎贡献代码、报告问题或提出建议！

### 贡献流程

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

### 代码规范

- 遵循 [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- 使用 `flutter format` 格式化代码
- 确保代码通过 `flutter analyze`

---

## 📝 待办事项

- [ ] iOS 平台支持
- [ ] 夜间模式/主题切换
- [ ] 网站分组功能
- [ ] 历史记录和收藏夹
- [ ] 搜索功能
- [ ] 桌面快捷方式
- [ ] 更多图标库支持
- [ ] 离线模式

---

## 📄 许可证

本项目基于 [MIT License](LICENSE) 开源。

---

## 👨‍💻 作者

**Your Name**

- GitHub: [@feichaixiaobai](https://github.com/feichaixiaobai)

---

## 🙏 致谢

- [Flutter](https://flutter.dev/) - Google 开发的跨平台框架
- [webview_flutter](https://pub.dev/packages/webview_flutter) - 官方 WebView 插件
- [shared_preferences](https://pub.dev/packages/shared_preferences) - 本地数据存储
- 所有贡献者和支持者

---

## ⭐ Star History

如果这个项目对你有帮助，请给一个 ⭐️ Star！

[![Star History Chart](https://api.star-history.com/svg?repos=feichaixiaobai/web-fusion-app&type=Date)](https://star-history.com/#yourusername/web-fusion-app&Date)

---

<div align="center">

**[⬆ 回到顶部](#网站融合器-web-fusion-app)**

Made with ❤️ by [Your Name](https://github.com/yourusername)

</div>
