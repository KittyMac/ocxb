//
//  extension.m
//  ocxb
//
//  Created by Rocco Bowling on 3/27/09.
//  Copyright 2009 Feline Entertainment. All rights reserved.
//

#import "extension.h"
#import "element.h"

extern NSMutableDictionary * config;

@implementation extension

@synthesize superclass;

- (void) pre_export
{
	element * ancestor_element = (element *)[self ancestorOfType:[element class]];
	
	if(ancestor_element != NULL)
	{
		NSString * base = [self get:@"base"];
		
		if([base rangeOfString:@":"].length > 0)
		{
			ancestor_element.class_superclass = [NSMutableString stringWithString:[[[self get:@"base"] componentsSeparatedByString:@":"] componentsJoinedByString:@"_"]];
		}
		else
		{
			ancestor_element.class_superclass = [NSMutableString stringWithString:[NSString stringWithFormat:@"%@_%@", [config objectForKey:@"prefix"], base]];
		}
		
		ancestor_element.custom_superclass = YES;
	}
}

@end
