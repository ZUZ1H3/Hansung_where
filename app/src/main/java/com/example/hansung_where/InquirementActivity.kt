package com.example.hansung_where

import android.os.Bundle
import android.widget.ImageView
import androidx.appcompat.app.AppCompatActivity

class InquirementActivity : AppCompatActivity() {
    private lateinit var back: ImageView

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_inquirement)

        back = findViewById(R.id.back)

        back.setOnClickListener { finish() }
    }
}