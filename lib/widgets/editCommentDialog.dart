import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/comment.dart';
import 'package:flutterApp/helper/image_utils.dart'; 
import 'package:flutterApp/services/commentService.dart';

class EditCommentWithImageDialog extends StatefulWidget {
  Comment comment;
  final String baseURL;
  final void Function(Comment) onUpdateComment;

  EditCommentWithImageDialog({
    super.key,
    required this.comment,
    required this.baseURL,
    required this.onUpdateComment,
  });

  @override
  State<EditCommentWithImageDialog> createState() =>
      _EditCommentWithImageDialogState();
}

class _EditCommentWithImageDialogState
  extends State<EditCommentWithImageDialog> {
  late int starRating;
  late String content;
  List<String> imagePaths = [];
  List<String> replaceImageId = [];
  List<XFile> newImages = [];
  final CommentService _commentService = CommentService();

  @override
  void initState() {
    super.initState();
    starRating = widget.comment.star;
    content = widget.comment.content;
    imagePaths = widget.comment.listImg
        .map((image) => '${widget.baseURL}${image.image}')
        .toList();
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final validationError = await validateImage(image);
      if (validationError != null) {
        showErrorDialog(context,validationError);
        return; // Không thêm ảnh nếu không hợp lệ 
      }
      setState(() {
        newImages.add(image);
      });
    }
  }

  void removeImage(String path, String? id) {
    setState(() {
      imagePaths.remove(path);
      if (id != null) replaceImageId.add(id);
    });
  }

  void removeNewImage(XFile image) {
    setState(() {
      newImages.remove(image);
    });
  }

  void updateComment() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
      final newImagePaths = newImages.map((image) => image.path).toList();
      final updatedComment = await _commentService.updateComment(
        id: widget.comment.id, // ID của bình luận
        star: starRating, // Số sao mới
        content: content, // Nội dung bình luận
        replaceImageIds: replaceImageId, // Danh sách ảnh cần thay thế
        newImagePaths: newImagePaths, // Ảnh mới
      );

      widget.onUpdateComment(updatedComment);
      setState(() {
        // Cập nhật lại comment
        widget.comment = widget.comment.copyWith(
          star: updatedComment.star,
          content: updatedComment.content,
          listImg: updatedComment.listImg,
        );
      });

      // Đảm bảo dialog sẽ được đóng ngay lập tức sau khi cập nhật hoàn tất
      Navigator.pop(context); // Đóng dialog
      Navigator.pop(context); 
      // Hiển thị thông báo thành công
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comment updated successfully')),
      );
    } catch (e) {
      // Đóng dialog khi có lỗi
      Navigator.pop(context);
      print('Error updating comment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update comment')),
      );
    }
  }
  
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
      FocusScope.of(context).unfocus();
      },
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < starRating
                            ? Icons.star
                            : Icons.star_border_outlined,
                        color: Colors.amber,
                      ),
                      onPressed: () {
                        setState(() {
                          starRating = index + 1;
                        });
                      },
                    );
                  }),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: TextEditingController(text: content),
                  onChanged: (value) {
                    content = value;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Edit Comment',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                // Ảnh đính kèm
                const Text('Attached Images:'),
                const SizedBox(height: 16),
                if (imagePaths.isNotEmpty)
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: widget.comment.listImg.map((image) {
                      final path = '${widget.baseURL}${image.image}';
                      return Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border:
                                  Border.all(color: Colors.grey.shade300),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                path,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => removeImage(path, image.id),
                              child: const Icon(Icons.close,
                                  color: Colors.red, size: 20),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  )
                else
                  const Text(
                    'No images available',
                    style: TextStyle(color: Colors.grey),
                  ),
                const SizedBox(height: 16),
                // Ảnh mới
                if (newImages.isNotEmpty)
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: newImages.map((image) {
                      return Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                File(image.path),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => removeNewImage(image),
                              child: const Icon(Icons.close,
                                  color: Colors.red, size: 20),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: pickImage,
                  child: const Text('Upload Image'),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: updateComment,
                      child: const Text('Update'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
