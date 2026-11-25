"""
بيجهّز مشروع أندرويد لإشعارات مساري المجدولة.
شغّله مرة واحدة من جذر المشروع بعد `flutter create .`:
    python tools/patch_android.py
(آمن لو اتشغّل أكتر من مرة)
"""
import pathlib
import sys

root = pathlib.Path('android/app')
manifest = root / 'src/main/AndroidManifest.xml'
if not manifest.exists():
    sys.exit('مش لاقي android/app — شغّل `flutter create .` الأول وبعدين السكريبت ده من جذر المشروع.')

m = manifest.read_text(encoding='utf-8')
perms = [
    'android.permission.POST_NOTIFICATIONS',
    'android.permission.RECEIVE_BOOT_COMPLETED',
    'android.permission.VIBRATE',
    'android.permission.SCHEDULE_EXACT_ALARM',
]
add_perms = ''.join(
    f'    <uses-permission android:name="{p}"/>\n' for p in perms if p not in m)
if add_perms:
    m = m.replace('<application', add_perms + '    <application', 1)

receivers = '''
        <receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
        <receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
            <intent-filter>
                <action android:name="android.intent.action.BOOT_COMPLETED"/>
                <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
                <action android:name="android.intent.action.QUICKBOOT_POWERON" />
                <action android:name="com.htc.intent.action.QUICKBOOT_POWERON"/>
            </intent-filter>
        </receiver>
'''
if 'ScheduledNotificationReceiver' not in m:
    m = m.replace('</application>', receivers + '    </application>', 1)
manifest.write_text(m, encoding='utf-8')
print('OK AndroidManifest.xml')

kts = root / 'build.gradle.kts'
groovy = root / 'build.gradle'
if kts.exists():
    g = kts.read_text(encoding='utf-8')
    if 'isCoreLibraryDesugaringEnabled' not in g:
        g = g.replace('compileOptions {', 'compileOptions {\n        isCoreLibraryDesugaringEnabled = true', 1)
    if 'desugar_jdk_libs' not in g:
        g += '\ndependencies {\n    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")\n}\n'
    kts.write_text(g, encoding='utf-8')
    print('OK build.gradle.kts')
elif groovy.exists():
    g = groovy.read_text(encoding='utf-8')
    if 'coreLibraryDesugaringEnabled' not in g:
        g = g.replace('compileOptions {', 'compileOptions {\n        coreLibraryDesugaringEnabled true', 1)
    if 'desugar_jdk_libs' not in g:
        g += "\ndependencies {\n    coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:2.1.4'\n}\n"
    groovy.write_text(g, encoding='utf-8')
    print('OK build.gradle')
else:
    sys.exit('مش لاقي build.gradle')
print('تمام - دلوقتي: flutter pub get ثم flutter run')
