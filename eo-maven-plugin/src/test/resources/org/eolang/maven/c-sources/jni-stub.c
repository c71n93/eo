#include <jni.h>

JNIEXPORT jint JNICALL Java_org_eolang_maven_clib_JniStub_returnParam
  (JNIEnv* env, jclass klass, jint param) {
    return param;
}