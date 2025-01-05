import 'package:flutter/material.dart';

import '../models/comment.dart';
import '../widgets/editCommentDialog.dart';

class CommentCard extends StatelessWidget {
  final Comment comment;
  final String baseURL;
  final String? currentUsername; // Username của người dùng hiện tại
  final Future<void> Function(Comment)
      onDeleteComment; // Callback cho xóa bình luận
  final void Function(Comment) onUpdateComment;
  const CommentCard({
    super.key,
    required this.comment,
    required this.baseURL,
    this.currentUsername,
    required this.onDeleteComment,
    required this.onUpdateComment,
  });

  // Hàm định dạng ngày tháng
  String formatDate(String date) {
    final parsedDate = DateTime.parse(date);
    return '${parsedDate.day}/${parsedDate.month}/${parsedDate.year}';
  }

  @override
  Widget build(BuildContext context) {
    final List<CommentImage> images = comment.listImg;
    final String formattedDate = formatDate(comment.updatedAt);
    final bool isOwner =
        currentUsername != null && comment.username == currentUsername;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text(comment.username ?? 'Anonymous'),
              subtitle: Text(comment.content),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${comment.star} ⭐'),
                  if (isOwner) // Hiển thị nút tùy chỉnh nếu là chủ sở hữu
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          // onEditComment(comment);
                          showDialog(
                            context: context,
                            builder: (context) => EditCommentWithImageDialog(
                              comment: comment,
                              baseURL: baseURL,
                              onUpdateComment: onUpdateComment,
                            ),
                          );
                        } else if (value == 'delete') {
                          onDeleteComment(comment);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('Edit'),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Hiển thị ngày cập nhật
            Text(
              formattedDate,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            // Hiển thị hình ảnh
            images.isNotEmpty
                ? Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: images.asMap().entries.map((entry) {
                      final index = entry.key;
                      final image = entry.value;
                      final imageUrl = image.image;
                      if (index == 3 && images.length > 4) {
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.network(
                              imageUrl,
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                            ),
                            Container(
                              width: 70,
                              height: 70,
                              color: Colors.black54,
                              alignment: Alignment.center,
                              child: Text(
                                '+${images.length - 3}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                      if (index < 4) {
                        return Image.network(
                          imageUrl,
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                        );
                      }

                      return const SizedBox
                          .shrink(); // Không hiển thị ảnh sau ảnh thứ 4
                    }).toList(),
                  )
                : const Text(
                    'No images available',
                    style: TextStyle(color: Colors.grey),
                  ),
          ],
        ),
      ),
    );
  }
}
