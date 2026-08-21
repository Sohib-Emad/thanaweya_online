-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class com.google.firebase.** { *; }
-keepnames class * extends java.lang.Exception

# Fix R8 missing play.core classes
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }