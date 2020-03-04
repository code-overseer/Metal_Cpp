#ifndef AppView_h
#define AppView_h
#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import <MetalKit/MetalKit.h>



@interface Viewport : NSView

//-(nonnull instancetype)initWithAPI:(Metal_API*) api
-(void)draw;

@end
#endif
