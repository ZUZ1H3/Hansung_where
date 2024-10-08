package com.example.hansung_where

import android.content.Intent
import android.os.Bundle
import android.widget.*
import androidx.appcompat.app.AppCompatActivity

class LoginActivity : AppCompatActivity() {
    private lateinit var back: ImageView
    private lateinit var login: ImageView
    private lateinit var explain: TextView
    private lateinit var findIdPw: TextView
    private lateinit var id: EditText
    private lateinit var pw: EditText

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_login)

        back = findViewById(R.id.back)
        login = findViewById(R.id.login)
        explain = findViewById(R.id.explain)
        findIdPw = findViewById(R.id.findIdPw)
        id = findViewById(R.id.id)
        pw = findViewById(R.id.pw)

        back.setOnClickListener {
            val intent = Intent(this, MainActivity::class.java)
            startActivity(intent)
        }
        login.setOnClickListener { handleLogin() }
        findIdPw.setOnClickListener { find() }
    }

    // 로그인 처리
    private fun handleLogin() {
        val idText = id.text.toString()
        val pwText = pw.text.toString()

        if (idText.isNotEmpty() && pwText.isNotEmpty()) {
            // 로그인 처리 로직 추가
        } else {
            explain.text = "학번과 비밀번호를 입력해 주세요."
        }
    }

    // 아이디 또는 비밀번호 찾기
    private fun find() {

    }
}