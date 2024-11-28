import 'package:flutter/material.dart';
import '../Post.dart';
import 'package:flutter/material.dart';

class PostCard extends StatelessWidget {
  final Post post;

  const PostCard({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: Colors.blue.shade100, width: 1.5),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 텍스트와 태그를 포함한 왼쪽 영역
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제목
                  Text(
                    post.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),

                  // 태그 (장소 및 사물)
                  Wrap(
                    spacing: 8.0,
                    children: [
                      if (post.place != null)
                        Chip(
                          label: Text(
                            '#${post.place}',
                            style: TextStyle(fontSize: 12),
                          ),
                          backgroundColor: Colors.grey.shade200,
                        ),
                      if (post.thing != null)
                        Chip(
                          label: Text(
                            '#${post.thing}',
                            style: TextStyle(fontSize: 12),
                          ),
                          backgroundColor: Colors.grey.shade200,
                        ),
                    ],
                  ),
                  const SizedBox(height: 8.0),

                  // 작성 시간 및 추가 정보
                  Text(
                    '${post.createdAt} | 학생',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            // 오른쪽 이미지
            if (post.imageUrl1 != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  post.imageUrl1!,
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 70,
                      height: 70,
                      color: Colors.grey.shade300,
                      child: Icon(Icons.image_not_supported, color: Colors.grey),
                    );
                  },
                ),
              )
            else
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Icon(Icons.image_not_supported, color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }
}
