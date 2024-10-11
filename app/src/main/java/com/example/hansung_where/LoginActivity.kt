package com.example.hansung_where

import android.content.Intent
import android.content.SharedPreferences
import android.net.Uri
import android.os.Bundle
import android.widget.*
import androidx.appcompat.app.AppCompatActivity
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import okhttp3.Call
import okhttp3.Callback
import okhttp3.FormBody
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.Response
import org.jsoup.Jsoup
import org.jsoup.nodes.Document
import java.io.IOException
import java.sql.Connection
import java.sql.Statement

class LoginActivity : AppCompatActivity() {
    private lateinit var back: ImageView
    private lateinit var login: TextView
    private lateinit var explain: TextView
    private lateinit var findIdPw: TextView
    private lateinit var id: EditText
    private lateinit var pw: EditText
    // 로그인 상태를 저장할 sharedPreferences
    private lateinit var loginPref: SharedPreferences
    private lateinit var editor: SharedPreferences.Editor

    // 쿠키 관리
    private val client = OkHttpClient.Builder()
        .cookieJar(MyCookieJar())
        .build()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_login)

        // 초기화
        back = findViewById(R.id.back)
        login = findViewById(R.id.login)
        explain = findViewById(R.id.explain)
        findIdPw = findViewById(R.id.findIdPw)
        id = findViewById(R.id.id)
        pw = findViewById(R.id.pw)
        // sharedPref 초기화
        loginPref = getSharedPreferences("Logins", MODE_PRIVATE)
        editor = loginPref.edit()

        back.setOnClickListener { finish() }
        login.setOnClickListener { handleLogin() }
        findIdPw.setOnClickListener { find() }
    }

    // 로그인 처리
    private fun handleLogin() {
        val userId = id.text.toString()
        val userPw = pw.text.toString()

        when {
            // ID 공백 여부
            userId.isBlank() -> {
                explain.text = "학번을 입력해주세요"
                id.requestFocus()
                return
            }
            // ID가 알파벳과 숫자로 구성된 지 확인
            !isAlphaNumeric(userId) -> {
                explain.text = "학번은 알파벳과 숫자만 포함되어야 합니다"
            }
            // ID 길이 확인
            userId.length < 6 || userId.length > 10 -> {
                explain.text = "학번은 6자 이상 10자 이하여야 합니다"
                id.requestFocus()
                return
            }
            // PW 공백 여부
            userPw.isBlank() -> {
                explain.text = "비밀번호를 입력해주세요"
                pw.requestFocus()
                return
            }
            // 서버에 로그인 요청
            else -> {
                loginToLms(userId, userPw)
            }
        }
    }

    // 알파벳, 숫자로 구성되어 있는지 확인
    private fun isAlphaNumeric(checkStr: String): Boolean {
        val checkOK = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
        for (ch in checkStr) {
            if (ch !in checkOK) {
                return false
            }
        }
        return true
    }

    // 학교 LMS 서버에 로그인 시도
    private fun loginToLms(userId: String, userPw: String) {
        // 로그인 요청 보낼 LMS 서버의 URL
        val url = "https://learn.hansung.ac.kr/login/index.php"

        // 폼 데이터로 로그인 정보 생성
        val formBody = FormBody.Builder()
            .add("username", userId)
            .add("password", userPw)
            .build()

        // 로그인 요청을 위한 HTTP 요청 생성
        val request = Request.Builder()
            .url(url)
            .post(formBody)
            .build()

        // 비동기 네트워크 요청
        client.newCall(request).enqueue(object : Callback {
            override fun onFailure(call: Call, e: IOException) {
                runOnUiThread {
                    explain.text = "서버와 연결할 수 없습니다. 다시 시도해 주세요."
                }
            }

            override fun onResponse(call: Call, response: Response) {
                val responseBody = response.body?.string()

                runOnUiThread {
                    if (response.isSuccessful) {
                        // HTML 파싱
                        val document: Document = Jsoup.parse(responseBody)
                        // body 내의 모든 텍스트 갖고 옴
                        val successText = document.select("body").text()

                        if (!successText.contains("잘못 입력")) { // 잘못 입력된 단어가 없으면 로그인 성공 처리
                            // 로그인 성공
                            saveUser(userId)
                            Toast.makeText(this@LoginActivity, "로그인 성공", Toast.LENGTH_SHORT).show()
                            editor.putBoolean("isLog", true)
                            editor.putString("student_id", id.text.toString())
                            editor.apply()

                            val intent = Intent(this@LoginActivity, MainActivity::class.java)
                            startActivity(intent)
                        } else {  // 로그인 실패
                            explain.text = "아이디 또는 비밀번호가 잘못 입력되었습니다"
                        }
                    }
                }
            }
        })
    }

    // 아이디 또는 비밀번호 찾기
    private fun find() {
        // 웹사이트 URL
        val url = "https://info.hansung.ac.kr/jsp/infofind/infoFindView_rwd.jsp"

        val intent = Intent(Intent.ACTION_VIEW).apply {
            data = Uri.parse(url)
        }
        startActivity(intent)
    }

    private fun saveUser(id: String) {
        CoroutineScope(Dispatchers.IO).launch {
            var conn: Connection? = DbConn.getConnection()

            try {
                val statement: Statement = conn!!.createStatement()
                val checkSql = "SELECT COUNT(*) FROM users WHERE student_id = '$id'"
                val resultSet = statement.executeQuery(checkSql)

                if (resultSet.next() && resultSet.getInt(1) == 0) {
                    var nickname: String
                    var isUnique: Boolean

                    do {
                        val randomNum = (1..999).random()
                        nickname = "부기$randomNum"

                        // nickname 중복 체크
                        val nicknameCheckSql = "SELECT COUNT(*) FROM users WHERE nickname = '$nickname'"
                        val nicknameResultSet = statement.executeQuery(nicknameCheckSql)
                        isUnique = nicknameResultSet.next() && nicknameResultSet.getInt(1) == 0
                        nicknameResultSet.close()
                    } while (!isUnique)
                }
                resultSet.close()
                statement.close()
                conn.close()

                withContext(Dispatchers.Main) {
                    // 메인 스레드에서 UI 업데이트
                    Toast.makeText(this@LoginActivity, "사용자 정보 저장 완료", Toast.LENGTH_SHORT).show()
                }
            } catch (e: Exception) {
                e.printStackTrace()
                withContext(Dispatchers.Main) {
                    explain.text = "사용자 정보를 저장할 수 없습니다."
                }
            }
        }
    }
}