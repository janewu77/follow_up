import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/html.dart' as html;
import '../l10n/app_localizations.dart';
import '../providers/events_provider.dart';
import '../widgets/event_card.dart';
import '../widgets/error_dialog.dart';
import '../theme/app_theme.dart';

// 活动列表页面
class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // 加载活动列表
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventsProvider>().fetchEvents();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _deleteEvent(int id) async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await ConfirmDialog.show(
      context,
      title: l10n.deleteEvent,
      message: l10n.deleteEventConfirm,
      confirmText: l10n.delete,
      isDangerous: true,
    );

    if (confirm && mounted) {
      final success = await context.read<EventsProvider>().deleteEvent(id);
      if (success && mounted) {
        SnackBarHelper.showSuccess(context, l10n.eventDeleted);
      }
    }
  }

  Future<void> _downloadIcs(int eventId, String title) async {
    final l10n = AppLocalizations.of(context)!;
    final eventsProvider = context.read<EventsProvider>();
    final icsBytes = await eventsProvider.downloadIcs(eventId);

    if (icsBytes == null) {
      if (mounted) {
        SnackBarHelper.showError(context, l10n.downloadFailed);
      }
      return;
    }

    final filename = '${title.replaceAll(RegExp(r'[^\w\s]'), '')}.ics';

    try {
      if (kIsWeb) {
        // Web platform download
        final blob = html.Blob([icsBytes], 'text/calendar');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', filename)
          ..click();
        html.Url.revokeObjectUrl(url);
        if (mounted) {
          SnackBarHelper.showSuccess(context, l10n.icsDownloaded);
        }
      } else {
        // Mobile platform save file
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$filename');
        await file.writeAsBytes(icsBytes);
        if (mounted) {
          SnackBarHelper.showSuccess(context, l10n.fileSaved);
        }
      }
    } catch (e) {
      if (mounted) {
        SnackBarHelper.showError(context, '${l10n.downloadFailed}: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: AppColors.backgroundStart,
      appBar: AppBar(
        backgroundColor: AppColors.cardBg,
        title: Text(l10n.eventList),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          indicatorColor: AppColors.primary,
          tabs: [
            Tab(text: l10n.allEvents),
            Tab(text: l10n.followed),
          ],
        ),
      ),
      body: SimpleWarmBackground(
        child: Consumer<EventsProvider>(
          builder: (context, eventsProvider, child) {
            if (eventsProvider.isLoading && eventsProvider.events.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            return TabBarView(
              controller: _tabController,
              children: [
                // All events
                _EventsList(
                  events: eventsProvider.events,
                  eventsProvider: eventsProvider,
                  onDelete: _deleteEvent,
                  onDownloadIcs: _downloadIcs,
                  emptyMessage: l10n.noEvents,
                ),
                // Followed
                _EventsList(
                  events: eventsProvider.followedEvents,
                  eventsProvider: eventsProvider,
                  onDelete: _deleteEvent,
                  onDownloadIcs: _downloadIcs,
                  emptyMessage: l10n.noFollowedEventsYet,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _EventsList extends StatelessWidget {
  final List events;
  final EventsProvider eventsProvider;
  final Future<void> Function(int id) onDelete;
  final Future<void> Function(int eventId, String title) onDownloadIcs;
  final String emptyMessage;

  const _EventsList({
    required this.events,
    required this.eventsProvider,
    required this.onDelete,
    required this.onDownloadIcs,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => eventsProvider.fetchEvents(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return EventCard(
            event: event,
            onTap: () => Navigator.pushNamed(
              context,
              '/preview',
              arguments: {'event': event, 'isEditing': true},
            ),
            onDelete: event.id != null ? () => onDelete(event.id!) : null,
            onToggleFollow: event.id != null
                ? () => eventsProvider.toggleFollow(event.id!)
                : null,
            onDownloadIcs: event.id != null
                ? () => onDownloadIcs(event.id!, event.title)
                : null,
          );
        },
      ),
    );
  }
}
