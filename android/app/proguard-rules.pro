# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# WorkManager
-keep class androidx.work.** { *; }
-keep class * extends androidx.work.Worker { *; }
-keep class * extends androidx.work.ListenableWorker { *; }
-keepclassmembers class * extends androidx.work.ListenableWorker {
    public <init>(android.content.Context, androidx.work.WorkerParameters);
}

# WorkManager plugin
-keep class dev.fluttercommunity.workmanager.** { *; }

# Flutter Play Store Split (referenced by Flutter internals, not used)
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }