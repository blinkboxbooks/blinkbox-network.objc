//
//  BBASwizzlingHelper.m
//  BBAIosApp
//
//  Created by Tomek Kuźma on 19/06/2014.
//  Copyright (c) 2014 blinkbox Entertainment Ltd. All rights reserved.
//

#import "BBASwizzlingHelper.h"


void SwizzleInstanceMethod(Class c, SEL orig, SEL new) {
    Method originalMethod = class_getInstanceMethod(c, orig);
    Method overrideMethod = class_getInstanceMethod(c, new);
    if (class_addMethod(c, orig, method_getImplementation(overrideMethod), method_getTypeEncoding(overrideMethod))) {
        class_replaceMethod(c, new, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, overrideMethod);
    }
}

IMP SwizzleInstanceMethodWithBlock(Class c, SEL orig, id block){
    Method originalMethod = class_getInstanceMethod(c,orig);
    IMP newImplementation = imp_implementationWithBlock(block);
    IMP oldImp = class_replaceMethod(c, orig, newImplementation, method_getTypeEncoding(originalMethod));
    return oldImp;
}

void SwizzleClassMethodWithBlock(Class c, SEL orig, id block) {
    c = object_getClass((id)c);
    Method originalMethod = class_getClassMethod(c, orig);
    IMP newImplementation = imp_implementationWithBlock(block);
    method_setImplementation(originalMethod, newImplementation);
}

void DeSwizzleClassMethod(Class c, SEL orig, IMP origImpl) {
    c = object_getClass((id)c);
    Method originalMethod = class_getClassMethod(c, orig);
    method_setImplementation(originalMethod, origImpl);
}

IMP ImplementationOfMethod(Class c, SEL sel){
    return class_getMethodImplementation(c, sel);
}

void SwizzleClassMethod(Class c, SEL orig, SEL new) {   
    
    Method origMethod = class_getClassMethod(c, orig);
    Method newMethod = class_getClassMethod(c, new);
    
    c = object_getClass((id)c);
    
    if(class_addMethod(c, orig, method_getImplementation(newMethod), method_getTypeEncoding(newMethod)))
        class_replaceMethod(c, new, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    else
        method_exchangeImplementations(origMethod, newMethod);
}

void SetImplementationOfSelector(Class c, SEL sel, IMP imp){
    Method method = class_getClassMethod(c, sel);
    method_setImplementation(method, imp);
}