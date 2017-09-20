#import "LTSProgressWindowController.h"

@implementation LTSProgressWindowController

#pragma mark Initialization and deallocation

- (instancetype) initWithWindow:(NSWindow *)window {
    if (self = [super initWithWindow:window]) {
        [self addObserver:self forKeyPath:@"request" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void) dealloc {
    [self removeObserver:self forKeyPath:@"request"];
}

#pragma mark NSKeyValueObserving

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"request"]) {
        if (self.request) {
            self.request.delegate = self;
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark ASIHTTPRequestDelegate

- (void) requestFailed:(ASIHTTPRequest *)request {
    [self.parent.window endSheet:self.window];
}

- (void) requestFinished:(ASIHTTPRequest *)request {
    [self.parent.window endSheet:self.window];
}

@end
