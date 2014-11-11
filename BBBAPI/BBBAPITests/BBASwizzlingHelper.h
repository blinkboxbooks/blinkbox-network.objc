//
//  BBASwizzlingHelper.h
//  BBAIosApp
//
//  Created by Tomek Kuźma on 19/06/2014.
//  Copyright (c) 2014 blinkbox Entertainment Ltd. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <objc/message.h>

void SwizzleInstanceMethod(Class c, SEL orig, SEL new);
void SwizzleClassMethod(Class c, SEL orig, SEL new);
void SwizzleClassMethodWithBlock(Class c, SEL orig, id block);
void DeSwizzleClassMethod(Class c, SEL orig, IMP origImpl);
IMP ImplementationOfMethod(Class c, SEL sel);
void SetImplementationOfSelector(Class c, SEL sel, IMP imp);
IMP SwizzleInstanceMethodWithBlock(Class c, SEL orig, id block);

/**
 *  This macro replaces method for `selector` for every instance of `class`
 *  with the `block`. Must be followed by `BBA_DESWIZZLE_INSTANCE_METHOD` which 
 *  reverts the change. Only one method in the scope can be swizzled at the moment
 *
 *  @param class    class to replace a method
 *  @param selector valid selector to object of `class`
 *  @param block    non nil block
 */
#define BBA_SWIZZLE_INSTANCE_METHOD_WITH_BLOCK(class, selector, block) Method originalMethod = class_getInstanceMethod(class,selector); \
IMP newImplementation = imp_implementationWithBlock(block); \
IMP oldImp = class_replaceMethod(class, selector, newImplementation, method_getTypeEncoding(originalMethod))

/**
 *  This macros deswizzles the method replaced with `BBA_SWIZZLE_INSTANCE_METHOD_WITH_BLOCK`
 */
#define BBA_DESWIZZLE_INSTANCE_METHOD(class, selector) class_replaceMethod(class, selector, oldImp, method_getTypeEncoding(originalMethod))