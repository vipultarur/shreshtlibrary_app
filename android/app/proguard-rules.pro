# Flutter Wrapper Rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.provider.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# Generated Plugin Registrant
-keep class io.flutter.plugins.GeneratedPluginRegistrant { *; }

# Gson / JSON keeping for models
-keepattributes *Annotation*,Signature,InnerClasses,EnclosingMethod
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Flutter Background Service
-keep class id.flutter.flutter_background_service.** { *; }

# Razorpay SDK
-keep class com.razorpay.** { *; }
-dontwarn com.razorpay.**
-keepattributes *Annotation*,*JavascriptInterface*
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# Firebase & Google Play Services
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Dio & OkHttp
-keep class dio.** { *; }
-keep class okhttp3.** { *; }
-dontwarn okhttp3.**
-dontwarn okio.**

# Hive DB
-keep class com.hive.** { *; }
-dontwarn com.hive.**

# Sensor Plus & Mobile Scanner
-keep class dev.fluttercommunity.plus.sensors.** { *; }
-keep class dev.barteksc.pdfviewer.** { *; }
