buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Add the Android Gradle plugin (likely already in use by Flutter)
        classpath("com.android.tools.build:gradle:8.1.0")
        // Add the Kotlin Gradle plugin (since you're using Kotlin script)
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.0")
        // Add the Google Services plugin for Firebase
        classpath("com.google.gms:google-services:4.4.2")
    }
}

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
