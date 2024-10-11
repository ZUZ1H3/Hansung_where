package com.example.hansung_where

import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.sql.Connection
import java.sql.DriverManager
import java.sql.SQLException
import java.sql.Statement

// DB
private val url = BuildConfig.DB_URL
private val user = BuildConfig.DB_USER
private val password = BuildConfig.DB_PASSWORD

object DbConn {
    private var conn: Connection? = null

    // MySQL 연결
    suspend fun getConnection(): Connection? {
        return withContext(Dispatchers.IO) {
            if (conn == null || conn!!.isClosed) {
                try {
                    // JDBC 드라이버 로드
                    Class.forName("com.mysql.jdbc.Driver")
                    conn = DriverManager.getConnection(url, user, password)
                } catch (e: Exception) {
                    e.printStackTrace()
                }
            }
            conn
        }
    }

    // 닉네임 불러오기
    suspend fun getNickname(studentId: String): String? {
        return withContext(Dispatchers.IO) {
            var nickname: String? = null
            val connection = getConnection()

            try {
                val statement = connection?.createStatement()
                val sql = "SELECT nickname FROM users WHERE student_id = '$studentId'"
                val resultSet = statement?.executeQuery(sql)

                if (resultSet?.next() == true) {
                    nickname = resultSet.getString("nickname")
                }
            } catch (e: SQLException) {
                e.printStackTrace()
            } finally {
                connection?.close()
            }
            nickname
        }
    }

    // 닉네임 업데이트
    suspend fun updateNickname(studentId: String, newNickname: String): Boolean {
        return withContext(Dispatchers.IO) {
            var statement: Statement? = null
            var success = false
            try {
                val connection = getConnection()
                statement = connection?.createStatement()
                val sql = "UPDATE users SET nickname = '$newNickname' WHERE student_id = '$studentId'"
                val rowsAffected = statement?.executeUpdate(sql) ?: 0

                success = rowsAffected > 0
            } catch (e: SQLException) {
                e.printStackTrace()
            } finally {
                statement?.close()
            }
            success
        }
    }
}
