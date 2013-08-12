//
//  main.m
//  RuntimeWidget
//
//  Created by Keith Lee on 1/29/13.
//  Copyright (c) 2013 Keith Lee. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are
//  permitted provided that the following conditions are met:
//
//   1. Redistributions of source code must retain the above copyright notice, this list of
//      conditions and the following disclaimer.
//
//   2. Redistributions in binary form must reproduce the above copyright notice, this list
//      of conditions and the following disclaimer in the documentation and/or other materials
//      provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY Keith Lee ''AS IS'' AND ANY EXPRESS OR IMPLIED
//  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
//  FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Keith Lee OR
//  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
//  ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//  The views and conclusions contained in the software and documentation are those of the
//  authors and should not be interpreted as representing official policies, either expressed
//  or implied, of Keith Lee.

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <objc/message.h>

static void display(id self, SEL _cmd)
{
  NSLog(@"Invoking method with selector %@ on %@ class instance",
        NSStringFromSelector(_cmd), [self className]);
}

int main(int argc, const char * argv[])
{
  @autoreleasepool
  {
    // Create a class pair
    Class WidgetClass = objc_allocateClassPair([NSObject class], "Widget", 0);
    
    // Add a method to the class
    const char *types = "v@:";
    class_addMethod(WidgetClass, @selector(display), (IMP)display, types);
    
    // Add an ivar to the class
    const char *height = "height";
    class_addIvar(WidgetClass, height, sizeof(id), rint(log2(sizeof(id))),
                  @encode(id));
    
    // Register the class
    objc_registerClassPair(WidgetClass);
    
    // Create a widget instance and set value of the ivar
    id widget = [[WidgetClass alloc] init];
    id value = [NSNumber numberWithInt:15];
    [widget setValue:value forKey:[NSString stringWithUTF8String:height]];
    NSLog(@"Widget instance height = %@",
          [widget valueForKey:[NSString stringWithUTF8String:height]]);

    // Send the widget a message
    objc_msgSend(widget, NSSelectorFromString(@"display"));

    // Dynamically add a variable (an associated object) to the widget
    NSNumber *width = [NSNumber numberWithInt:10];
    objc_setAssociatedObject(widget, @"width", width,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    // Retrieve the variable's value and display it
    id result = objc_getAssociatedObject(widget, @"width");
    NSLog(@"Widget instance width = %@", result);
  }
  return 0;
}

