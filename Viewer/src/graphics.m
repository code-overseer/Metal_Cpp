#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "../include/graphics.h"
#import "../include/AppDelegate.h"
#import "../include/ViewerApp.h"
#import <simd/simd.h>


void launch_app() {
    ViewerApp* app = [ViewerApp sharedApplication];
    
    [app setDelegate:[[AppDelegate alloc] init]];
    
    [app setup];
}

char update_view() {
    ViewerApp* app = [ViewerApp sharedApplication];
    if (app && app.shouldKeepRunning) [app update];
    return app.shouldKeepRunning ? 1 : 0;
}

static simd_float4x4 mat;

void* get_simd_float4x4() {
    mat = simd_matrix(simd_make_float4(0.5,0,0,0),
                                    simd_make_float4(0,0.5,0,0),
                                    simd_make_float4(0,0,0.5,0),
                                    simd_make_float4(0,0.1,0,1));
    return &mat;
}
