import 'package:home_widget/home_widget.dart';
import 'package:snippet_app/core/constants.dart';
import 'package:snippet_app/features/snippet/data/models/snippet.dart';

class UpdateWidgetUseCase {
  Future<void> call(List<Snippet> snippets) async {
    if (snippets.isEmpty) return;
    try {
      await HomeWidget.setAppGroupId(AppConstants.appGroupId);
      final top = snippets.first;
      await HomeWidget.saveWidgetData<String>('snippet_text', top.text);
      await HomeWidget.saveWidgetData<String>('snippet_tag', top.tag);
      await HomeWidget.updateWidget(
        name: AppConstants.widgetProviderName,
        iOSName: AppConstants.widgetIosName,
      );
    } catch (e) {
      // Widget update failure is non-critical
    }
  }
}
