//
//  attribute.m
//  ocxb
//
//  Created by Rocco Bowling on 3/27/09.
//  Copyright 2009 Feline Entertainment. All rights reserved.
//

#import "attribute.h"
#import "element.h"
#import "complexType.h"

@implementation attribute

- (void) pre_export
{
	element * ancestor_element = (element *)[self ancestorOfType:[element class]];
	
	if(ancestor_element == NULL)
	{
		ancestor_element = (element *)[self ancestorOfType:[complexType class]];
	}
	
	if(ancestor_element != NULL)
	{
		NSString * name = [[[self get:@"name"] componentsSeparatedByString:@":"] lastObject];
		NSString * type = [self get:@"type"];
		
		[ancestor_element.element_attributes addObject:[NSDictionary dictionaryWithObjectsAndKeys:
														name, @"name",
														type, @"type",
														NULL]];
		
		name = [self convertName:name];
		
		if(type != NULL && name != NULL)
		{
			NSString * vanilla_type = type;
			
			type = [self convertType:type];

			//[ancestor_element.header_prototypes appendFormat:@"#undef %@\n", name];
			[ancestor_element.header_declarations appendFormat:@"\t%@ %@;\n", type, name];
			
			if([type rangeOfString:@"*"].length != 0)
			{
				NSString * class_string = [NSString stringWithFormat:@"@class %@;\n", [type stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" *"]]];
				
				if([ancestor_element.header_prototypes rangeOfString:class_string].length == 0)
				{
					[ancestor_element.header_prototypes appendString:class_string];
				}
				
			
				[ancestor_element.header_properties appendFormat:@"@property(retain) %@ %@;\n", type, name];
				[ancestor_element.class_properties appendFormat:@"@synthesize %@;\n", name];
			}
			else
			{
				NSString * natural_type = [self cocoaConvertObject:name
													 ToNaturalType:vanilla_type];
				
				if(natural_type)
				{
					[ancestor_element.header_properties appendFormat:@"@property %@ %@;\n", type, name];
					[ancestor_element.header_properties appendFormat:@"@property (readonly) BOOL %@Exists;\n", name];
					[ancestor_element.header_declarations appendFormat:@"BOOL %@Exists;\n", name];
					[ancestor_element.class_properties appendFormat:@"@synthesize %@;\n", name];
					[ancestor_element.class_properties appendFormat:@"@synthesize %@Exists;\n", name];
					[ancestor_element.class_properties appendFormat:@"%@;\n\n", natural_type];
				}
				else
				{
					[ancestor_element.header_properties appendFormat:@"@property(nonatomic) %@ %@;\n", type, name];
					[ancestor_element.class_properties appendFormat:@"@synthesize %@;\n", name];
				}
			}
			
			[ancestor_element.header_methods appendFormat:@"- (void) %@WithString:(NSString *)string;\n", 
			 [[self setterName:name] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@":"]]];
			
			[ancestor_element.class_methods appendFormat:@"- (void) %@WithString:(NSString *)string { [self %@%@]; }\n", 
			 [[self setterName:name] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@":"]],
			 [self setterName:name],
			 [self cocoaConvertObject:@"string" ToTypeFromString:vanilla_type]];
		}
	}
}

@end
