pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "9.0.1" apply false
    id("org.jetbrains.kotlin.android") version "2.3.20" apply false
}

include(":app")

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()

rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory =
        newBuildDir.dir(project.name)

    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    val configureProject: Project.() -> Unit = {

        val androidExt = extensions.findByName("android")

        if (androidExt != null) {

            try {
                val getNamespace =
                    androidExt.javaClass.getMethod("getNamespace")

                val setNamespace =
                    androidExt.javaClass.getMethod(
                        "setNamespace",
                        String::class.java
                    )

                if (getNamespace.invoke(androidExt) == null) {

                    val targetNamespace =
                        if (name == "on_audio_query_android") {
                            "com.lucasjosino.on_audio_query"
                        } else {
                            val grp = group.toString()

                            if (grp.isNotEmpty() && grp != "unspecified")
                                grp
                            else
                                "com.example.$name"
                        }

                    setNamespace.invoke(
                        androidExt,
                        targetNamespace
                    )
                }

            } catch (_: Exception) {}
        }

        tasks.withType<JavaCompile>().configureEach {
            sourceCompatibility = "17"
            targetCompatibility = "17"
        }

        tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
            compilerOptions {
                jvmTarget.set(
                    org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
                )
            }
        }
    }

    if (state.executed) {
        configureProject()
    } else {
        afterEvaluate {
            configureProject()
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}