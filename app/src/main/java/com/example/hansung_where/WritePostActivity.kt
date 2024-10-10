package com.example.hansung_where

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.util.TypedValue
import android.widget.Button
import android.widget.EditText
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import android.widget.Toast
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AppCompatActivity

class WritePostActivity : AppCompatActivity() {
    private lateinit var back: ImageView //뒤로가기 버튼. lateinit으로 나중에 초기화하기 때문에 var 사용
    private lateinit var title: EditText //제목 입력 칸
    private lateinit var body: EditText // 본문 입력 칸
    private lateinit var keyword: EditText // 키워드 입력 칸
    private lateinit var photo: ImageView //사진 업로드 버튼
    private lateinit var submit: Button // 게시물 업로드 버튼
    private lateinit var keywordBtn: Button
    private lateinit var imageContainer: LinearLayout //추가된 사진 보여줄 레이아웃
    private lateinit var keywordContainer: LinearLayout // 키워드 레이아웃
    private lateinit var photoNum: TextView // 현재 사진 개수를 나타내는 TextView
    private lateinit var getResult: ActivityResultLauncher<Intent> // 갤러리에서 선택된 이미지를 받기 위한 ActivityResultLauncher
    private var imageCount = 0 // 현재 추가된 이미지의 개수를 추적하는 변수
    private var keywordCount = 0;
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_write_post)

        back = findViewById(R.id.back)
        title = findViewById(R.id.title)
        body = findViewById(R.id.body)
        keyword = findViewById(R.id.keyword)
        photo = findViewById(R.id.photo)
        submit = findViewById(R.id.submit)
        imageContainer = findViewById(R.id.image_container)
        keywordContainer = findViewById(R.id.keyword_container)
        photoNum = findViewById(R.id.photoNumber)
        keywordBtn = findViewById(R.id.keywordBtn)

        // 사진 선택 결과 처리
        getResult =
            registerForActivityResult(ActivityResultContracts.StartActivityForResult()) { result ->
                if (result.resultCode == Activity.RESULT_OK && imageCount < 4) { // 최대 4개의 사진까지만 허용
                    val selectedImageUri: Uri? = result.data?.data
                    if (selectedImageUri != null) {
                        // 선택된 이미지를 담을 새로운 ImageView 생성
                        val imageView = ImageView(this).apply {
                            layoutParams = LinearLayout.LayoutParams(
                                76.dpToPx(), 76.dpToPx() // 70x70 크기
                            ).apply {
                                setMargins(12.dpToPx(), 0, 12.dpToPx(), 0) // 사진끼리의 마진
                            }
                            setImageURI(selectedImageUri) // 선택한 이미지 설정
                            scaleType = ImageView.ScaleType.CENTER_CROP // 사진을 잘 맞추기 위한 설정
                        }
                        // imageContainer에 새로 만든 ImageView 추가
                        imageContainer.addView(imageView)
                        imageCount++ // 추가된 이미지 개수 증가
                        photoNum.text = "($imageCount/4)" // 사진 개수 업데이트
                    }
                } else {
                    Toast.makeText(this, "사진은 최대 4개까지 추가할 수 있습니다.", Toast.LENGTH_SHORT).show()
                }
            }

        // 사진 선택 버튼 클릭 이벤트
        photo.setOnClickListener {
            if (imageCount < 4) { // 최대 4개까지만 허용
                val intent = Intent(Intent.ACTION_PICK).apply {
                    type = "image/*" // 이미지 파일만 선택
                }
                getResult.launch(intent) // 갤러리 열기
            } else {
                Toast.makeText(this, "사진은 최대 4개까지 추가할 수 있습니다.", Toast.LENGTH_SHORT).show()
            }
        }

        keywordBtn.setOnClickListener { // keywordBtn 사용
            val keywordText = keyword.text.toString().trim() // EditText에서 텍스트 가져오기
            if (keywordText.isNotEmpty() && keywordCount < 3) {
                addKeywordToLayout(keywordText) // 키워드를 레이아웃에 추가하는 함수 호출
                keyword.text.clear() // EditText 비우기
                keywordCount++
            } else if(keywordText.isEmpty() && keywordCount < 3){
                Toast.makeText(this, "키워드를 입력하세요.", Toast.LENGTH_SHORT).show()
            }
            else{
                Toast.makeText(this, "키워드는 최대 3개까지 추가할 수 있습니다.", Toast.LENGTH_SHORT).show()
            }
        }

        submit.setOnClickListener {
            val titleText = title.text.toString().trim() // 제목 가져오기
            val bodyText = body.text.toString().trim() // 본문 가져오기

            // 제목이 없거나 본문이 10글자 이하인 경우
            if (titleText.isEmpty()) {
                Toast.makeText(this, "제목을 입력하세요.", Toast.LENGTH_SHORT).show()
            } else if (bodyText.length <= 10) {
                Toast.makeText(this, "본문은 10글자 이상 입력해야 합니다.", Toast.LENGTH_SHORT).show()
            } else {
                // mysql 저장, 자기가 쓴 글 화면으로 넘어가기
            }
        }

    }

    private fun addKeywordToLayout(keywordText: String) {
        val textView = TextView(this).apply {
            text = "#$keywordText"
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 14f)
            setPadding(11.dpToPx(), 5.dpToPx(), 11.dpToPx(), 5.dpToPx())
            setBackgroundResource(R.drawable.custom_background)
        }
        val params = LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.WRAP_CONTENT,
            LinearLayout.LayoutParams.WRAP_CONTENT
        ).apply {
            setMargins(5.dpToPx(), 0, 0, 0)
        }
        textView.layoutParams = params

        // 키워드 컨테이너에 추가
        keywordContainer.addView(textView)
    }

    // dp 값을 px 값으로 변환하는 함수
    private fun Int.dpToPx(): Int {
        return (this * resources.displayMetrics.density).toInt()
    }
}
