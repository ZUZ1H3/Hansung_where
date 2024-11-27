import 'package:mysql_client/mysql_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
          final randomNum = (1 + (999 - 1) * (DateTime.now().millisecondsSinceEpoch % 1000)).toString();
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
          {'studentId': studentId, 'nickname': nickname, 'profileId': profileId},
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
  static Future<bool> updateNickname(String studentId, String newNickname) async {
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
}