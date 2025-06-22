// ignore_for_file: file_names, depend_on_referenced_packages

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class CustomUploadButton extends StatefulWidget {
  final String label;
  final String subLabel;
  final double width;
  final double height;
  final String fileName;
  final Function(File?) onFileSelected;

  const CustomUploadButton({
    super.key,
    required this.label,
    required this.subLabel,
    required this.width,
    required this.height,
    required this.fileName,
    required this.onFileSelected,
  });

  @override
  State<CustomUploadButton> createState() => _CustomUploadButtonState();
}

class _CustomUploadButtonState extends State<CustomUploadButton> {
  File? selectedFile;

  Future<void> _loadCachedFile() async {
    final cacheDir = await getTemporaryDirectory();
    final filePath = path.join(cacheDir.path, widget.fileName);
    final file = File(filePath);
    if (await file.exists()) {
      setState(() => selectedFile = file);
      widget.onFileSelected(file);
    }
  }

  Future<void> _pickAndCacheFile() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.image,
    );

    if (result != null && result.files.isNotEmpty) {
      final pickedFile = result.files.first;
      final bytes = pickedFile.bytes;

      final cacheDir = await getTemporaryDirectory();
      final filePath = path.join(cacheDir.path, widget.fileName);

      if (bytes != null) {
        final file = File(filePath);
        await file.writeAsBytes(bytes);
        setState(() => selectedFile = file);
        widget.onFileSelected(file);
      } else if (pickedFile.path != null) {
        final originalFile = File(pickedFile.path!);
        final cachedFile = await originalFile.copy(filePath);
        setState(() => selectedFile = cachedFile);
        widget.onFileSelected(cachedFile);
      }
    }
  }

  void _showOptionsDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text("Preview"),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (_) =>
                      AlertDialog(content: Image.file(selectedFile!)),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text("Remove"),
              onTap: () {
                Navigator.pop(context);
                setState(() => selectedFile = null);
                widget.onFileSelected(null);
              },
            ),
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text("Replace"),
              onTap: () {
                Navigator.pop(context);
                _pickAndCacheFile();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _loadCachedFile();
  }

  @override
  Widget build(BuildContext context) {
    double width = widget.width;
    double height = widget.height;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width / 20),
      child: selectedFile == null
          ? ElevatedButton(
              onPressed: _pickAndCacheFile,
              style: ElevatedButton.styleFrom(
                fixedSize: Size(width / 1.15, height * 0.12),
                backgroundColor: const Color.fromRGBO(194, 182, 189, 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(width / 1.9),
                ),
                elevation: 0,
                shadowColor: Colors.transparent,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(width: width / 18),
                  Icon(
                    Icons.camera_alt_outlined,
                    color: Colors.black,
                    size: width / 14,
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          widget.label,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: width / 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          widget.subLabel,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: width / 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: width / 8),
                ],
              ),
            )
          : Column(
              children: [
                GestureDetector(
                  onTap: _showOptionsDialog,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      selectedFile!,
                      width: width / 2.2,
                      height: height * 0.12,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 4),
                SizedBox(
                  width: width / 2.2,
                  child: Text(
                    path.basename(selectedFile!.path),
                    style: const TextStyle(fontSize: 10),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
    );
  }
}
