//
//  appinfo.m
//  ocxb
//
//  Created by Rocco Bowling on 3/28/09.
//  Copyright 2009 Feline Entertainment. All rights reserved.
//

#import "appinfo.h"
#import "simpleType.h"
#import "complexType.h"

@implementation appinfo

- (void) pre_export
{
	simpleType * ancestor_simpleType = (simpleType *)[self ancestorOfType:[simpleType class]];
	
	if(ancestor_simpleType != NULL)
	{
		ancestor_simpleType.appinfo = contents;
	}
	
	complexType * ancestor_complexType = (complexType *)[self ancestorOfType:[complexType class]];
	
	if(ancestor_complexType != NULL && [ancestor_complexType get:@"name"] != NULL)
	{
		NSArray * parts = [contents componentsSeparatedByString:@"|"];
		
		if([parts count] == 1)
		{
			[ancestor_complexType.header_declarations appendFormat:@"%@\n", contents];
		}
		if([parts count] == 2)
		{
			[ancestor_complexType.header_declarations appendFormat:@"%@\n", [parts objectAtIndex:1]];
			
			if([[parts objectAtIndex:0] hasPrefix:@"#"])
			{
				[ancestor_complexType.header_includes setString:[NSString stringWithFormat:@"#import \"%@.h\";\n%@", [[parts objectAtIndex:0] substringFromIndex:1], ancestor_complexType.header_includes]];
			}
			else
			{
				[ancestor_complexType.header_includes appendFormat:@"@class %@;\n", [parts objectAtIndex:0]];
			}
		}
	}
	
	element * ancestor_element = (element *)[self ancestorOfType:[element class]];
	
	if(ancestor_element != NULL)
	{
		NSArray * parts = [contents componentsSeparatedByString:@"|"];
		
		if([parts count] == 1)
		{
			[ancestor_element.header_declarations appendFormat:@"%@\n", contents];
		}
		if([parts count] == 2)
		{
			[ancestor_element.header_declarations appendFormat:@"%@\n", [parts objectAtIndex:1]];
			
			if([[parts objectAtIndex:0] hasPrefix:@"#"])
			{
				[ancestor_element.header_includes setString:[NSString stringWithFormat:@"#import \"%@.h\";\n%@", [[parts objectAtIndex:0] substringFromIndex:1], ancestor_element.header_includes]];
			}
			else
			{
				[ancestor_element.header_includes appendFormat:@"@class %@;\n", [parts objectAtIndex:0]];
			}
			
		}
	}
}

@end
