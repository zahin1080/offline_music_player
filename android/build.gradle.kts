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

subprojects {
    val configureProject: Project.() -> Unit = {
        val androidExt = extensions.findByName("android")
        if (androidExt != null) {
            // 1. Inject missing namespace for AGP 8+
            try {
                val getNamespace = androidExt.javaClass.getMethod("getNamespace")
                val setNamespace = androidExt.javaClass.getMethod("setNamespace", String::class.java)
                if (getNamespace.invoke(androidExt) == null) {
                    val targetNamespace = if (name == "on_audio_query_android") {
                        "com.lucasjosino.on_audio_query"
                    } else {
                        val grp = group.toString()
                        if (grp.isNotEmpty() && grp != "unspecified") grp else "com.example.$name"
                    }
                    setNamespace.invoke(androidExt, targetNamespace)
                }
            } catch (_: Exception) {}

            // 2. Force subproject compileSdk up from 33 to 35
            try {
                val compileMethod = androidExt.javaClass.methods.firstOrNull {
                    (it.name == "compileSdkVersion" || it.name == "setCompileSdkVersion" || it.name == "setCompileSdk") &&
                            it.parameterTypes.size == 1 &&
                            (it.parameterTypes[0] == Int::class.javaPrimitiveType || it.parameterTypes[0] == Integer::class.java)
                }
                compileMethod?.invoke(androidExt, 37)
            } catch (_: Exception) {}
        }

        // 3. JVM target alignment
        tasks.withType<JavaCompile>().configureEach {
            sourceCompatibility = "11"
            targetCompatibility = "11"
        }
        tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
            compilerOptions {
                jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_11)
            }
        }

        // 4. Disable AAR metadata verification tasks
        tasks.matching { it.name.contains("AarMetadata", ignoreCase = true) }.configureEach {
            enabled = false
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