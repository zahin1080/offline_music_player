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

// 1. Configure the namespace BEFORE evaluationDependsOn(":app")
subprojects {
    val configureNamespace: Project.() -> Unit = {
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
                // Ignore if extension does not support namespace
            }
        }
    }

    // If already evaluated, execute directly; otherwise use afterEvaluate
    if (state.executed) {
        configureNamespace()
    } else {
        afterEvaluate {
            configureNamespace()
        }
    }
}

// 2. Evaluate dependencies AFTER namespace configuration has been registered
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}