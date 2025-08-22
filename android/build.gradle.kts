allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

android {
    namespace = "com.example.petlendar_project" // 프로젝트 네임스페이스는 그대로 두세요
    compileSdk = 34

    defaultConfig {
        applicationId = "com.example.petlendar_project"
        minSdk = 23
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
    }

    // ✅ 여기에 NDK 버전 고정 추가
    ndkVersion = "27.0.12077973"

    buildTypes {
        release {
            isMinifyEnabled = false
        }
    }
}
