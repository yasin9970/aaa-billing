#!/bin/bash
set -e

# 1. Clean & create Android files
rm -rf android
flutter create . --platforms=android --no-pub

# 2. Write exact build.gradle.kts with compileSdk 34, minSdk 21 & disabled AarMetadata check
cat << 'KTS' > android/app/build.gradle.kts
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.aaa_billing"
    compileSdk = 34

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    defaultConfig {
        applicationId = "com.example.aaa_billing"
        minSdk = 21
        targetSdk = 34
        versionCode = 1
        versionName = "1.0.0"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}

tasks.configureEach {
    if (name.contains("AarMetadata")) {
        enabled = false
    }
}
KTS

# 3. Update AndroidManifest to avoid manifest merger conflicts
python3 -c '
import os
mf = "android/app/src/main/AndroidManifest.xml"
if os.path.exists(mf):
    with open(mf, "r") as f:
        content = f.read()
    if "xmlns:tools" not in content:
        content = content.replace("<manifest ", "<manifest xmlns:tools=\"http://schemas.android.com/tools\" ")
    if "<uses-sdk" not in content:
        content = content.replace("<application", "<uses-sdk android:minSdkVersion=\"21\" android:targetSdkVersion=\"34\" tools:overrideLibrary=\"net.nfet.flutter.printing,com.tekartik.sqflite\" />\n    <application")
    with open(mf, "w") as f:
        f.write(content)
    print("Manifest updated successfully!")
'

# 4. Remove default XML icons and set our custom aaabill icon
rm -rf android/app/src/main/res/mipmap-anydpi-v26
mkdir -p android/app/src/main/res/mipmap-mdpi
mkdir -p android/app/src/main/res/mipmap-hdpi
mkdir -p android/app/src/main/res/mipmap-xhdpi
mkdir -p android/app/src/main/res/mipmap-xxhdpi
mkdir -p android/app/src/main/res/mipmap-xxxhdpi

if [ -f "assets/icon/app_icon.png" ] && [ -s "assets/icon/app_icon.png" ]; then
    cp assets/icon/app_icon.png android/app/src/main/res/mipmap-mdpi/ic_launcher.png
    cp assets/icon/app_icon.png android/app/src/main/res/mipmap-hdpi/ic_launcher.png
    cp assets/icon/app_icon.png android/app/src/main/res/mipmap-xhdpi/ic_launcher.png
    cp assets/icon/app_icon.png android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png
    cp assets/icon/app_icon.png android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png
    echo "Custom app icon placed in all mipmap folders!"
fi
