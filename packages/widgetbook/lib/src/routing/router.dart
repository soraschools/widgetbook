import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:widgetbook/src/navigation/navigation.dart';
import 'package:widgetbook/src/routing/widgetbook_panel.dart';
import 'package:widgetbook/src/widgetbook_shell.dart';
import 'package:widgetbook/src/workbench/workbench.dart';

extension GoRouterExtension on BuildContext {
  void goTo({
    required Map<String, String> queryParams,
  }) {
    final goRouter = GoRouter.of(this);
    final uri = Uri.parse(goRouter.location);
    final queryParameters = Map<String, String>.from(uri.queryParameters);
    for (final pair in queryParams.entries) {
      queryParameters[pair.key] = pair.value;
    }

    goNamed('/', queryParams: queryParameters);
  }
}

Set<WidgetbookPanel> _parsePanelsQueryParam(
  String? value,
) {
  if (value == null) {
    return WidgetbookPanel.values.toSet();
  }

  if (value.isEmpty || value == '{}') {
    return {};
  }

  return value
      .replaceAll(RegExp('[{}]'), '')
      .split(',')
      .map((name) => WidgetbookPanel.values.byName(name))
      .toSet();
}

bool _parseBoolQueryParameter({
  required String? value,
  bool defaultValue = false,
}) {
  if (value == null) {
    return defaultValue;
  }

  return value == 'true';
}

GoRouter createRouter({
  required UseCasesProvider useCasesProvider,
  // Used for testing
  String? initialLocation,
}) {
  final router = GoRouter(
    redirect: (context, state) {
      // Redirect deprecated `disable-navigation` and `disable-properties`
      // query params to their equivalent `panels` query param.
      if (state.queryParams.containsKey('disable-navigation') ||
          state.queryParams.containsKey('disable-properties')) {
        final disableNavigation = _parseBoolQueryParameter(
          value: state.queryParams['disable-navigation'],
        );

        final disableProperties = _parseBoolQueryParameter(
          value: state.queryParams['disable-properties'],
        );

        final panels = {
          if (!disableNavigation) ...{
            WidgetbookPanel.navigation,
          },
          if (!disableProperties) ...{
            WidgetbookPanel.addons,
            WidgetbookPanel.knobs,
          }
        };

        return '/?panels={${panels.map((x) => x.name).join(",")}}';
      }

      final path = state.queryParams['path'];

      if (path != null) {
        useCasesProvider.selectUseCaseByPath(path);
      }

      return null;
    },
    initialLocation: initialLocation,
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          final panels = _parsePanelsQueryParam(state.queryParams['panels']);

          return WidgetbookShell(
            panels: panels,
            initialLocation: state.location,
            child: child,
          );
        },
        routes: [
          GoRoute(
            name: '/',
            path: '/',
            pageBuilder: (_, state) {
              return NoTransitionPage<void>(
                child: Workbench(
                  queryParams: state.queryParams,
                ),
              );
            },
          ),
        ],
      )
    ],
  );

  return router;
}
