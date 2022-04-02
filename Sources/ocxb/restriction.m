//
//  restriction.m
//  ocxb
//
//  Created by Rocco Bowling on 3/28/09.
//  Copyright 2009 Feline Entertainment. All rights reserved.
//

#import "restriction.h"
#import "simpleType.h"

@implementation restriction

- (void) pre_export
{
	simpleType * ancestor_simpleType = (simpleType *)[self ancestorOfType:[simpleType class]];
	
	if(ancestor_simpleType != NULL)
	{
		ancestor_simpleType.base = [self get:@"base"];
	}
}

@end
