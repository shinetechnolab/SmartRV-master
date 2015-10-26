//
//  TTPOIAnnotation.h
//  TruckRoute
//
//  Created by admin on 3/21/13.
//  Copyright (c) 2013 admin. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "TTPOI.h"

@interface TTPOIAnnotation : MKPointAnnotation

@property (nonatomic, retain) TTPOI *poi;

@end
