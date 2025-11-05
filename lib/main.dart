import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '网站融合器',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class WebSite {
  String name;
  String url;
  String? iconUrl;
  bool isEnabled;

  WebSite({
    required this.name,
    required this.url,
    this.iconUrl,
    this.isEnabled = true,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'url': url,
    'iconUrl': iconUrl,
    'isEnabled': isEnabled,
  };

  factory WebSite.fromJson(Map<String, dynamic> json) {
    return WebSite(
      name: json['name'],
      url: json['url'],
      iconUrl: json['iconUrl'],
      isEnabled: json['isEnabled'] ?? true,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<WebSite> websites = [];
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    loadWebsites();
  }

  Future<void> loadWebsites() async {
    final prefs = await SharedPreferences.getInstance();
    final String? websitesJson = prefs.getString('websites');

    if (websitesJson != null) {
      final List<dynamic> decoded = json.decode(websitesJson);
      setState(() {
        websites = decoded.map((item) => WebSite.fromJson(item)).toList();
      });
    } else {
      // 默认网站
      setState(() {
        websites = [
          WebSite(
            name: 'Gemini',
            url: 'https://gemini.google.com',
            iconUrl: 'https://www.gstatic.com/lamda/images/gemini_sparkle_v002_d4735304ff6292a690345.svg',
          ),
          WebSite(
            name: 'ChatGPT',
            url: 'https://chatgpt.com',
            iconUrl: 'https://cdn.oaistatic.com/_next/static/media/apple-touch-icon.59f2e898.png',
          ),
          WebSite(
            name: '文心一言',
            url: 'https://yiyan.baidu.com',
          ),
        ];
      });
      saveWebsites();
    }
  }

  Future<void> saveWebsites() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded =
    json.encode(websites.map((w) => w.toJson()).toList());
    await prefs.setString('websites', encoded);
  }

  List<WebSite> get enabledWebsites =>
      websites.where((w) => w.isEnabled).toList();

  @override
  Widget build(BuildContext context) {
    final enabled = enabledWebsites;

    return Scaffold(
      appBar: AppBar(
        title: Text(enabled.isEmpty ? '网站融合器' : enabled[selectedIndex].name),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsPage(
                    websites: websites,
                    onSave: (updatedWebsites) {
                      setState(() {
                        websites = updatedWebsites;
                        // 重置选中索引
                        if (selectedIndex >= enabledWebsites.length) {
                          selectedIndex = enabledWebsites.isEmpty ? 0 : enabledWebsites.length - 1;
                        }
                      });
                      saveWebsites();
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: enabled.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.web, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              '没有启用的网站',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsPage(
                      websites: websites,
                      onSave: (updatedWebsites) {
                        setState(() {
                          websites = updatedWebsites;
                        });
                        saveWebsites();
                      },
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('添加网站'),
            ),
          ],
        ),
      )
          : Column(
        children: [
          if (enabled.length > 1)
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              color: Colors.blue.shade50,
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.blue),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '点击底部图标切换网站',
                      style: TextStyle(fontSize: 12, color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: WebViewPage(url: enabled[selectedIndex].url),
          ),
        ],
      ),
      bottomNavigationBar: enabled.length < 2
          ? null
          : NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        destinations: enabled
            .map((site) => NavigationDestination(
          icon: site.iconUrl != null
              ? Image.network(
            site.iconUrl!,
            width: 24,
            height: 24,
            errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.web),
          )
              : const Icon(Icons.web),
          label: site.name,
        ))
            .toList(),
      ),
    );
  }
}

class SettingsPage extends StatefulWidget {
  final List<WebSite> websites;
  final Function(List<WebSite>) onSave;

  const SettingsPage({
    Key? key,
    required this.websites,
    required this.onSave,
  }) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late List<WebSite> websites;

  @override
  void initState() {
    super.initState();
    websites = List.from(widget.websites);
  }

  void saveChanges() {
    widget.onSave(websites);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            // 顶部工具栏
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      showAddWebsiteDialog(context);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('新增站点'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: showExportDialog,
                    child: const Text('导出'),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: showImportDialog,
                    child: const Text('导入'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // 网站列表
            Expanded(
              child: websites.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.web_asset_off,
                        size: 80, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      '还没有添加网站',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        showAddWebsiteDialog(context);
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('添加第一个网站'),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: websites.length,
                itemBuilder: (context, index) {
                  return WebsiteListItem(
                    website: websites[index],
                    onTap: () {
                      // 点击打开预览
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WebViewPage(
                            url: websites[index].url,
                            title: websites[index].name,
                          ),
                        ),
                      );
                    },
                    onRefresh: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('刷新 ${websites[index].name}'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    onDownload: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('下载 ${websites[index].name}'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    onEdit: () {
                      showEditWebsiteDialog(context, index);
                    },
                    onDelete: () {
                      showDeleteDialog(context, index);
                    },
                    onToggle: (value) {
                      setState(() {
                        websites[index].isEnabled = value;
                      });
                      saveChanges();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showAddWebsiteDialog(BuildContext context) {
    final nameController = TextEditingController();
    final urlController = TextEditingController();
    final iconController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('新增站点'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: '网站名称',
                  hintText: '例如：Google',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: urlController,
                decoration: const InputDecoration(
                  labelText: '网站URL',
                  hintText: '例如：https://www.google.com',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: iconController,
                decoration: const InputDecoration(
                  labelText: '图标URL（可选）',
                  hintText: '网站图标地址',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  urlController.text.isNotEmpty) {
                setState(() {
                  websites.add(WebSite(
                    name: nameController.text,
                    url: urlController.text,
                    iconUrl: iconController.text.isEmpty
                        ? null
                        : iconController.text,
                  ));
                });
                saveChanges();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white),
                        const SizedBox(width: 8),
                        Text('已添加 ${nameController.text}'),
                      ],
                    ),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }

  void showEditWebsiteDialog(BuildContext context, int index) {
    final site = websites[index];
    final nameController = TextEditingController(text: site.name);
    final urlController = TextEditingController(text: site.url);
    final iconController = TextEditingController(text: site.iconUrl ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('编辑站点'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: '网站名称',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: urlController,
                decoration: const InputDecoration(
                  labelText: '网站URL',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: iconController,
                decoration: const InputDecoration(
                  labelText: '图标URL（可选）',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  urlController.text.isNotEmpty) {
                setState(() {
                  websites[index] = WebSite(
                    name: nameController.text,
                    url: urlController.text,
                    iconUrl: iconController.text.isEmpty
                        ? null
                        : iconController.text,
                    isEnabled: site.isEnabled,
                  );
                });
                saveChanges();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white),
                        const SizedBox(width: 8),
                        Text('已更新 ${nameController.text}'),
                      ],
                    ),
                    backgroundColor: Colors.blue,
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void showDeleteDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除 ${websites[index].name} 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              final name = websites[index].name;
              setState(() {
                websites.removeAt(index);
              });
              saveChanges();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white),
                      const SizedBox(width: 8),
                      Text('已删除 $name'),
                    ],
                  ),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text(
              '删除',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void showExportDialog() {
    final jsonStr = json.encode(websites.map((w) => w.toJson()).toList());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('导出配置'),
        content: SelectableText(jsonStr),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  void showImportDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('导入配置'),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: '粘贴配置JSON',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              try {
                final List<dynamic> decoded = json.decode(controller.text);
                setState(() {
                  websites =
                      decoded.map((item) => WebSite.fromJson(item)).toList();
                });
                saveChanges();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('导入成功'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('导入失败，请检查格式'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('导入'),
          ),
        ],
      ),
    );
  }
}

class WebsiteListItem extends StatelessWidget {
  final WebSite website;
  final VoidCallback onTap;
  final VoidCallback onRefresh;
  final VoidCallback onDownload;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<bool> onToggle;

  const WebsiteListItem({
    Key? key,
    required this.website,
    required this.onTap,
    required this.onRefresh,
    required this.onDownload,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 网站图标
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: website.iconUrl != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    website.iconUrl!,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.web, color: Colors.blue);
                    },
                  ),
                )
                    : const Icon(Icons.web, color: Colors.blue),
              ),
              const SizedBox(width: 12),
              // 网站信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      website.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      website.url,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // 操作按钮
              IconButton(
                icon: const Icon(Icons.refresh, size: 20),
                color: Colors.blue,
                onPressed: onRefresh,
                tooltip: '刷新',
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.download, size: 16, color: Colors.blue),
              ),
              const SizedBox(width: 8),
              PopupMenuButton(
                icon: const Icon(Icons.more_vert, size: 20),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    onTap: onEdit,
                    child: const Row(
                      children: [
                        Icon(Icons.edit, size: 18),
                        SizedBox(width: 8),
                        Text('编辑'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    onTap: onDelete,
                    child: const Row(
                      children: [
                        Icon(Icons.delete, size: 18, color: Colors.red),
                        SizedBox(width: 8),
                        Text('删除', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
              // 开关
              Transform.scale(
                scale: 0.8,
                child: Switch(
                  value: website.isEnabled,
                  onChanged: onToggle,
                  activeColor: Colors.green,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WebViewPage extends StatefulWidget {
  final String url;
  final String? title;

  const WebViewPage({Key? key, required this.url, this.title})
      : super(key: key);

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() {
              isLoading = true;
            });
          },
          onPageFinished: (url) {
            setState(() {
              isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  void didUpdateWidget(WebViewPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      controller.loadRequest(Uri.parse(widget.url));
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.title != null
        ? Scaffold(
      appBar: AppBar(
        title: Text(widget.title!),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              controller.reload();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: controller),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    )
        : Stack(
      children: [
        WebViewWidget(controller: controller),
        if (isLoading)
          const Center(
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }
}