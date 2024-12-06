import 'package:mysql_client/mysql_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Post.dart'; // Post 모델 임포트
import 'Comment.dart';
import 'NoticePost.dart'; // Post 모델 임포트
import 'Report.dart';
import 'Message.dart';
import 'local_push_notification.dart';

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
          displayTime: relativeTime,
          createdAt: DateTime.parse(row.assoc()['created_at'] ?? DateTime.now().toString()),
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

  // postId로 게시물 제목 가져오기
  static Future<String?> getPostTitleById({required int postId}) async {
    final connection = await getConnection();
    try {
      // execute로 SELECT 쿼리 실행
      final result = await connection.execute(
        '''
      SELECT title
      FROM posts 
      WHERE post_id = :postId
      ''',
        {'postId': postId},
      );

      if (result.rows.isNotEmpty) {
        return result.rows.first.assoc()['title']; // 결과를 Map 형태로 추출
      }
    } catch (e) {
      print("제목 추출 실패: $e");
    } finally {
      await connection.close(); // 연결 닫기
    }
    return null; // 결과가 없을 경우 null 반환
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

  // 댓글 저장하기
  static Future<bool> saveComment({
    required int postId,
    required int userId,
    required String body,
    required String type,
    int? parentCommentId,
  }) async {
    final connection = await getConnection();
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
      final result = await connection.execute('''
      SELECT notice_id, title, body, created_at, manager_id 
      FROM notices 
      ORDER BY created_at DESC 
      LIMIT 1
      ''');

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

  // 신고내역 삭제
  static Future<void> deleteReportById({required int reportId}) async {
    final connection = await getConnection();

    try {
      await connection.execute(
        '''
      DELETE FROM reports
      WHERE report_id = :reportId
      ''',
        {'reportId': reportId},
      );
      print('게시물 삭제 성공');
    } catch (e) {
      print('게시물 삭제 오류: $e');
    }
  }

  //3일 정지 부여
  static Future<bool> suspendUser({
    required int userId,
    required DateTime suspendedUntil, // 정지 해제 시간
  }) async {
    final connection = await getConnection();
    bool success = false;

    try {
      print("User ID: $userId");
      final formattedDate =
          suspendedUntil.toUtc().toString().split('.').first; // 밀리초 제거

      var result = await connection.execute(
        '''
      UPDATE users
      SET suspended_until = :suspendedUntil
      WHERE student_id = :userId
      ''',
        {
          'suspendedUntil': formattedDate,
          'userId': userId,
        },
      );
      print("Suspended Until: ${formattedDate}");

      success = result.affectedRows > BigInt.zero; // 업데이트 성공 여부
    } catch (e) {
      print('3일 정지 시간 저장 실패: $e');
    } finally {
      await connection.close();
    }

    return success; // 결과 반환
  }

  //정지 여부
  static Future<String?> getUserSuspensionStatus(int userId) async {
    final connection = await getConnection();
    try {
      final result = await connection.execute(
        '''
      SELECT suspended_until 
      FROM users 
      WHERE student_id = :userId
      ''',
        {'userId': userId}, // 현재 로그인한 사용자 ID
      );

      if (result.rows.isNotEmpty) {
        final row = result.rows.first.assoc();
        return row['suspended_until']; // 정지 상태가 있으면 반환
      }
    } catch (e) {
      print('정지 상태 확인 중 오류 발생: $e');
    } finally {
      await connection.close();
    }
    return null; // 정지 상태가 없으면 null 반환
  }

  static Future<bool> updateSuspendStatus(int userId) async {
    final connection = await getConnection();
    try {
      final result = await connection.execute(
        '''UPDATE users SET suspended_until = NULL WHERE student_id = :userId''',
        {'userId': userId},
      );
      return result.affectedRows > BigInt.zero;
    } catch (e) {
      print("Error updating suspend_status: $e");
    }
    return false;
  }

  //레포트 내역으로 게시글 type 찾기
  static Future<String?> fetchTypeByReport({
    required int reportId,
    required String reportType,
  }) async {
    final connection = await getConnection();
    try {
      if (reportType == 'post') {
        // reportType이 post라면 posts 테이블에서 바로 조회
        final result = await connection.execute(
          '''
        SELECT type 
        FROM posts 
        WHERE post_id = :reportId
        ''',
          {'reportId': reportId},
        );

        if (result.rows.isNotEmpty) {
          final row = result.rows.first.assoc();
          return row['type'];
        }
      } else {
        // comments 테이블에서 post_id 조회
        final commentResult = await connection.execute(
          '''
        SELECT post_id 
        FROM comments 
        WHERE id = :reportId
        ''',
          {'reportId': reportId},
        );

        if (commentResult.rows.isNotEmpty) {
          final commentRow = commentResult.rows.first.assoc();
          final int? postId = int.tryParse(commentRow['post_id'] ?? '');

          if (postId != null) {
            final postResult = await connection.execute(
              '''
            SELECT type 
            FROM posts 
            WHERE post_id = :postId
            ''',
              {'postId': postId},
            );

            if (postResult.rows.isNotEmpty) {
              final postRow = postResult.rows.first.assoc();
              return postRow['type'];
            }
          }
        }
      }
    } catch (e) {
      print('테이블에서 type 조회 중 오류 발생: $e');
    } finally {
      await connection.close();
    }
    return null;
  }

  //레포트 내역으로 게시글 post_id 찾기
  static Future<int?> fetchPostIdByReport({
    required int reportId,
    required String reportType,
  }) async {
    final connection = await getConnection();
    try {
      if (reportType == 'post') {
        return reportId;
      } else if (reportType == 'comment' || reportType == 'reply') {
        // comments 테이블에서 post_id 조회
        final result = await connection.execute(
          '''
        SELECT post_id 
        FROM comments 
        WHERE comment_id = :reportId
        ''',
          {'reportId': reportId},
        );

        if (result.rows.isNotEmpty) {
          final row = result.rows.first.assoc();
          return int.tryParse(row['post_id'] ?? '');
        }
      } else {
        throw Exception("알 수 없는 reportType: $reportType");
      }
    } catch (e) {
      print('postId 조회 중 오류 발생: $e');
    } finally {
      await connection.close();
    }
    return null; // 데이터가 없으면 null 반환
  }

  // 채팅 메시지 저장하기
  static Future<bool> saveMessage({
    required int senderId,
    required int receiverId,
    required int postId,
    required String message,
  }) async {
    final connection = await getConnection();
    try {
      var result = await connection.execute(
        '''
        INSERT INTO messages (sender_id, receiver_id, post_id, message) 
        VALUES (:senderId, :receiverId, :postId, :message)
        ''',
        {
          'senderId': senderId,
          'receiverId': receiverId,
          'postId': postId,
          'message': message,
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

  // 채팅 메시지 가져오기
  static Future<List<Message>> fetchMessages({
    required int postId,
  }) async {
    final connection = await getConnection();
    List<Message> messages = [];

    try {
      final result = await connection.execute(
        '''
      SELECT 
        m.message_id,
        m.sender_id,
        m.post_id,
        m.receiver_id,
        m.message,
        DATE_FORMAT(m.createdAt, '%H:%i') as createdAt,
        sender.profile AS senderProfileId,
        receiver.profile AS receiverProfileId
      FROM messages m
      LEFT JOIN users sender ON m.sender_id = sender.student_id
      LEFT JOIN users receiver ON m.receiver_id = receiver.student_id
      WHERE m.post_id = :postId
      ''',
        {'postId': postId},
      );

      for (final row in result.rows) {
        final message = Message(
          messageId:
              int.tryParse(row.assoc()['message_id']?.toString() ?? '') ?? 0,
          senderId:
              int.tryParse(row.assoc()['sender_id']?.toString() ?? '') ?? 0,
          postId: int.tryParse(row.assoc()['post_id']?.toString() ?? '') ?? 0,
          receiverId:
              int.tryParse(row.assoc()['receiver_id']?.toString() ?? '') ?? 0,
          message: row.assoc()['message'] ?? '',
          createdAt: row.assoc()['createdAt'] ?? '',
          senderProfileId: row.assoc()['senderProfileId'],
          receiverProfileId: row.assoc()['receiverProfileId'],
        );
        messages.add(message);
      }
    } catch (e) {
      print('채팅 메시지 가져오기 실패: $e');
    }

    return messages;
  }

  static Future<List<Post>> fetchPostsWithMyComments({
    required int userId,
    required String postType,
  }) async {
    final connection = await getConnection();
    List<Post> posts = [];

    try {
      final query = '''
    SELECT DISTINCT 
      p.post_id, 
      p.title, 
      p.body, 
      p.created_at, 
      p.user_id, 
      p.image_url1, 
      p.place_keyword, 
      p.thing_keyword 
    FROM 
      posts p
    INNER JOIN 
      comments c ON p.post_id = c.post_id
    WHERE 
      c.user_id = :userId 
      AND p.type = :postType
    ORDER BY 
      p.created_at DESC
    ''';

      final results = await connection.execute(query, {
        'userId': userId,
        'postType': postType,
      });

      for (final row in results.rows) {
        posts.add(Post(
          postId: int.parse(row.assoc()['post_id'] ?? '0'),
          title: row.assoc()['title'] ?? '',
          body: row.assoc()['body'] ?? '',
          displayTime: _calculateRelativeTime(row.assoc()['created_at']),
          createdAt: DateTime.parse(row.assoc()['created_at'] ?? DateTime.now().toString()),
          userId: int.parse(row.assoc()['user_id'] ?? '0'),
          imageUrl1: row.assoc()['image_url1'],
          place: row.assoc()['place_keyword'],
          thing: row.assoc()['thing_keyword'],
        ));
      }
    } catch (e) {
      print('Error fetching posts with my comments: $e');
    } finally {
      await connection.close();
    }

    return posts;
  }

  // DbConn 클래스 내부에 추가
  static Future<List<String>> getTopSearchKeywords({int limit = 5}) async {
    final connection = await getConnection();
    List<String> keywords = [];

    try {
      final result = await connection.execute(
        '''
      SELECT keyword 
      FROM search_keywords 
      ORDER BY count DESC 
      LIMIT :limit
      ''',
        {'limit': limit},
      );

      for (final row in result.rows) {
        keywords.add(row.assoc()['keyword'] ?? '');
      }
    } catch (e) {
      print('Error fetching top search keywords: $e');
    } finally {
      await connection.close();
    }

    return keywords;
  }

  static Future<void> saveSearchKeyword(String keyword) async {
    final connection = await getConnection();

    try {
      await connection.execute(
        '''
      INSERT INTO search_keywords (keyword, count, updated_at) 
      VALUES (:keyword, 1, NOW()) 
      ON DUPLICATE KEY UPDATE count = count + 1, updated_at = NOW()
      ''',
        {'keyword': keyword},
      );
    } catch (e) {
      print('Error saving search keyword: $e');
    } finally {
      await connection.close();
    }
  }

  //게시물 가져오기
  static Future<List<Post>> fetchMyPosts({
    required int userId,
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
      user_id = :userId
    ORDER BY 
      created_at DESC
    ''';

      final results = await connection.execute(sql, {
        'userId': userId,
      });

      for (final row in results.rows) {
        final rawCreatedAt = row.assoc()['created_at'];
        final relativeTime = _calculateRelativeTime(rawCreatedAt);

        posts.add(Post(
          postId: int.tryParse(row.assoc()['post_id']?.toString() ?? '') ?? 0,
          title: row.assoc()['title'] ?? '',
          body: row.assoc()['body'] ?? '',
          displayTime: _calculateRelativeTime(row.assoc()['created_at']),
          createdAt: DateTime.parse(row.assoc()['created_at'] ?? DateTime.now().toString()),
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

  // 현재 접속 중인 유저 Id 가 sender_id와 동일할 때는 receiver_id 값의 users 테이블 정보를 불러오고
  // receiver_id와 동일할 때는 sender_id 값의 users 테이블 정보를 불러 옴
  static Future<List<Map<String, dynamic>>> fetchSamePostMessages(
      {required int currentStudentId}) async {
    final connection = await getConnection();
    List<Map<String, dynamic>> messages = [];

    try {
      final result = await connection.execute(
        '''
      SELECT 
          m.*,
          CASE 
              WHEN m.sender_id = :currentStudentId THEN u_receiver.nickname
              WHEN m.receiver_id = :currentStudentId THEN u_sender.nickname
          END AS nickname,
          CASE 
              WHEN m.sender_id = :currentStudentId THEN u_receiver.profile
              WHEN m.receiver_id = :currentStudentId THEN u_sender.profile
          END AS profile,
          -- 읽지 않은 메시지 개수 추가
          (SELECT COUNT(*) 
           FROM messages 
           WHERE post_id = m.post_id 
             AND receiver_id = :currentStudentId 
             AND isRead = FALSE) AS unread_count
      FROM messages m
      INNER JOIN (
          SELECT post_id, MAX(createdAt) AS latest_message_time
          FROM messages
          GROUP BY post_id
      ) latest_messages
      ON m.post_id = latest_messages.post_id AND m.createdAt = latest_messages.latest_message_time
      LEFT JOIN users u_sender ON m.sender_id = u_sender.student_id
      LEFT JOIN users u_receiver ON m.receiver_id = u_receiver.student_id
      WHERE m.sender_id = :currentStudentId OR m.receiver_id = :currentStudentId;
      ''',
        {'currentStudentId': currentStudentId},
      );

      for (final row in result.rows) {
        final message = {
          ...row.assoc(),
        };

        messages.add(message);
      }
    } catch (e) {
      print('Error fetching messages: $e');
    } finally {
      await connection.close();
    }

    return messages;
  }

  // 메시지 읽음 처리
  static Future<void> markMessagesAsRead(
      {required int currentStudentId, required int postId}) async {
    final connection = await getConnection();

    try {
      await connection.execute(
        '''
      UPDATE messages
      SET isRead = TRUE
      WHERE receiver_id = :currentStudentId AND post_id = :postId;
      ''',
        {'currentStudentId': currentStudentId, 'postId': postId},
      );
    } catch (e) {
      print('Error marking messages as read: $e');
    } finally {
      await connection.close();
    }
  }

  // 최신 createdAt 값 가져오기
  static Future<String?> fetchCreatedAtMessages({required int postId}) async {
    final connection = await getConnection();
    String? formattedDate;

    try {
      final result = await connection.execute(
        '''
      SELECT DATE_FORMAT(MAX(createdAt), '%Y.%m.%d') as latestCreatedAt
      FROM messages
      WHERE post_id = :postId
      ''',
        {'postId': postId},
      );

      if (result.rows.isNotEmpty) {
        formattedDate =
            result.rows.first.assoc()['latestCreatedAt']?.toString();
      }
    } catch (e) {
      print('최신 createdAt 가져오기 실패: $e');
    } finally {
      await connection.close();
    }

    return formattedDate;
  }

  // posts 테이블에서 데이터 가져오기
  static Future<Map<String, dynamic>?> loadPostData(int postId) async {
    final connection = await getConnection();

    try {
      // SQL 쿼리 실행
      final result = await connection.execute(
        '''
      SELECT 
        title, body, place_keyword, thing_keyword,
        image_url1, image_url2, image_url3, image_url4
      FROM posts 
      WHERE post_id = :postId
      ''',
        {
          'postId': postId,
        },
      );

      // 결과 처리
      if (result.rows.isNotEmpty) {
        final row = result.rows.first; // 첫 번째 결과 가져오기
        return {
          'title': row.colByName('title'),
          'body': row.colByName('body'),
          'place_keyword': row.colByName('place_keyword'),
          'thing_keyword': row.colByName('thing_keyword'),
          'image_urls': [
            row.colByName('image_url1'),
            row.colByName('image_url2'),
            row.colByName('image_url3'),
            row.colByName('image_url4'),
          ].whereType<String>().toList(), // null 제거 후 리스트로 반환
        };
      }
    } catch (e) {
      // 에러 로그 출력
      print('게시물 데이터 로드 실패: $e');
    } finally {
      // 데이터베이스 연결 닫기
      await connection.close();
    }

    // 결과가 없을 경우 null 반환
    return null;
  }

  // 게시물 업데이트
  static Future<bool> updatePost({
    required int postId,
    required String title,
    required String body,
    String? imageUrl1,
    String? imageUrl2,
    String? imageUrl3,
    String? imageUrl4,
    required String placeKeyword,
    required String thingKeyword,
  }) async {
    final connection = await getConnection();

    try {
      await connection.execute(
        '''
      UPDATE posts
      SET 
        title = :title, 
        body = :body, 
        place_keyword = :placeKeyword, 
        thing_keyword = :thingKeyword,
        image_url1 = :imageUrl1,
        image_url2 = :imageUrl2,
        image_url3 = :imageUrl3,
        image_url4 = :imageUrl4
      WHERE post_id = :postId
      ''',
        {
          'title': title,
          'body': body,
          'placeKeyword': placeKeyword,
          'thingKeyword': thingKeyword,
          'imageUrl1': imageUrl1,
          'imageUrl2': imageUrl2,
          'imageUrl3': imageUrl3,
          'imageUrl4': imageUrl4,
          'postId': postId,
        },
      );
      return true;
    } catch (e) {
      print('게시물 업데이트 실패: $e');
      return false;
    } finally {
      await connection.close();
    }
  }

  static Future<List<Post>> fetchAllPosts({
    String? placeKeyword,
    String? thingKeyword,
  }) async {
    final connection = await getConnection();
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
    ''';

      if (placeKeyword != null) {
        sql += " WHERE place_keyword = :placeKeyword";
      }
      if (thingKeyword != null) {
        sql += placeKeyword == null ? " WHERE" : " AND";
        sql += " thing_keyword = :thingKeyword";
      }

      sql += " ORDER BY created_at DESC";

      final results = await connection.execute(sql, {
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
          userId: int.tryParse(row.assoc()['user_id']?.toString() ?? '') ?? 0,
          imageUrl1: row.assoc()['image_url1'],
          place: row.assoc()['place_keyword'],
          thing: row.assoc()['thing_keyword'],
        ));
      }
    } catch (e) {
      print('Error fetching posts: $e');
    }

    return posts;
  }

}
