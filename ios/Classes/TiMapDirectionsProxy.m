/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2014年 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiUtils.h"
#import "TiMapDirectionsProxy.h"

@implementation TiMapDirectionsProxy

-(id)init
{
    if (self = [super init]) {
    }
    
    return self;
}

-(void)dealloc
{
    [super dealloc];
}

-(void)_initWithProperties:(NSDictionary*)properties
{
    id source = [properties valueForKey:@"source"];
    id destination = [properties valueForKey:@"destination"];
    
    if (source != nil && destination != nil)
    {
        CLLocationCoordinate2D sourceCoordinate = [self locationCoordinatesFromDict:source];
        CLLocationCoordinate2D destinationCoordinate = [self locationCoordinatesFromDict:destination];
        
        MKPlacemark *sourcePlacemark = [[MKPlacemark alloc] initWithCoordinate:sourceCoordinate
                                                             addressDictionary:nil];
        MKPlacemark *destinationPlacemark = [[MKPlacemark alloc] initWithCoordinate:destinationCoordinate
                                                             addressDictionary:nil];
        
        MKMapItem *sourceItem_ = [[MKMapItem alloc] initWithPlacemark:sourcePlacemark];
        MKMapItem *destinationItem_ = [[MKMapItem alloc] initWithPlacemark:destinationPlacemark];
        
        MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
        [request setSource:sourceItem_];
        [request setDestination:destinationItem_];
        
        MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
        [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error){
            if (error)
            {
                if ([self _hasListeners:@"error"])
                {
                    [self fireEvent:@"error" withObject:nil];
                }
                
                return;
            }
            
            if ([response.routes count] > 0)
            {
                MKRoute *route = [response.routes objectAtIndex:0];
                NSUInteger pointCount = route.polyline.pointCount;
                CLLocationCoordinate2D *routeCoordinates = malloc(pointCount * sizeof(CLLocationCoordinate2D));
                [route.polyline getCoordinates:routeCoordinates
                                         range:NSMakeRange(0, pointCount)];
                
                NSMutableArray *coordinates = [NSMutableArray array];
                
                for (int i = 0; i < pointCount; i++)
                {
                    [coordinates addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                            NUMDOUBLE(routeCoordinates[i].latitude), @"latitude",
                                            NUMDOUBLE(routeCoordinates[i].longitude), @"longitude",
                                            nil]];
                }
                
                if ([self _hasListeners:@"success"])
                {
                    [self fireEvent:@"success" withObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                                           coordinates, @"coordinates",
                                                           nil]];
                }
                
                free(routeCoordinates);
            }
        }];
    }
    
    [super _initWithProperties:properties];
}


# pragma mark Utils

-(CLLocationCoordinate2D)locationCoordinatesFromDict:(NSDictionary*)dict
{
    CLLocationCoordinate2D result;
    result.latitude = [TiUtils doubleValue:[dict valueForKey:@"latitude"]];
    result.longitude = [TiUtils doubleValue:[dict valueForKey:@"longitude"]];
    return result;
}

@end
