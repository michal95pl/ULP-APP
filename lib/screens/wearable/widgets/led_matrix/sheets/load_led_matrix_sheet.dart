import 'package:flutter/material.dart';
import 'package:mobile_app/screens/wearable/widgets/led_matrix/led_matrix_controller.dart';
import 'package:mobile_app/screens/wearable/widgets/led_matrix/sheets/components/pattern_tile.dart';
import 'package:mobile_app/screens/wearable/widgets/led_matrix/sheets/components/type_selector.dart';
import 'package:mobile_app/utils/app_colors.dart';
import 'package:mobile_app/utils/app_snack_bar.dart';

class LoadLedMatrixSheet extends StatefulWidget {
  final LedMatrixController controller;

  const LoadLedMatrixSheet({
    super.key,
    required this.controller,
  });

  static void show(BuildContext context, {required LedMatrixController controller}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (context) => LoadLedMatrixSheet(controller: controller),
    );
  }

  @override
  State<LoadLedMatrixSheet> createState() => _LoadLedMatrixSheetState();
}

class _LoadLedMatrixSheetState extends State<LoadLedMatrixSheet> {

  MatrixSourceType _currentType = MatrixSourceType.pixelArt;
  int? _selectedIndex;
  bool _isLoading = false;
  bool _isProcessing = false;

  List<String> _projectsFileNames = [];
  List<String> _imagesFileNames = [];

  @override
  void initState() {
    super.initState();
    _loadAvailableFiles();
  }

  Future<void> _loadAvailableFiles() async {
    setState(() => _isLoading = true);
    try {
      final pixelArts = await widget.controller.getSavedPixelArts();
      final images = await widget.controller.getSavedImages();

      if (!mounted) return;

      setState(() {
        _projectsFileNames = pixelArts;
        _imagesFileNames = images;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  List<String> get _currentList {
    switch (_currentType) {
      case MatrixSourceType.pixelArt:
        return _projectsFileNames;
      case MatrixSourceType.images:
        return _imagesFileNames;
    }
  }

  void _onLoadPressed() {
    if (_selectedIndex == null || _isProcessing) return;
    setState(() => _isProcessing = true);
    
    try {
      final selectedFileName = _currentList[_selectedIndex!];
      widget.controller.loadFile(selectedFileName);

      if (!mounted) return;
      Navigator.of(context).pop(selectedFileName);
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.showError(context, title: 'Load Error', message: e.toString());
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _onDeletePressed() async {
    if (_selectedIndex == null || _isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final fileToDelete = _currentList[_selectedIndex!];
      await widget.controller.deleteFile(fileToDelete);

      if (!mounted) return;

      setState(() {
        _currentList.removeAt(_selectedIndex!);
        _selectedIndex = null;
      });
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.showError(context, title: 'Delete Error', message: e.toString());
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isActionEnabled = (_selectedIndex != null) && !_isProcessing;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20.0,
          right: 20.0,
          top: 16.0,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20.0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TypeSelector(
              selectedType: _currentType,
              onTypeChanged: (type) {
                setState(() {
                  _currentType = type;
                  _selectedIndex = null;
                });
              },
              isEnabled: !_isProcessing,
            ),

            const SizedBox(height: 16.0),

            SizedBox(
              height: MediaQuery.of(context).size.height * 0.35,
              child: Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _currentList.isEmpty
                    ? Center(
                        child: Text(
                          'Files not found',
                          style: TextStyle(color: Colors.white54),
                        ),
                      )
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        itemCount: _currentList.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8.0),
                        itemBuilder: (context, index) {
                          return PatternTile(
                            fileName: _currentList[index],
                            isSelected: _selectedIndex == index,
                            onTap: () {
                              setState(() {
                                _selectedIndex = index;
                              });
                            },
                          );
                        },
                      ),
              ),
            ),

            const SizedBox(height: 16.0),

            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: OutlinedButton.icon(
                    onPressed: isActionEnabled ? _onDeletePressed : null,
                    icon: const Icon(Icons.delete_outline_rounded, size: 20),
                    label: const Text('Delete'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      disabledForegroundColor: Colors.white24,
                      side: BorderSide(
                        color: isActionEnabled ? Colors.redAccent.withAlpha(128) : Colors.white12,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12.0),

                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: isActionEnabled ? _onLoadPressed : null,
                    icon: const Icon(Icons.download_rounded, size: 20),
                    label: const Text('Load'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.buttonColor,
                      disabledBackgroundColor: Colors.white10,
                      foregroundColor: Colors.white,
                      disabledForegroundColor: Colors.white38,
                      padding: const EdgeInsets.symmetric(vertical: 14.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}