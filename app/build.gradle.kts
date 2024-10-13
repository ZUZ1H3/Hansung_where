import java.util.Properties
import java.io.FileInputStream

// local.properties 파일에서 값 읽기
val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localProperties.load(FileInputStream(localPropertiesFile))
}

// local.properties에서 값 가져오기
val dbUrl: String = localProperties.getProperty("db.url", "")
val dbUser: String = localProperties.getProperty("db.user", "")
val dbPassword: String = localProperties.getProperty("db.password", "")

plugins {
    alias(libs.plugins.android.application)
    alias(libs.plugins.jetbrains.kotlin.android)
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.hansung_where"
    compileSdk = 34

    defaultConfig {
        applicationId = "com.example.hansung_where"
        minSdk = 24
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"

        // 빌드 설정에 DB 정보 추가
        buildConfigField("String", "DB_URL", "\"${dbUrl}\"")
        buildConfigField("String", "DB_USER", "\"${dbUser}\"")
        buildConfigField("String", "DB_PASSWORD", "\"${dbPassword}\"")
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }
    kotlinOptions {
        jvmTarget = "1.8"
    }
    buildFeatures {
        viewBinding = true
        buildConfig = true
    }
}

dependencies {

    implementation(libs.androidx.core.ktx)
    implementation(libs.androidx.appcompat)
    implementation(libs.material)
    implementation(libs.androidx.activity)
    implementation(libs.androidx.constraintlayout)
    implementation(libs.androidx.lifecycle.livedata.ktx)
    implementation(libs.androidx.lifecycle.viewmodel.ktx)
    implementation(libs.androidx.navigation.fragment.ktx)
    implementation(libs.androidx.navigation.ui.ktx)
    testImplementation(libs.junit)
    androidTestImplementation(libs.androidx.junit)
    androidTestImplementation(libs.androidx.espresso.core)

    // OkHttp 라이브러리
    implementation("com.squareup.okhttp3:okhttp:4.9.3")
    // Jsoup
    implementation("org.jsoup:jsoup:1.14.3")
    // MySQL
    implementation("mysql:mysql-connector-java:5.1.49")
    // 코루틴 스레드
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.6.4")
    //Firebase
    implementation(platform("com.google.firebase:firebase-bom:33.4.0"))
    implementation("com.google.firebase:firebase-analytics")
}

