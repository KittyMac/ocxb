//
//  simpleType.m
//  ocxb
//
//  Created by Rocco Bowling on 3/28/09.
//  Copyright 2009 Feline Entertainment. All rights reserved.
//

#import "simpleType.h"


@implementation simpleType

@synthesize maxLength;
@synthesize base;
@synthesize appinfo;

- (void) setBase:(NSString *) value
{
    base = value;
	
	if([self get:@"name"] != NULL)
	{
		if(appinfo == NULL)
		{
			[schema_object markConversionFromType:[self get:@"name"] ToType:value];
		}
		else
		{
			[schema_object markConversionFromType:[self get:@"name"] ToType:appinfo];
		}
	}
	else
	{
		
	}
}

@end
