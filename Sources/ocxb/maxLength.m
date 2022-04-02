//
//  maxLength.m
//  ocxb
//
//  Created by Rocco Bowling on 3/28/09.
//  Copyright 2009 Feline Entertainment. All rights reserved.
//

#import "maxLength.h"
#import "simpleType.h"

@implementation maxLength

- (void) pre_export
{
	simpleType * ancestor_simpleType = (simpleType *)[self ancestorOfType:[simpleType class]];
	
	if(ancestor_simpleType != NULL)
	{
		ancestor_simpleType.maxLength = [NSNumber numberWithInt:[[self get:@"value"] intValue]];
		
		if([ancestor_simpleType.base isEqualToString:@"string"])
		{
			ancestor_simpleType.base = [NSString stringWithFormat:@"string%@", [self get:@"value"]];
		}
	}
}

@end
