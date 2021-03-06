/* Copyright © 2019 Mastercard. All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 =============================================================================*/

#import <UIKit/UIKit.h>
#import "MCSCommerceWeb.h"
#import "MCSCheckoutButtonManager.h"
#import "MCSConfigurationManager.h"
#import "MCFEnvironmentConfiguration.h"
#import "MCCSVGImage.h"
#import "MCSCheckoutButton+Private.h"

NSString *const kMasterPassDefaultButtonImage       = @"MasterpassButton";

@interface MCSCheckoutButtonManager()

@property(nonatomic, strong, nullable) UIImage *buttonImage;
@property(nonatomic, strong) MCCSVGImage *svg;

@end

@implementation MCSCheckoutButtonManager
static MCSCheckoutButtonManager *sharedManager = nil;
NSString *basePath = @"button/";

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
        [sharedManager initialize];
    });
    
    return sharedManager;
}

- (MCSCheckoutButton *)checkoutButtonWithDelegate:(__autoreleasing id<MCSCheckoutDelegate>)delegate {
    MCSCheckoutButton *checkoutButton = [[MCSCheckoutButton alloc] init];
    
    [checkoutButton setDelegate:delegate];
    [checkoutButton setButtonImage:self.buttonImage];
    
    return checkoutButton;
}

- (void)initialize {
    NSLocale *locale = [MCSConfigurationManager sharedManager].configuration.locale;
    NSSet *allowedCardTypes = [MCSConfigurationManager sharedManager].configuration.allowedCardTypes;
    NSString *checkoutId = [MCSConfigurationManager sharedManager].configuration.checkoutId;
    NSURL *buttonUrl = [NSURL URLWithString:[MCFEnvironmentConfiguration sharedInstance].buttonImageHost];
    NSString *fileName = [NSString stringWithFormat:@"%lu%lu", [locale hash], [allowedCardTypes hash]];
    NSURL *saveUrl = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    saveUrl = [saveUrl URLByAppendingPathComponent:fileName];
    
    //Check if image is cached
    NSData *buttonData = [NSData dataWithContentsOfFile:saveUrl.path];
    if (buttonData != nil) {
        UIImage *cacheImage = [UIImage imageWithData:buttonData];
        
        self.buttonImage = cacheImage;
    } else {
        // set default button image
        UIImage *defaultImg = [UIImage imageNamed:kMasterPassDefaultButtonImage inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
        self.buttonImage = defaultImg;
    }
    //Download image from URL
    NSURLComponents *components = [NSURLComponents componentsWithURL:buttonUrl resolvingAgainstBaseURL:YES];
    NSURLQueryItem *localeQueryItem = [[NSURLQueryItem alloc] initWithName:@"locale" value:locale.localeIdentifier];
    NSURLQueryItem *allowedCardsQueryItem = [[NSURLQueryItem alloc] initWithName:@"acceptedCardBrands" value:[allowedCardTypes.allObjects componentsJoinedByString:@","]];
    NSURLQueryItem *checkoutIdQueryItetm = [[NSURLQueryItem alloc] initWithName:@"checkoutId" value:checkoutId];
    
    [components setQueryItems:@[localeQueryItem, allowedCardsQueryItem, checkoutIdQueryItetm]];
    
    NSURLSession *session = [NSURLSession sharedSession];
    MCSCheckoutButtonManager * __weak weakSelf = self;
    [[session downloadTaskWithURL:components.URL completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error) {
            NSLog(@"Error: %@",[error localizedDescription]);
        } else {
        NSData *responseData = [NSData dataWithContentsOfURL:location];
        //save the data to file
        [weakSelf imageWithData:responseData completionHandler:^(UIImage *image) {
            NSData *imageData = UIImagePNGRepresentation(image);
            UIImage *cacheImage = [UIImage imageWithData:imageData];
            NSError *error = nil;
            
            [imageData writeToFile:saveUrl.path options:NSDataWritingAtomic error:&error];
            if (error) {
                NSLog(@"Error: %@",[error localizedDescription]);
            }
            
            weakSelf.buttonImage = cacheImage;
        }];
    }
        
    }] resume];
}

- (void)imageWithData:(NSData *)imageData completionHandler:(void (^)(UIImage *image))completionHandler {
    self.svg = [[MCCSVGImage alloc] init];
    
    [self.svg imageWithData:imageData andSize:CGSizeMake(kCheckoutButtonWidth, kCheckoutButtonHeight) completionBlock:^(UIImage * _Nullable image, NSError * _Nullable error) {
        completionHandler(image);
    }];
}

@end
