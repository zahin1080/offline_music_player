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
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// Intercept plugins at configuration time and inject missing namespace + SDK versions
subprojects {
    plugins.withId("com.android.library") {
        val androidExt = extensions.findByName("android") as? com.android.build.gradle.LibraryExtension
        if (androidExt != null) {
            // 1. Force namespace for on_audio_query_android or any plugin missing it
            if (androidExt.namespace == null) {
                androidExt.namespace = if (project.name == "on_audio_query_android") {
                    "com.lucasjosino.on_audio_query"
                } else {
                    val grp = project.group.toString()
                    if (grp.isNotEmpty() && grp != "unspecified") grp else "com.example.${project.name}"
                }
            }

            // 2. Align compileSdk
            androidExt.compileSdk = 35
        }
    }

    // Synchronize Java and Kotlin compile targets to Java 11
    tasks.withType<JavaCompile>().configureEach {
        sourceCompatibility = "17"
        targetCompatibility = "17"
    }
    tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
        compilerOptions {
            jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}