#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import <simd/simd.h>
#import "AppDelegate.h"
#import "RendererApp.h"
#import "include/Cocoa_API.h"

input_t* INPUT = NULL;

void launch_app() {
    INPUT = (input_t*) malloc(sizeof(input_t));
    RendererApp* app = [RendererApp sharedApplication];
    [app setDelegate:[[AppDelegate alloc] init]];
    [app setup];
    clear_input();
}

void update_view(bool* shouldRun) {
    RendererApp* app = [RendererApp sharedApplication];
    if (app && app.shouldKeepRunning) [app updateView];
    *shouldRun = app.shouldKeepRunning;
    if (!app.shouldKeepRunning && INPUT) {
        free(INPUT);
        INPUT = NULL;
    }
}

static void reset_input() {
    
    memset(&INPUT->click_down, 0, 3*sizeof(bool));
    memset(&INPUT->click_up, 0, 3*sizeof(bool));
}

void process_event(bool* shouldRun) {
    reset_input();
    RendererApp* app = [RendererApp sharedApplication];
    if (app && app.shouldKeepRunning) [app processNextEvent];
    *shouldRun = app.shouldKeepRunning;
    if (!app.shouldKeepRunning && INPUT) {
        free(INPUT);
        INPUT = NULL;
    }
}

void clear_input() {
    memset(INPUT, 0, sizeof(input_t));
}
