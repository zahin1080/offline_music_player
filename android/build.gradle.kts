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

// 1. Configure namespace and synchronize Java/Kotlin targets to 17
subprojects {
    val configureProject: Project.() -> Unit = {
        // Fix missing namespaces for AGP 8+
        val androidExt = extensions.findByName("android")
        if (androidExt != null) {
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
            } catch (e: Exception) {
                // Ignore
            }
        }

        // Align Java and Kotlin tasks to JVM 17
        tasks.withType<JavaCompile>().configureEach {
            sourceCompatibility = "17"
            targetCompatibility = "17"
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

// 2. Project evaluation dependency
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}