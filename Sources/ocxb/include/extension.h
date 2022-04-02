//
//  extension.h
//  ocxb
//
//  Created by Rocco Bowling on 3/27/09.
//  Copyright 2009 Feline Entertainment. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "schema_object.h"

@interface extension : schema_object
{
	NSString * superclass;
}

@property(nonatomic, retain) NSString * superclass;

@end
