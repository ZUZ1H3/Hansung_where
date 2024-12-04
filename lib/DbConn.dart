import 'package:mysql_client/mysql_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'Post.dart'; // Post 모델 임포트
import 'Comment.dart';
import 'NoticePost.dart'; // Post 모델 임포트
import 'Report.dart';
class DbConn {
  static MySQLConnection? _connection;

  // 데이터베이스 연결
  static Future<MySQLConnection> getConnection() async {
    if (_connection == null || !_connection!.connected) {
      print("Connecting to MySQL server...");

      await dotenv.load(); // 환경 변수 로드

      _connection = await MySQLConnection.createConnection(
        host: dotenv.env['db.host']!,
        port: 3306,
        userName: dotenv.env['db.user']!,
        password: dotenv.env['db.password']!,
        databaseName: dotenv.env['db.name']!,
      );
      await _connection!.connect();
    }
    return _connection!;
  }

  // 연결 종료
  static Future<void> closeConnection() async {
    if (_connection != null && _connection!.connected) {
      await _connection!.close();
      _connection = null;
      print("MySQL 연결 종료");
    }
  }

  // 사용자 정보 저장
  static Future<void> saveUser(String studentId) async {
    final conn = await getConnection();
    const profileId = 1; // 기본 프로필 ID

    try {
      // 학생 ID 확인
      final results = await conn.execute(
        'SELECT COUNT(*) AS count FROM users WHERE student_id = :studentId',
        {'studentId': studentId},
      );

      final count = results.rows.first.assoc()['count'];
      if (count == '0') {
        String nickname;
        bool isUnique;

        // 닉네임 중복 확인
        do {
          final randomNum =
          (1 + (999 - 1) * (DateTime.now().millisecondsSinceEpoch % 1000))
              .toString();
          nickname = '부기$randomNum';
          final nicknameResults = await conn.execute(
            'SELECT COUNT(*) AS count FROM users WHERE nickname = :nickname',
            {'nickname': nickname},
          );

          isUnique = nicknameResults.rows.first.assoc()['count'] == '0';
        } while (!isUnique);

        // 사용자 정보 삽입
        await conn.execute(
          'INSERT INTO users (student_id, nickname, profile) VALUES (:studentId, :nickname, :profileId)',
          {
            'studentId': studentId,
            'nickname': nickname,
            'profileId': profileId
          },
        );
      }

      print("사용자 정보 저장 완료");
    } catch (e) {
      print("Error in saveUser: $e");
    }
  }

  // 닉네임 가져오기
  static Future<String?> getNickname(String studentId) async {
    final connection = await getConnection();
    try {
      final result = await connection.execute(
        'SELECT nickname FROM users WHERE student_id = :studentId',
        {'studentId': studentId},
      );
      if (result.rows.isNotEmpty) {
        return result.rows.first.assoc()['nickname'];
      }
    } catch (e) {
      print("Error fetching nickname: $e");
    }
    return null;
  }

  // 닉네임 업데이트
  static Future<bool> updateNickname(
      String studentId, String newNickname) async {
    final connection = await getConnection();
    try {
      final result = await connection.execute(
        'UPDATE users SET nickname = :newNickname WHERE student_id = :studentId',
        {'newNickname': newNickname, 'studentId': studentId},
      );
      return result.affectedRows > BigInt.zero;
    } catch (e) {
      print("Error updating nickname: $e");
    }
    return false;
  }

  // 닉네임 중복 확인
  static Future<bool> checkNickname(String nickname) async {
    final connection = await getConnection();
    try {
      final result = await connection.execute(
        'SELECT COUNT(*) AS count FROM users WHERE nickname = :nickname',
        {'nickname': nickname},
      );
      final count = result.rows.first.assoc()['count'];
      return count == '0'; // 중복된 닉네임이 없으면 true 반환
    } catch (e) {
      print("Error checking nickname uniqueness: $e");
      return false;
    }
  }

  // 프로필 ID 가져오기
  static Future<int> getProfileId(String studentId) async {
    final connection = await getConnection();
    try {
      final result = await connection.execute(
        'SELECT profile FROM users WHERE student_id = :studentId',
        {'studentId': studentId},
      );
      if (result.rows.isNotEmpty) {
        return int.parse(result.rows.first.assoc()['profile'] ?? '0');
      }
    } catch (e) {
      print("Error fetching profile ID: $e");
    }
    return 1; // 기본값
  }

  // 프로필 업데이트
  static Future<bool> updateProfile(String studentId, int newProfileId) async {
    final connection = await getConnection();
    try {
      final result = await connection.execute(
        'UPDATE users SET profile = :newProfileId WHERE student_id = :studentId',
        {'newProfileId': newProfileId, 'studentId': studentId},
      );
      return result.affectedRows > BigInt.zero;
    } catch (e) {
      print("Error updating profile: $e");
    }
    return false;
  }

  // 게시물 저장
  static Future<bool> savePost({
    required String title,
    required String body,
    required int userId,
    String? imageUrl1,
    String? imageUrl2,
    String? imageUrl3,
    String? imageUrl4,
    required String type,
    required String? place,
    required String? thing,
  }) async {
    final connection = await getConnection();
    try {
      // SQL 쿼리 실행
      final result = await connection.execute(
        '''
        INSERT INTO posts (title, body, user_id, image_url1, image_url2, image_url3, image_url4, type, place_keyword, thing_keyword) 
        VALUES (:title, :body, :userId, :imageUrl1, :imageUrl2, :imageUrl3, :imageUrl4, :type, :place, :thing)
        ''',
        {
          'title': title,
          'body': body,
          'userId': userId,
          'imageUrl1': imageUrl1,
          'imageUrl2': imageUrl2,
          'imageUrl3': imageUrl3,
          'imageUrl4': imageUrl4,
          'type': type,
          'place': place,
          'thing': thing,
        },
      );

      // 성공 여부 반환
      return result.affectedRows > BigInt.zero;
    } catch (e) {
      print("Error saving post: $e");
      return false;
    }
  }

  //장소 별 found 게시물 수를 가져옴(지도에서 사용)
  static Future<int> getFoundPostCount(String placeKeyword) async {
    final connection = await getConnection();
    try {
      final result = await connection.execute(
        '''
        SELECT COUNT(*) AS count 
        FROM posts 
        WHERE type = 'found' 
        AND place_keyword = :placeKeyword
        AND created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)
      ''',
        {'placeKeyword': placeKeyword},
      );
      return int.parse(result.rows.first.assoc()['count'] ?? '0');
    } catch (e) {
      print("Error fetching found post count: $e");
      return 0;
    }
  }

  //게시물 가져오기
  static Future<List<Post>> fetchPosts({
    required String type,
    String? placeKeyword,
    String? thingKeyword,
  }) async {
    final connection = await getConnection(); // 연결 유지
    List<Post> posts = [];

    try {
      String sql = '''
    SELECT 
      post_id,
      title, 
      body, 
      created_at, 
      user_id,
      image_url1, 
      place_keyword, 
      thing_keyword 
    FROM 
      posts 
    WHERE 
      type = :type
    ''';

      if (placeKeyword != null) {
        sql += " AND place_keyword = :placeKeyword";
      }
      if (thingKeyword != null) {
        sql += " AND thing_keyword = :thingKeyword";
      }

      sql += " ORDER BY created_at DESC";

      final results = await connection.execute(sql, {
        'type': type,
        if (placeKeyword != null) 'placeKeyword': placeKeyword,
        if (thingKeyword != null) 'thingKeyword': thingKeyword,
      });

      for (final row in results.rows) {
        final rawCreatedAt = row.assoc()['created_at'];
        final relativeTime = _calculateRelativeTime(rawCreatedAt);

        posts.add(Post(
          postId: int.tryParse(row.assoc()['post_id']?.toString() ?? '') ?? 0,
          title: row.assoc()['title'] ?? '',
          body: row.assoc()['body'] ?? '',
          createdAt: relativeTime,
          // 상대적 시간으로 변환된 값 사용
          userId: int.tryParse(row.assoc()['user_id']?.toString() ?? '') ?? 0,
          imageUrl1: row.assoc()['image_url1'],
          place: row.assoc()['place_keyword'],
          thing: row.assoc()['thing_keyword'],
        ));
      }
    } catch (e) {
      print('Error fetching posts: $e');
    }

    return posts; // 연결을 닫지 않고 재사용
  }

  static String _calculateRelativeTime(String? createdAt) {
    if (createdAt == null) return '';
    final createdAtDate = DateTime.parse(createdAt);
    final now = DateTime.now();
    final difference = now.difference(createdAtDate);

    if (difference.inMinutes < 1) {
      return '방금 전';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}시간 전';
    } else {
      return '${difference.inDays}일 전';
    }
  }

  // postId로 게시물 내용 가져오기
  static Future<Map<String, dynamic>?> getPostById(int postId) async {
    final connection = await getConnection();
    try {
      // execute로 SELECT 쿼리 실행
      final result = await connection.execute(
        '''
      SELECT *
      FROM posts 
      WHERE post_id = :postId
      ''',
        {'postId': postId},
      );

      // 결과가 없다면 null 반환
      if (result.rows.isEmpty) return null;

      // 첫 번째 행 가져오기
      final row = result.rows.first.assoc();

      // 생성 날짜 포맷팅 MM/DD HH:MM 형식으로
      if (row['created_at'] != null) {
        row['created_at'] = _formatDate(row['created_at']);
      }

      // 결과가 있다면 한 줄로 반환
      return row.map((key, value) => MapEntry(
        key,
        value ??
            (['title', 'body', 'created_at'].contains(key) ? '' : null),
      ));
    } catch (e) {
      print("Error retrieving post: $e");
      return null;
    }
  }

  //공지사항을 저장
  static Future<bool> saveNoticePost({
    required String title,
    required String body,
    required int managerId,
  }) async {
    final connection = await getConnection();
    try {
      // SQL 쿼리 실행
      final result = await connection.execute(
        '''
        INSERT INTO notices (title, body, manager_id) 
        VALUES (:title, :body, :managerId)
        ''',
        {
          'title': title,
          'body': body,
          'managerId': managerId,
        },
      );

      // 성공 여부 반환
      return result.affectedRows > BigInt.zero;
    } catch (e) {
      print("Error saving notice post: $e");
      return false;
    }
  }

  // 날짜를 MM/dd HH:mm 형식으로 포맷
  static String _formatDate(dynamic createdAt) {
    if (createdAt == null) return '';

    try {
      DateTime parsedDate;

      if (createdAt is int) {
        // Unix timestamp를 DateTime으로 변환
        parsedDate = DateTime.fromMillisecondsSinceEpoch(createdAt * 1000);
      } else if (createdAt is String) {
        // ISO 8601 문자열을 DateTime으로 변환
        parsedDate = DateTime.parse(createdAt);
      } else {
        return ''; // 처리할 수 없는 형식
      }

      // MM/dd HH:mm 형식으로 변환
      return '${parsedDate.month.toString().padLeft(2, '0')}/${parsedDate.day.toString().padLeft(2, '0')} ${parsedDate.hour.toString().padLeft(2, '0')}:${parsedDate.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      print("Error formatting date: $e");
      return '';
    }
  }

  // 공통 MySQL 실행 유틸리티
  static Future<List<Map<String, dynamic>>> executeQuery(
      String query, [
        Map<String, dynamic>? params,
      ]) async {
    final connection = await getConnection();
    try {
      final result = await connection.execute(query, params ?? {});
      return result.rows.map((row) => row.assoc()).toList();
    } catch (e) {
      print("MySQL Query Error: $e");
      return [];
    }
  }

  // 공통 MySQL 변경 유틸리티
  static Future<int> executeUpdate(
      String query, [
        Map<String, dynamic>? params,
      ]) async {
    final connection = await getConnection();
    try {
      final result = await connection.execute(query, params ?? {});
      return result.affectedRows.toInt();
    } catch (e) {
      print("MySQL Update Error: $e");
      return 0;
    }
  }
  
  // 실시간 검색어 관리
  static Future<void> saveSearchKeyword(String keyword) async {
    final query = '''
      INSERT INTO search_keywords (keyword, count, updated_at)
      VALUES (:keyword, 1, NOW())
      ON DUPLICATE KEY UPDATE count = count + 1, updated_at = NOW()
    ''';
    await executeUpdate(query, {'keyword': keyword});
  }

  static Future<List<String>> getTopSearchKeywords({int limit = 5}) async {
    final query = '''
      SELECT keyword 
      FROM search_keywords 
      ORDER BY count DESC 
      LIMIT :limit
    ''';
    final results = await executeQuery(query, {'limit': limit});
    return results.map((row) => row['keyword'] as String).toList();
  }

  // 댓글 저장하기
  static Future<bool> saveComment({
    required int postId,
    required int userId,
    required String body,
    required String type,
    int? parentCommentId,
  }) async {
    final connection = await getConnection();
    bool success = false;

    try {
      var result = await connection.execute(
        '''
        INSERT INTO comments (post_id, user_id, body, type, parent_comment_id) 
        VALUES (:postId, :userId, :body, :type, :parentCommentId)
        ''',
        {
          'postId': postId,
          'userId': userId,
          'body': body,
          'type': type,
          'parentCommentId': parentCommentId,
        },
      );

      return result.affectedRows > BigInt.zero;
    } catch (e) {
      print('DB 연결 실패: $e');
    } finally {
      await connection.close();
    }

    return false;
  }

  // 댓글 가져오기
  static Future<List<Comment>> fetchComments({
    required int postId,
  }) async {
    final connection = await getConnection();
    List<Comment> comments = [];
    Map<int, List<Comment>> groupedComments = {}; // 댓글 그룹화 위한 맵

    try {
      final result = await connection.execute(
        '''
      SELECT *
      FROM comments 
      WHERE post_id = :postId
      ''',
        {'postId': postId},
      );

      for (final row in result.rows) {
        final rawCreatedAt = row.assoc()['created_at'];
        final formattedCreatedAt =
        rawCreatedAt != null ? _formatDate(rawCreatedAt) : '';

        final comment = Comment(
          commentId:
          int.tryParse(row.assoc()['comment_id']?.toString() ?? '') ?? 0,
          postId: int.tryParse(row.assoc()['post_id']?.toString() ?? '') ?? 0,
          userId: int.tryParse(row.assoc()['user_id']?.toString() ?? '') ?? 0,
          body: row.assoc()['body'] ?? '',
          createdAt: formattedCreatedAt,
          type: row.assoc()['type'] ?? '',
          parentCommentId: row.assoc()['parent_comment_id'] != null
              ? int.tryParse(row.assoc()['parent_comment_id']?.toString() ?? '')
              : null,
        );

        // userId로 닉네임을 가져와서 댓글에 추가
        final nickname = await getNickname(comment.userId.toString());
        comment.nickname = nickname;

        comments.add(comment);

        // parent_comment_id에 따른 그룹화
        if (comment.parentCommentId != null) {
          if (!groupedComments.containsKey(comment.parentCommentId)) {
            groupedComments[comment.parentCommentId!] = [];
          }
          groupedComments[comment.parentCommentId!]!.add(comment);
        }
      }
    } catch (e) {
      print('Error fetching comments: $e');
    }

    // 댓글을 그룹화된 형태로 반환
    return comments;
  }

  // 공지사항 가져오기
  static Future<List<NoticePost>> fetchNoticePosts() async {
    final connection = await getConnection(); // MySQL 연결
    List<NoticePost> noticePosts = [];

    try {
      // notices 테이블에서 데이터를 가져오는 SQL 쿼리 실행
      final results = await connection.execute('''
      SELECT notice_id, title, body, created_at, manager_id
      FROM notices
      ORDER BY created_at DESC
      ''');

      for (final row in results.rows) {
        noticePosts.add(NoticePost(
          noticeId: int.tryParse(row.assoc()['notice_id'] ?? '0') ?? 0,
          title: row.assoc()['title'] ?? '',
          body: row.assoc()['body'] ?? '',
          createdAt: _calculateRelativeTime(row.assoc()['created_at']),
          // 상대 시간으로 변환
          managerId: int.tryParse(row.assoc()['manager_id'] ?? '0'),
        ));
      }
    } catch (e) {
      print("Error fetching notice posts: $e");
    }

    return noticePosts;
  }

  static Future<Map<String, dynamic>?> getNoticePostById(int noticeId) async {
    final connection = await getConnection();
    try {
      print("Fetching notice with ID: $noticeId"); // 디버깅 로그 추가

      final result = await connection.execute(
        '''
      SELECT 
        n.notice_id,
        n.title,
        n.body,
        n.created_at,
        u.student_id AS manager_id
      FROM 
        notices n
      LEFT JOIN 
        users u ON n.manager_id = u.student_id
      WHERE 
        n.notice_id = :noticeId
      ''',
        {'noticeId': noticeId},
      );

      if (result.rows.isEmpty) {
        print('No data found for noticeId: $noticeId'); // 디버깅 로그
        return null;
      }

      final row = result.rows.first.assoc();

      print('Fetched row: $row'); // 디버깅 로그

      if (row['created_at'] != null) {
        row['created_at'] = _formatDate(row['created_at']); // 날짜 포맷팅
      }

      return row.map((key, value) => MapEntry(
        key,
        value ?? '',
      ));
    } catch (e) {
      print("Error retrieving notice by ID: $e"); // 디버깅 로그
      return null;
    }
  }

  // 최신 공지사항 가져오기
  static Future<NoticePost?> fetchLatestNoticePosts() async {
    final connection = await getConnection();
    try {
      final result = await connection.execute(
          '''
      SELECT notice_id, title, body, created_at, manager_id 
      FROM notices 
      ORDER BY created_at DESC 
      LIMIT 1
      '''
      );

      if (result.rows.isNotEmpty) {
        final row = result.rows.first.assoc();
        return NoticePost(
          noticeId: int.tryParse(row['notice_id'] ?? '0') ?? 0,
          title: row['title'] ?? '',
          body: row['body'] ?? '',
          createdAt: _calculateRelativeTime(row['created_at']),
          managerId: int.tryParse(row['manager_id'] ?? '0'),
        );
      }
    } catch (e) {
      print('Error fetching latest notice: $e');
    }
    return null;
  }

  // 게시물 삭제
  static Future<void> deletePostById({required int postId}) async {
    final connection = await getConnection();

    try {
      await connection.execute(
        '''
      DELETE FROM posts
      WHERE post_id = :postId
      ''',
        {'postId': postId},
      );
      print('게시물 삭제 성공');
    } catch (e) {
      print('게시물 삭제 오류: $e');
    }
  }
  // 댓글 삭제
  static Future<void> deleteCommentById({required int commentId}) async {
    final connection = await getConnection();

    try {
      await connection.execute(
        '''
      DELETE FROM comments
      WHERE comment_id = :commentId
      ''',
        {'commentId': commentId},
      );
      print('댓글 삭제 성공');
    } catch (e) {
      print('댓글 삭제 오류: $e');
    }
  }

  // 게시물 타입 알아내기
  static Future<String?> fetchTypeById({required int postId}) async {
    final connection = await getConnection();
    try {
      final result = await connection.execute(
        '''
          SELECT type 
          FROM posts 
          WHERE post_id = ?
          ''',
        {'postId': postId},
      );

      if (result.rows.isNotEmpty) {
        final row = result.rows.first.assoc();
        return row['type']; // 예: 'notice', 'blog', 'article' 등의 값
      }
    } catch (e) {
      print('가져오기 실패: $e');
    }
    return null;
  }


  //신고내역을 저장함
  static Future<bool> saveReport({
    required int userId, // 신고된 사용자
    int? reportId, // 게시글 ID
    required String reason, // 신고 사유
    required String type, // 신고된 유형 ('post', 'comment', 'reply')
  }) async {
    final connection = await getConnection();
    bool success = false;

    try {
      // 게시글과 댓글 중 하나는 NULL로 저장되므로, 둘 중 하나는 항상 비어있게 됩니다.
      var result = await connection.execute(
        '''
      INSERT INTO reports (user_id, report_id, reason, type)
      VALUES (:userId, :reportId, :reason, :type)
      ''',
        {
          'userId': userId,
          'reportId': reportId,
          'reason': reason,
          'type': type
        },
      );

      success = result.affectedRows > BigInt.zero;
    } catch (e) {
      print('DB 연결 실패: $e');
    } finally {
      await connection.close();
    }
    return success;
  }

  // 신고 내역 가져오기
  static Future<List<Report>> getReports() async {
    final connection = await getConnection(); // MySQL 연결
    List<Report> reports = [];

    try {
      // reports 테이블에서 데이터를 가져오는 SQL 쿼리 실행
      final results = await connection.execute('''
      SELECT id, user_id, report_id, reason, reported_at, type
      FROM reports
      ORDER BY reported_at DESC
    ''');

      // 결과를 반복하며 Report 객체 리스트로 변환
      for (final row in results.rows) {
        reports.add(Report(
          id: int.tryParse(row.assoc()['id'] ?? '0') ?? 0,
          userId: int.tryParse(row.assoc()['user_id'] ?? '0') ?? 0,
          reportId: int.parse(row.assoc()['report_id']!),
          reason: row.assoc()['reason'] ?? '',
          reportedAt: row.assoc()['reported_at'] ?? '',
          type: row.assoc()['type'] ?? '',
        ));
      }
    } catch (e) {
      print("Error fetching reports: $e");
    } finally {
      // 연결 닫기
      await connection.close();
    }

    return reports;
  }

  // 댓글 단 글 가제랴기
  static Future<List<Post>> fetchPostsWithMyComments({
    required int userId,
    String? postType, // 선택적으로 postType 추가
  }) async {
    final connection = await getConnection(); // MySQL 연결
    List<Post> posts = [];

    try {
      // 댓글 단 게시물 가져오는 SQL 쿼리
      String sql = '''
      SELECT DISTINCT p.post_id, p.title, p.body, p.created_at, 
                      p.user_id, p.image_url1, p.place_keyword, p.thing_keyword
      FROM posts p
      INNER JOIN comments c ON p.post_id = c.post_id
      WHERE c.user_id = :userId
    ''';

      // postType 필터링 추가
      if (postType != null) {
        sql += " AND p.type = :postType";
      }

      sql += " ORDER BY p.created_at DESC";

      final results = await connection.execute(sql, {
        'userId': userId,
        if (postType != null) 'postType': postType,
      });

      for (final row in results.rows) {
        posts.add(Post(
          postId: int.parse(row.assoc()['post_id'] ?? '0'),
          title: row.assoc()['title'] ?? '',
          body: row.assoc()['body'] ?? '',
          createdAt: _calculateRelativeTime(row.assoc()['created_at']),
          userId: int.parse(row.assoc()['user_id'] ?? '0'),
          imageUrl1: row.assoc()['image_url1'],
          place: row.assoc()['place_keyword'],
          thing: row.assoc()['thing_keyword'],
        ));
      }
    } catch (e) {
      print("Error fetching posts with my comments: $e");
    }

    return posts;
  }
}