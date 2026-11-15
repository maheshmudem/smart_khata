# Smart Khata R8 rules.
# Flutter's Gradle plugin already supplies the rules the engine needs.
# Add plugin-specific keep rules here only when a release build proves they
# are required, and note the plugin and reason next to each rule.

# flutter_local_notifications stores scheduled reminders as JSON with Gson
# and reads them back after a restart. Without these rules R8 strips the
# generic type information Gson needs and saved reminders cannot be read.
# Rules from the Gson project's Android example.
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**
-keep class com.google.gson.reflect.TypeToken { *; }
-keep class * extends com.google.gson.reflect.TypeToken
-keep class * extends com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer
-keepclassmembers,allowobfuscation class * {
  @com.google.gson.annotations.SerializedName <fields>;
}
-keep class com.dexterous.flutterlocalnotifications.** { *; }
