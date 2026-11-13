# RetailOS Android ProGuard rules

# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Play Core (referenced by Flutter's PlayStoreDeferredComponentManager).
# We don't bundle Play Core, so suppress the missing-class errors.
-dontwarn com.google.android.play.core.**
-dontwarn com.google.android.play.**

# Drift (SQLite)
-keep class * extends androidx.sqlite.db.SupportSQLiteOpenHelper { *; }
-dontwarn androidx.sqlite.**

# Riverpod / state
-keep class com.riverpod.** { *; }

# Dio / OkHttp
-dontwarn okhttp3.internal.platform.**
-dontwarn org.conscrypt.**
-dontwarn org.bouncycastle.**
-dontwarn org.openjsse.**

# Models (often serialized via reflection; we use json_serializable so this
# is just defensive)
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.retailos.mobile.** { *; }
