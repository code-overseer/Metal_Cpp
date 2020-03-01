#import "../include/AppView.h"
#import "../include/Renderer.h"

@interface AppView()

-(void)setupView;
-(void)setupMetal;

@end

@implementation AppView
{
    MTKView* _view;
    id<MTKViewDelegate> _renderer;
}

-(nonnull instancetype)init
{
    self = [super initWithFrame:NSZeroRect];
    if (self) {
        [self setupView];
        [self setupMetal];
    }
    return self;
}
-(void)setupView
{
    self.translatesAutoresizingMaskIntoConstraints = false;
}
-(void)setupMetal
{
    _view = [[MTKView alloc] init];
    [self addSubview:_view];
    _view.translatesAutoresizingMaskIntoConstraints = false;
    
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:_view
                         attribute:NSLayoutAttributeTrailing
                         relatedBy:NSLayoutRelationEqual
                         toItem:self
                         attribute:NSLayoutAttributeTrailing
                         multiplier:1.f
                         constant:0.f ]];
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:_view
                         attribute:NSLayoutAttributeLeading
                         relatedBy:NSLayoutRelationEqual
                         toItem:self
                         attribute:NSLayoutAttributeLeading
                         multiplier:1.f
                         constant:0.f ]];
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:_view
                         attribute:NSLayoutAttributeTop
                         relatedBy:NSLayoutRelationEqual
                         toItem:self
                         attribute:NSLayoutAttributeTop
                         multiplier:1.f
                         constant:0.f ]];
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:_view
                         attribute:NSLayoutAttributeBottom
                         relatedBy:NSLayoutRelationEqual
                         toItem:self
                         attribute:NSLayoutAttributeBottom
                         multiplier:1.f
                         constant:0.f ]];
    
    for (NSLayoutConstraint *constraint in self.constraints) {
        constraint.active = true;
    }
    _view.device = MTLCreateSystemDefaultDevice();
    _view.enableSetNeedsDisplay = true;
    
    _renderer = [[Renderer alloc] initWithMetalKitView:_view];
    _view.delegate = _renderer;

    
    _view.needsDisplay = true;
        
}

@end
