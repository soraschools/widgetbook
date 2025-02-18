import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';
import 'package:widgetbook_core/widgetbook_core.dart';
import 'package:widgetbook_for_widgetbook/navigation/navigation_bloc_provider.dart';
import 'package:widgetbook_for_widgetbook/navigation/navigation_test_data.dart';

@UseCase(name: 'Default', type: NavigationPanel)
Widget navigationPanelDefaultUseCase(BuildContext context) {
  return const NavigationBlocProvider(
    directories: directories,
    child: NavigationPanel(),
  );
}
