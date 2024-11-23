import 'package:flutter/material.dart';
import 'dart:io';

class CommentInput extends StatelessWidget {
  final String? name;
  final String? avatarUrl;
  final int selectedRating;
  final Function(int) onRatingSelected;
  final TextEditingController commentController; 
  final List<String> imagePaths;
  final Function(String) onDeleteImage; // Callback xử lý khi xóa ảnh
  final Function() onUploadImage;
  final bool isLoading;
  final Function() onSubmitComment;

  const CommentInput({
    Key? key,
    this.name,
    this.avatarUrl,
    required this.selectedRating,
    required this.onRatingSelected,
    required this.commentController,
    required this.imagePaths,
    required this.onDeleteImage, 
    required this.onUploadImage,
    required this.isLoading,
    required this.onSubmitComment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hiển thị avatar và tên người dùng
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: avatarUrl != null
                      ? NetworkImage(avatarUrl!)
                      : null,
                  child: avatarUrl == null
                      ? const Icon(Icons.person, size: 40)
                      : null,
                ),
                const SizedBox(width: 10),
                Text(name ?? 'Anonymous', style: const TextStyle(fontSize: 18)),
              ],
            ),
            const SizedBox(height: 10),
            // Hiển thị 5 icon ngôi sao để người dùng đánh giá
            Row(
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < selectedRating
                        ? Icons.star
                        : Icons.star_border,
                    color: index < selectedRating ? Colors.orange : Colors.grey,
                  ),
                  onPressed: () {
                    onRatingSelected(index + 1); // Truyền giá trị đánh giá
                  },
                );
              }),
            ),
            const SizedBox(height: 10),
            // Mô tả bình luận
            TextField(
              controller: commentController, // Hiển thị nội dung cũ
              decoration: const InputDecoration(
                hintText: 'Write your comment...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 10),
            // Upload ảnh
            ElevatedButton(
              onPressed: isLoading ? null : onUploadImage,
              child: Text(isLoading ? 'Processing...' : 'Upload Image'),
            ),
            if (imagePaths.isNotEmpty)
              Wrap(
                spacing: 8.0,
                children: imagePaths.map((path) {
                  return Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Image.file(
                        File(path),
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.red),
                        onPressed: () {
                          onDeleteImage(path); // Gọi callback để xử lý xóa ảnh
                        },
                      ),
                    ],
                  );
                }).toList(),
              ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: onSubmitComment,
              child: const Text('Submit Comment'),
            ),
          ],
        ),
      ),
    );
  }
}
