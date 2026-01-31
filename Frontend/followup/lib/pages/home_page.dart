import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/events_provider.dart';
import '../widgets/event_card.dart';
import '../widgets/error_dialog.dart';
import '../theme/app_theme.dart';

// 主页面
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // 加载活动列表
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventsProvider>().fetchEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 800;

    final destinations = [
      const NavigationRailDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home),
        label: Text('首页'),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.add_circle_outline),
        selectedIcon: Icon(Icons.add_circle),
        label: Text('添加'),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.event_outlined),
        selectedIcon: Icon(Icons.event),
        label: Text('活动'),
      ),
    ];

    final pages = [
      _HomeContent(),
      _AddPlaceholder(),
      _EventsPlaceholder(),
    ];

    if (isWide) {
      // 宽屏使用侧边导航
      return Scaffold(
        backgroundColor: AppColors.backgroundStart,
        body: Row(
          children: [
            NavigationRail(
              backgroundColor: AppColors.cardBg,
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) => _onDestinationSelected(index),
              labelType: NavigationRailLabelType.all,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    Icon(
                      Icons.event_available,
                      size: 32,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'FollowUP',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              trailing: Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: IconButton(
                      icon: const Icon(Icons.logout),
                      onPressed: _logout,
                      tooltip: '退出登录',
                    ),
                  ),
                ),
              ),
              destinations: destinations,
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(
              child: SimpleWarmBackground(child: pages[_selectedIndex]),
            ),
          ],
        ),
      );
    }

    // 窄屏使用底部导航
    return Scaffold(
      backgroundColor: AppColors.backgroundStart,
      appBar: AppBar(
        backgroundColor: AppColors.cardBg,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.event_available,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            const Text('FollowUP'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: '退出登录',
          ),
        ],
      ),
      body: SimpleWarmBackground(child: pages[_selectedIndex]),
      bottomNavigationBar: NavigationBar(
        backgroundColor: AppColors.cardBg,
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => _onDestinationSelected(index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: '首页',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle),
            label: '添加',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_outlined),
            selectedIcon: Icon(Icons.event),
            label: '活动',
          ),
        ],
      ),
    );
  }

  void _onDestinationSelected(int index) {
    if (index == 1) {
      // 添加 - 跳转到输入页面
      Navigator.pushNamed(context, '/input');
    } else if (index == 2) {
      // 活动 - 跳转到活动列表页面
      Navigator.pushNamed(context, '/events');
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  Future<void> _logout() async {
    final confirm = await ConfirmDialog.show(
      context,
      title: '退出登录',
      message: '确定要退出登录吗？',
      confirmText: '退出',
      isDangerous: true,
    );

    if (confirm && mounted) {
      await context.read<AuthProvider>().logout();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/');
      }
    }
  }
}

// 首页内容
class _HomeContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<EventsProvider>(
      builder: (context, eventsProvider, child) {
        if (eventsProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final followedEvents = eventsProvider.followedEvents;

        return RefreshIndicator(
          onRefresh: () => eventsProvider.fetchEvents(),
          child: CustomScrollView(
            slivers: [
              // 欢迎区域
              SliverToBoxAdapter(
                child: Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return Container(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '欢迎回来，${authProvider.user?.username ?? '用户'}',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '今天有什么新的活动要添加吗？',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // 快速操作
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.text_snippet,
                          title: '文字识别',
                          subtitle: '输入活动描述',
                          onTap: () => Navigator.pushNamed(
                            context,
                            '/input',
                            arguments: {'tab': 0},
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.camera_alt,
                          title: '图片识别',
                          subtitle: '拍照或上传',
                          onTap: () => Navigator.pushNamed(
                            context,
                            '/input',
                            arguments: {'tab': 1},
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 关注的活动标题
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '关注的活动',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, '/events'),
                        child: const Text('查看全部'),
                      ),
                    ],
                  ),
                ),
              ),

              // 关注的活动列表
              if (followedEvents.isEmpty)
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(48),
                    child: Column(
                      children: [
                        Icon(
                          Icons.star_border,
                          size: 64,
                          color: theme.colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '还没有关注的活动',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () => Navigator.pushNamed(context, '/input'),
                          icon: const Icon(Icons.add),
                          label: const Text('添加活动'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final event = followedEvents[index];
                      return EventCard(
                        event: event,
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/preview',
                          arguments: {'event': event, 'isEditing': true},
                        ),
                        onToggleFollow: () =>
                            eventsProvider.toggleFollow(event.id!),
                        showActions: false,
                      );
                    },
                    childCount: followedEvents.length.clamp(0, 5),
                  ),
                ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 24),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: AppColors.cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 占位组件
class _AddPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('添加页面'));
  }
}

class _EventsPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('活动列表'));
  }
}
