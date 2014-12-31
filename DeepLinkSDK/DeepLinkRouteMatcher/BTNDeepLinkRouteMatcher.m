#import "BTNDeepLinkRouteMatcher.h"
#import "BTNDeepLink_Private.h"
#import "NSString+BTNTrim.h"

@interface BTNDeepLinkRouteMatcher ()

@property (nonatomic, copy)   NSString *route;
@property (nonatomic, strong) NSArray  *routeParts;

@end

@implementation BTNDeepLinkRouteMatcher

+ (instancetype)matcherWithRoute:(NSString *)route {
    return [[self alloc] initWithRoute:route];
}


- (instancetype)initWithRoute:(NSString *)route {
    if (![route length]) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        _route      = route;
        _routeParts = [_route componentsSeparatedByString:@"/"];
    }
    
    return self;
}


- (BTNDeepLink *)deepLinkWithURL:(NSURL *)url {
    if (!url) {
        return nil;
    }
    
    BTNDeepLink *deepLink = [[BTNDeepLink alloc] initWithURL:url];
    
    NSArray *pathParts = [[[deepLink.URL path] BTN_trimPath] componentsSeparatedByString:@"/"];
    if ([pathParts count] != [self.routeParts count]) {
        return nil;
    }
    
    __block BOOL isMatch = NO;
    NSMutableDictionary *routeParameters = [NSMutableDictionary dictionary];
    
    [self.routeParts enumerateObjectsUsingBlock:^(NSString *routeComponent, NSUInteger idx, BOOL *stop) {
        NSString *pathComponent = pathParts[idx];
        
        if ([routeComponent rangeOfString:@":"].location == 0) {
            isMatch = YES;
            
            NSString *key = [routeComponent stringByReplacingOccurrencesOfString:@":" withString:@""];
            routeParameters[key] = pathComponent;
        }
        else if ([pathComponent isEqualToString:routeComponent]) {
            isMatch = YES;
        }
        else {
            isMatch = NO;
            *stop   = YES;
        }
    }];
    
    deepLink.routeParameters = routeParameters;
    
    return isMatch ? deepLink : nil;
}

@end
