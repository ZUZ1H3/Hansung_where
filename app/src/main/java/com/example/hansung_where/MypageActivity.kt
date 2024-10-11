package com.example.hansung_where

import android.content.Intent
import android.content.SharedPreferences
import android.os.Bundle
import android.util.Log
import android.view.View
import android.widget.EditText
import android.widget.ImageView
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.lifecycle.lifecycleScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.sql.Connection

class MypageActivity : AppCompatActivity(), View.OnClickListener {
    private lateinit var main: ConstraintLayout
    private lateinit var back: ImageView
    private lateinit var bell: ImageView
    private lateinit var pen: ImageView
    private lateinit var profile: ImageView
    private lateinit var profilebox: ImageView
    private lateinit var myPost: ImageView
    private lateinit var myComment: ImageView
    private lateinit var myScrap: ImageView
    private lateinit var boogi: ImageView
    private lateinit var kkukku: ImageView
    private lateinit var kkokko: ImageView
    private lateinit var sangzzi: ImageView
    private lateinit var nyang: ImageView
    private lateinit var announce: ImageView
    private lateinit var inquire: ImageView
    private lateinit var nickname: EditText

    private var isProfileVisible = false // 프로필 표시 상태
    private var isEdit = false // 닉네임 수정 상태

    private lateinit var loginPref: SharedPreferences
    private lateinit var editor: SharedPreferences.Editor
    private lateinit var userId: String

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_mypage)

        init()
        loadNickname() // 닉네임 불러오기
    }

    private fun init() {
        // sharedPref 초기화
        loginPref = getSharedPreferences("Logins", MODE_PRIVATE)
        editor = loginPref.edit()
        userId = loginPref.getString("student_id", null) ?: ""

        // 초기화
        main = findViewById(R.id.main)
        back = findViewById(R.id.back)
        bell = findViewById(R.id.bell)
        pen = findViewById(R.id.pen)
        profile = findViewById(R.id.profile)
        profilebox = findViewById(R.id.profilebox)
        myPost = findViewById(R.id.post)
        myComment = findViewById(R.id.comment)
        myScrap = findViewById(R.id.scrap)
        boogi = findViewById(R.id.boogi)
        kkukku = findViewById(R.id.kkukku)
        kkokko = findViewById(R.id.kkokko)
        sangzzi = findViewById(R.id.sangzzi)
        nyang = findViewById(R.id.nyang)
        announce = findViewById(R.id.announce)
        inquire = findViewById(R.id.inquire)
        nickname = findViewById(R.id.nickname)

        // 클릭 리스너 초기화
        back.setOnClickListener { finish() }
        pen.setOnClickListener(this)
        main.setOnClickListener(this)
        profile.setOnClickListener(this)
        boogi.setOnClickListener(this)
        kkukku.setOnClickListener(this)
        kkokko.setOnClickListener(this)
        sangzzi.setOnClickListener(this)
        nyang.setOnClickListener(this)

        bell.setOnClickListener {
            val intent = Intent(this, NotificationActivity::class.java)
            startActivity(intent)
        }
        myPost.setOnClickListener {
            val intent = Intent(this, MypostActivity::class.java)
            startActivity(intent)
        }
        myComment.setOnClickListener {
            val intent = Intent(this, MycommentActivity::class.java)
            startActivity(intent)
        }
        myScrap.setOnClickListener {
            val intent = Intent(this, MyscrapActivity::class.java)
            startActivity(intent)
        }
        announce.setOnClickListener {
            val intent = Intent(this, AnnouncementActivity::class.java)
            startActivity(intent)
        }
        inquire.setOnClickListener {
            val intent = Intent(this, InquirementActivity::class.java)
            startActivity(intent)
        }
    }

    override fun onClick(v: View?) {
        when (v?.id) {
            // profile 클릭 시
            R.id.profile -> {
                isProfileVisible = !isProfileVisible
                // true면 VISIBLE, false면 INVISIBLE로 설정
                if(isProfileVisible) setVisibility(View.VISIBLE)
                else setVisibility(View.INVISIBLE)
            }
            R.id.main -> {
                if(isProfileVisible) {
                    setVisibility(View.INVISIBLE)
                    isProfileVisible = !isProfileVisible
                }
            }

            R.id.boogi -> { profile.setImageResource(R.drawable.ic_boogi) }
            R.id.kkukku -> { profile.setImageResource(R.drawable.ic_kkukku) }
            R.id.kkokko -> { profile.setImageResource(R.drawable.ic_kkokko) }
            R.id.sangzzi -> { profile.setImageResource(R.drawable.ic_sangzzi) }
            R.id.nyang -> { profile.setImageResource(R.drawable.ic_nyang) }

            // pen 클릭 시 편집 가능하게 변경
            R.id.pen -> {
                val nicknameText = nickname.text.toString()

                // 글자 수에 따라 paddingStart 조정
                if(nicknameText.length < 3) {
                    nickname.setPadding(65, nickname.paddingTop, nickname.paddingEnd, nickname.paddingBottom)
                } else if (nicknameText.length < 5) {
                    nickname.setPadding(50, nickname.paddingTop, nickname.paddingEnd, nickname.paddingBottom)
                } else if(nicknameText.length < 6) {
                    nickname.setPadding(20, nickname.paddingTop, nickname.paddingEnd, nickname.paddingBottom)
                } else {
                    nickname.setPadding(0, nickname.paddingTop, nickname.paddingEnd, nickname.paddingBottom) // 기본
                }

                if (isEdit) {
                    when {
                        nicknameText.length < 2 -> { // 2글자 미만일 때
                            Toast.makeText(this, "2글자 이상 써주세요.", Toast.LENGTH_SHORT).show()
                            return // 편집 모드 유지
                        }
                        nicknameText.length > 7 -> {  // 7글자 초과일 때
                            Toast.makeText(this, "7글자 이하로 입력해주세요.", Toast.LENGTH_SHORT).show()
                            nickname.setText(nicknameText.take(7)) // 7글자로 자름
                            nickname.setSelection(nickname.text.length) // 커서를 맨 뒤로
                            return // 편집 모드 유지
                        }
                    }

                    // 유효성 검사 후 편집 불가능
                    updateNickname(nicknameText)
                    isEdit = false
                    nickname.isClickable = false
                    nickname.isFocusable = false
                    nickname.isFocusableInTouchMode = false
                } else { // 편집 가능
                    isEdit = true
                    nickname.isClickable = true
                    nickname.isFocusable = true
                    nickname.isFocusableInTouchMode = true

                    nickname.requestFocus() // 자동으로 커서를 위치시켜줌
                    nickname.setSelection(nickname.text.length) // 커서를 맨 뒤로
                }
            }
        }
    }

    // visibility 설정
    private fun setVisibility(visibility: Int) {
        profilebox.visibility = visibility
        boogi.visibility = visibility
        kkukku.visibility = visibility
        kkokko.visibility = visibility
        sangzzi.visibility = visibility
        nyang.visibility = visibility
    }

    // 로그인한 사용자 nickname 가져오기
    private fun loadNickname() {
        if (userId != null) {
            lifecycleScope.launch {
                val userNickname = DbConn.getNickname(userId)
                nickname.setText(userNickname ?: "")
            }
        }
    }

    // nickname 업데이트
    private fun updateNickname(newNickname: String) {
        if (userId != null) {
            lifecycleScope.launch {
                val isUnique = withContext(Dispatchers.IO) {
                    // 새 닉네임 중복 체크
                    val conn: Connection? = DbConn.getConnection()
                    var unique = true
                    try {
                        val statement = conn!!.createStatement()
                        val nicknameCheckSql = "SELECT COUNT(*) FROM users WHERE nickname = '$newNickname'"
                        val resultSet = statement.executeQuery(nicknameCheckSql)
                        if (resultSet.next() && resultSet.getInt(1) > 0) {
                            unique = false // 중복된 닉네임이 있을 경우 false
                        }
                        resultSet.close()
                        statement.close()
                    } catch (e: Exception) {
                        e.printStackTrace()
                        unique = false // 예외 발생 시 중복으로 간주
                    } finally {
                        conn?.close()
                    }
                    unique
                }

                if (isUnique) {
                    // 닉네임이 중복되지 않으면 업데이트 진행
                    val success = withContext(Dispatchers.IO) {
                        DbConn.updateNickname(userId, newNickname) // DB 업데이트
                    }
                    if (success) {
                        Toast.makeText(this@MypageActivity, "업데이트되었습니다.", Toast.LENGTH_SHORT).show()
                    } else {
                        Toast.makeText(this@MypageActivity, "실패했습니다.", Toast.LENGTH_SHORT).show()
                    }
                } else {
                    // 중복된 닉네임일 경우 사용자에게 알림
                    withContext(Dispatchers.Main) {
                        Toast.makeText(this@MypageActivity, "사용 중인 이름입니다.", Toast.LENGTH_SHORT).show()
                    }
                }
            }
        }
    }

}