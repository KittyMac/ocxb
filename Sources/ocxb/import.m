//
//  import.m
//  ocxb
//
//  Created by Rocco Bowling on 3/28/09.
//  Copyright 2009 Feline Entertainment. All rights reserved.
//

#import "import.h"
#import "simpleType.h"
#import "schema.h"

extern const char * executable_location;
extern NSMutableString * gcc_flags;
extern NSMutableDictionary * config;

@implementation import

- (void) pre_export
{
	// We need to run ocxb on the remote file...
	NSString * base_path = [[config objectForKey:@"file"] stringByDeletingLastPathComponent];
	
	if([base_path length] > 0)
	{
		base_path = [base_path stringByAppendingString:@"/"];
	}
	
	NSMutableArray * args = [NSMutableArray array];
	
	
	[args addObject:[NSString stringWithFormat:@"%s", executable_location]];
	[args addObject:[NSString stringWithFormat:@"file=%@%@", base_path, [self get:@"schemaLocation"]]];
	[args addObject:[NSString stringWithFormat:@"exportTypes=yes"]];
	
	for(NSString * key in [config allKeys])
	{
		if(	[key isEqualToString:@"file"] == NO &&
			[key isEqualToString:@"framework"] == NO &&
			[key isEqualToString:@"prefix"] == NO &&
			[key isEqualToString:@"fullNamespace"] == NO &&
			[key isEqualToString:@"namespaceMap"] == NO &&
			[key isEqualToString:@"currentNamespace"] == NO)
		{
			[args addObject:[NSString stringWithFormat:@"%@=%@ ", key, [config objectForKey:key]]];
		}
	}
	
	NSTask * ocxb_task = [[NSTask alloc] init];
	NSPipe * newPipe = [NSPipe pipe];
    NSFileHandle * readHandle = [newPipe fileHandleForReading];
    NSData * inData = nil;
	NSMutableData * all_data = [NSMutableData data];
	
	[ocxb_task setStandardError:[NSFileHandle fileHandleWithNullDevice]];
	[ocxb_task setStandardOutput:newPipe];
	
	[ocxb_task setArguments:args];
	[ocxb_task setLaunchPath:[NSString stringWithUTF8String:executable_location]];
	
	[ocxb_task launch];
		
	while ([ocxb_task isRunning] && (inData = [readHandle availableData]) && [inData length])
	{
		[all_data appendData:inData];
    }
	
	NSString * lines = [[NSString alloc] initWithData:all_data encoding:NSUTF8StringEncoding];
	NSArray * parts = [lines componentsSeparatedByString:@"\n"];
	
	for(NSString * line in parts)
	{
		NSArray * conversion_parts = [line componentsSeparatedByString:@"="];
		if([conversion_parts count] == 2)
		{
			// This is a type conversion  (typeA=typeB)
			[schema_object markConversionFromType:[conversion_parts objectAtIndex:0] ToType:[conversion_parts objectAtIndex:1]];
		}
		else
		{
			NSArray * conversion_parts = [line componentsSeparatedByString:@":"];
			
			if([conversion_parts count] == 2)
			{
				// This is an enumeration for type (typeA:enum1,enum2,enum3,enum4,enum5)
				NSArray * enumerations_parts = [[conversion_parts objectAtIndex:1] componentsSeparatedByString:@","];
				
				for(NSString * enumeration_value in enumerations_parts)
				{
					[schema_object addEnumeration:enumeration_value ForType:[conversion_parts objectAtIndex:0]];
				}
			}
		}
	}
		
	[ocxb_task waitUntilExit];
	
	// Tell the schema object about them, we need to force initialize them...
	schema * ancestor_schema = (schema *)[self ancestorOfType:[schema class]];
	if(ancestor_schema != NULL)
	{
		[ancestor_schema.all_import_imports appendFormat:@"  #import \"%@_XMLLoader.h\"\n", [[self get:@"namespace"] lastPathComponent]];
		[ancestor_schema.all_import_inits appendFormat:@"  [%@_XMLLoader initialize];\n", [[self get:@"namespace"] lastPathComponent]];
	}
	
	
	// Need the targetNamespace 
	
	[gcc_flags appendFormat:@" -I %@/%@.iphone/Headers/", [config objectForKey:@"output"], [[self get:@"namespace"] lastPathComponent]];
	[gcc_flags appendFormat:@" -I %@/%@.framework/Headers/", [config objectForKey:@"output"], [[self get:@"namespace"] lastPathComponent]];
}

@end
