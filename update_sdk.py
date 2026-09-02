import os
import re

# 1. Update android/app/build.gradle.kts
kts_path = 'android/app/build.gradle.kts'
if os.path.exists(kts_path):
    with open(kts_path, 'r') as f:
        code = f.read()
    code = re.sub(r'compileSdk\s*=.*', 'compileSdk = 34', code)
    code = re.sub(r'minSdk\s*=.*', 'minSdk = 21', code)
    code = re.sub(r'targetSdk\s*=.*', 'targetSdk = 34', code)
    with open(kts_path, 'w') as f:
        f.write(code)
    print("Successfully updated " + kts_path)

# 2. Update android/app/build.gradle (if Groovy DSL)
groovy_path = 'android/app/build.gradle'
if os.path.exists(groovy_path):
    with open(groovy_path, 'r') as f:
        code = f.read()
    code = re.sub(r'compileSdkVersion\s+.*', 'compileSdkVersion 34', code)
    code = re.sub(r'minSdkVersion\s+.*', 'minSdkVersion 21', code)
    code = re.sub(r'targetSdkVersion\s+.*', 'targetSdkVersion 34', code)
    with open(groovy_path, 'w') as f:
        f.write(code)
    print("Successfully updated " + groovy_path)

# 3. Add to android/gradle.properties
prop_path = 'android/gradle.properties'
if os.path.exists(prop_path):
    with open(prop_path, 'a') as f:
        f.write('\nflutter.compileSdkVersion=34\n')
        f.write('flutter.minSdkVersion=21\n')
        f.write('flutter.targetSdkVersion=34\n')
    print("Successfully updated " + prop_path)
