package com.example.hansung_where.ui.home

import android.content.Intent
import android.content.SharedPreferences
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.appcompat.app.AppCompatActivity.MODE_PRIVATE
import androidx.fragment.app.Fragment
import androidx.lifecycle.ViewModelProvider
import com.example.hansung_where.LoginActivity
import com.example.hansung_where.MypageActivity
import com.example.hansung_where.NotificationActivity
import com.example.hansung_where.databinding.FragmentHomeBinding

class HomeFragment : Fragment() {

    private var _binding: FragmentHomeBinding? = null
    private val binding get() = _binding!!

    private lateinit var loginPref: SharedPreferences
    private var isLog: Boolean = false // 로그인 활성 여부

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        val homeViewModel =
            ViewModelProvider(this).get(HomeViewModel::class.java)

        _binding = FragmentHomeBinding.inflate(inflater, container, false)
        val root: View = binding.root

        // SharedPreferences 초기화
        loginPref = requireActivity().getSharedPreferences("Logins", MODE_PRIVATE)
        isLog = loginPref.getBoolean("isLog", false)

        // 클릭 리스너
        binding.bell.setOnClickListener {
            val intent = Intent(requireContext(), NotificationActivity::class.java)
            startActivity(intent)
        }

        binding.mypage.setOnClickListener {
            if (isLog) {
                // 로그인 상태가 유지되고 있음
                val intent = Intent(requireContext(), MypageActivity::class.java)
                startActivity(intent)
            } else {
                // 로그인 상태가 아님
                val intent = Intent(requireContext(), LoginActivity::class.java)
                startActivity(intent)
            }
        }

        return root
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}