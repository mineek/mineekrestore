@import Foundation;

void AMDSetLogLevel(int a1);
void AMRestoreSetLogLevel(int a1);
void AMRestoreEnableFileLogging(const char *path);

enum {
    kAMDeviceNormalMode = 0,
    kAMDeviceRestoreMode = 1,
    kAMDeviceRecoveryMode = 2,
    kAMDeviceDFUMode = 3,
    kAMDeviceNoMode = 4
};
typedef int AMDeviceMode;

typedef enum {
    kAMStatusSuccess = 0,
    kAMStatusFailure = !kAMStatusSuccess
} AMStatus;

typedef enum {
    kAMDeviceNotificationMessageConnected = 1,
    kAMDeviceNotificationMessageDisconnected = 2,
    kAMDeviceNotificationMessageUnsubscribed = 3
} AMDeviceNotificationMessage;

typedef struct __AMDevice *AMDeviceRef;
typedef struct __AMRecoveryModeDevice *AMRecoveryModeDeviceRef;
typedef struct __AMDFUModeDevice *AMDFUModeDeviceRef;
typedef struct __AMRestoreModeDevice *AMRestoreModeDeviceRef;

typedef unsigned char *AMDeviceSubscriptionRef;

typedef struct {
    AMDeviceRef                     device;
    AMDeviceNotificationMessage     message;
    AMDeviceSubscriptionRef         subscription;
} *AMDeviceNotificationRef;

typedef void (* AMRecoveryModeDeviceConnectionCallback)(AMRecoveryModeDeviceRef device);
typedef void (* AMDFUModeDeviceConnectionCallback)(AMDFUModeDeviceRef device);
typedef void (* AMDeviceConnectionCallback)(AMDeviceNotificationRef notification);
typedef void (* AMRestoreCallback)(void* a);

AMStatus AMRestoreRegisterForDeviceNotifications(AMDFUModeDeviceConnectionCallback DFUConnectCallback, AMRecoveryModeDeviceConnectionCallback recoveryConnectCallback, AMDFUModeDeviceConnectionCallback DFUDisconnectCallback, AMRecoveryModeDeviceConnectionCallback recoveryDisconnectCallback, unsigned int alwaysZero, void *userInfo);

CFMutableDictionaryRef AMRestoreCreateDefaultOptions(CFAllocatorRef allocator);

AMStatus AMRestorePerformDFURestore(AMDFUModeDeviceRef device, CFDictionaryRef restoreOptions, AMRestoreCallback callback, void *userInfo);
AMStatus AMRestorePerformRecoveryModeRestore(AMRecoveryModeDeviceRef device, CFDictionaryRef restoreOptions, AMRestoreCallback callback, void *userInfo);

int AMRestorableDeviceRegisterForNotifications(void *eventHandler, void *arg, CFErrorRef *err);

typedef void *AMRestorableDeviceRef;

void* AMRestorableDeviceRestore(AMRestorableDeviceRef device, CFDictionaryRef options, void (*progressCallback)(AMRestorableDeviceRef device, CFDictionaryRef data, void *arg), void *a4);

CFDictionaryRef AMRestorableDeviceCopyDefaultRestoreOptions(void);

static int clientID;

CFDictionaryRef getOptions() {
    CFDictionaryRef options = AMRestorableDeviceCopyDefaultRestoreOptions();
    if (!options) {
        NSLog(@"Failed to get default restore options");
        return NULL;
    }
    CFMutableDictionaryRef mutableOptions = CFDictionaryCreateMutableCopy(kCFAllocatorDefault, 0, options);
    CFRelease(options);
    if (!mutableOptions) {
        NSLog(@"Failed to create mutable copy of restore options");
        return NULL;
    }
    CFDictionarySetValue(mutableOptions, CFSTR("RestoreBundlePath"), CFSTR("/Users/mineek/Downloads/macosipsw"));
    CFDictionarySetValue(mutableOptions, CFSTR("AuthInstallVariant"), CFSTR("Customer Erase Install (IPSW)"));
    // return mutableOptions;
    CFDictionaryRef optionsCopy = CFDictionaryCreateCopy(kCFAllocatorDefault, mutableOptions);
    CFRelease(mutableOptions);
    return optionsCopy;
}

static void eventHandler(AMRestorableDeviceRef _device, int type, void *arg) {
    if (type == 0) {
        AMRestorableDeviceRestore(_device, getOptions(), NULL, (void *)0xdeadbeef);
    }
}

int main(int argc, const char * argv[]) {
    AMDSetLogLevel(INT_MAX);
    AMRestoreSetLogLevel(INT_MAX);
    AMRestoreEnableFileLogging("/dev/stderr");
    CFErrorRef err;
    clientID = AMRestorableDeviceRegisterForNotifications(eventHandler, (void *)0xdeadbeef, &err);
    if(!clientID) {
        printf("Failed to register for notifications.");
        return 1;
    }
    CFRunLoopRun();
    return 0;
}
