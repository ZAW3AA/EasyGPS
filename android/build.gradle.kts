allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// تغيير مسار مجلد build للمشروع الرئيسي
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

// تغيير مسار مجلد build للمشاريع الفرعية
subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// إدارة التبعيات بين المشاريع الفرعية
subprojects {
    project.evaluationDependsOn(":app")
}

// مهمة تنظيف مجلد build
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}