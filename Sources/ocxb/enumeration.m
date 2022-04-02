//
//  enumeration.m
//  ocxb
//
//  Created by Rocco Bowling on 3/28/09.
//  Copyright 2009 Feline Entertainment. All rights reserved.
//

#import "enumeration.h"
#import "simpleType.h"

@implementation enumeration

- (void) pre_export
{
	simpleType * ancestor_simpleType = (simpleType *)[self ancestorOfType:[simpleType class]];
	
	if(ancestor_simpleType != NULL)
	{
		[schema_object addEnumeration:[self get:@"value"]
							  ForType:[ancestor_simpleType get:@"name"]];
	}
}

@end
