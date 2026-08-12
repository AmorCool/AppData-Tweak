//
//  TCC.m
//  AppData
//
//  Created by udevs on 21/11/2020.
//

#import <Foundation/Foundation.h>
#import <dlfcn.h>
#import "ADTCC.h"

NSString *kTCCServiceAll = @"kTCCServiceAll";

static int (*TCCAccessResetForBundle_Ptr) (NSString *, CFBundleRef);
static CFArrayRef (*TCCAccessCopyInformationForBundle_Ptr)(CFBundleRef);


int TCCAccessResetForBundle(NSString *service, CFBundleRef bundle) {
    return TCCAccessResetForBundle_Ptr ? TCCAccessResetForBundle_Ptr(service, bundle) : 0;
}

NSArray<NSDictionary *> *TCCAccessCopyInformationForBundle(CFBundleRef bundle) {
    if (TCCAccessCopyInformationForBundle_Ptr) {
        CFArrayRef array = TCCAccessCopyInformationForBundle_Ptr(bundle);
        NSArray *objcArray = (__bridge_transfer NSArray *)array;
        return [objcArray copy];
    }
    return NULL;
}


__attribute__((constructor))
static void initializeFunctions() {
    void *handle = dlopen("/System/Library/PrivateFrameworks/TCC.framework/TCC", RTLD_LAZY);
    if (handle) {
        TCCAccessResetForBundle_Ptr = dlsym(handle, "TCCAccessResetForBundle");
        TCCAccessCopyInformationForBundle_Ptr = dlsym(handle, "TCCAccessCopyInformationForBundle");
        // kTCCServiceAll is a global NSString * in TCC; use the real symbol instead of a guessed literal.
        NSString **realServiceAll = (NSString **)dlsym(handle, "kTCCServiceAll");
        if (realServiceAll) {
            kTCCServiceAll = *realServiceAll;
        }
        dlclose(handle);
    }
}
