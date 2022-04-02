//
//  simpleType.h
//  ocxb
//
//  Created by Rocco Bowling on 3/28/09.
//  Copyright 2009 Feline Entertainment. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "schema_object.h"

@interface simpleType : schema_object
{
	NSNumber * maxLength;
	NSString * base;
	NSString * appinfo;
}

@property(nonatomic, retain) NSNumber * maxLength;
@property(nonatomic, retain) NSString * base;
@property(nonatomic, retain) NSString * appinfo;

@end
