//
//  SRHeadHitIAPHelper.m
//  HeadHit
//
//  Created by Rotek on 3/4/13.
//  Copyright (c) 2013 Rotek. All rights reserved.
//

#import "SRProtractorIAPHelper.h"
#import "SRAppID.h"

@implementation SRProtractorIAPHelper

+ (SRProtractorIAPHelper *)sharedInstance
{
    static dispatch_once_t onceToken;
    static SRProtractorIAPHelper *sharedInstance;
    dispatch_once(&onceToken, ^{
        NSSet *productIdentifiers = [NSSet setWithObjects:
                                     K_CAMERA_ANGLE_MODE,
                                     K_SLOPE_ANGLE_MODE,
                                     K_DIHEDRAL_ANGLE_MODE,
                                     K_LINE_PLANE_ANGLE_MODE,
                                     nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return sharedInstance;
}

@end
