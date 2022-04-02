//
//  any.m
//  ocxb
//
//  Created by Rocco Bowling on 3/27/09.
//  Copyright 2009 Feline Entertainment. All rights reserved.
//

#import "any.h"


@implementation any

- (void) pre_export
{
	[self set:@"any" key:@"name"];
	[self set:@"any" key:@"type"];
	
	[super pre_export];
}

@end
