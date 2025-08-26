// 루트 build.gradle.kts

plugins {
    // ✅ 버전 명시 제거 → Flutter/Gradle에서 자동으로 관리되도록 함
    id("com.android.application") apply false
    id("org.jetbrains.kotlin.android") apply false
    id("dev.flutter.flutter-gradle-plugin") apply false
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// ✅ Flutter는 빌드 산출물을 최상위 build/ 가 아닌, 프로젝트 루트 기준으로 두는 방식 사용
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
