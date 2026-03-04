import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:endimata/common/AppData/presentation/bloc/app_data_bloc.dart';
import 'package:endimata/common/presentation/widgets/custom_scaffold.dart';
import 'package:endimata/features/home/presentation/bloc/home_bloc.dart';
import 'package:endimata/features/home/presentation/widgets/panel_content_widget.dart';
import 'package:endimata/features/home/presentation/widgets/photo_list_widget.dart';
import 'package:endimata/features/home/presentation/widgets/photo_toggle_button.dart';
import 'package:endimata/features/home/presentation/widgets/background_photo.dart';

import '../../../../common/AppData/presentation/bloc/app_data_event.dart';
import '../../../../common/AppData/presentation/bloc/app_data_state.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ValueNotifier<bool> _isPhotoListVisible = ValueNotifier<bool>(false);
  final PanelController _panelController = PanelController();
  final ScrollController _mainScrollController = ScrollController();
  final ScrollController _catalogScrollController = ScrollController();
  final ScrollController _wardrobeScrollController = ScrollController();
  final double _panelHeightClosed = 20.0;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _mainScrollController.addListener(_handleMainScroll);
  }

  void _handleMainScroll() {
    if (_mainScrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if (_panelController.isPanelClosed) {
        _panelController.open();
      }
    } else if (_mainScrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      if (_panelController.isPanelOpen) {
        _panelController.close();
      }
    }
  }

  @override
  void dispose() {
    _isPhotoListVisible.dispose();
    _mainScrollController.dispose();
    _catalogScrollController.dispose();
    _wardrobeScrollController.dispose();
    super.dispose();
  }

  void _togglePhotoList() {
    _isPhotoListVisible.value = !_isPhotoListVisible.value;
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
  }

  void _onPhotoSelected(String? base64Photo) {
    context.read<AppDataBloc>().add(SetSelectedPhotoEvent(base64Photo));
    _togglePhotoList();
  }

  @override
  Widget build(BuildContext context) {
    final double panelHeightOpen = MediaQuery.of(context).size.height * 0.35;

    return BlocProvider(
      create: (context) => HomeBloc(context.read<AppDataBloc>()),
      child: CustomScaffold(
        body: Stack(
          children: [
            BackgroundPhoto(),
            Column(
              children: [
                const SizedBox(height: 60),
                Expanded(
                  child: SingleChildScrollView(
                    controller: _mainScrollController,
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        BlocBuilder<AppDataBloc, AppDataState>(
                          builder: (context, state) {
                            if (state.selectedHumanPhoto == null) {
                              return const Center(
                                child: Text(
                                  'Выберите фотографию человека',
                                  style: TextStyle(fontSize: 18),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.7,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            ValueListenableBuilder<bool>(
              valueListenable: _isPhotoListVisible,
              builder: (context, isVisible, child) {
                if (!isVisible) return const SizedBox.shrink();
                return PhotoListWidget(
                  onPhotoSelected: _onPhotoSelected,
                  onClose: _togglePhotoList,
                );
              },
            ),
            SlidingUpPanel(
              controller: _panelController,
              minHeight: _panelHeightClosed,
              maxHeight: panelHeightOpen,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24.0),
                topRight: Radius.circular(24.0),
              ),
              boxShadow: const [],
              panel: PanelContentWidget(
                selectedTabIndex: _selectedTabIndex,
                onTabSelected: _onTabSelected,
                catalogScrollController: _catalogScrollController,
                wardrobeScrollController: _wardrobeScrollController,
              ),
              collapsed: const SizedBox.shrink(),
              color: Colors.transparent,
            ),
            ValueListenableBuilder<bool>(
              valueListenable: _isPhotoListVisible,
              builder: (context, isVisible, child) {
                return PhotoToggleButton(
                  isPhotoListVisible: isVisible,
                  onTap: _togglePhotoList,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
