//
//  schema_object.m
//  ocxb
//
//  Created by Rocco Bowling on 3/27/09.
//  Copyright 2009 Feline Entertainment. All rights reserved.
//

#import "schema_object.h"
#import "schema.h"

extern NSMutableDictionary * config;

static NSMutableDictionary * all_conversion_types = NULL;
static NSMutableDictionary * all_enumeration_types = NULL;

@implementation schema_object

@synthesize node;
@synthesize contents;
@synthesize attributes;


+ (void) addEnumeration:(NSString *) value
				ForType:(NSString *) type
{
	if(all_enumeration_types == NULL)
	{
		all_enumeration_types = [NSMutableDictionary dictionary];
	}
	
	if([all_enumeration_types objectForKey:type] == NULL)
	{
		[all_enumeration_types setObject:[NSMutableArray array] forKey:type];
	}
	
	NSMutableArray * enum_array = [all_enumeration_types objectForKey:type];
	
	[enum_array addObject:value];
}

+ (NSArray *) enumerationsForType:(NSString *)type
{
	if([all_enumeration_types objectForKey:type])
	{
		return [all_enumeration_types objectForKey:type];
	}
	return NULL;
}



+ (void) markConversionFromType:(NSString *) from_type
						 ToType:(NSString *) to_type
{
	if(all_conversion_types == NULL)
	{
		all_conversion_types = [NSMutableDictionary dictionary];
	}
	
	[all_conversion_types setObject:[[to_type componentsSeparatedByString:@":"] lastObject] forKey:from_type];
}

+ (NSString *) convertedType:(NSString *)type
{
	if([all_conversion_types objectForKey:type])
	{
		return [all_conversion_types objectForKey:type];
	}
	return type;
}

- (id) init
{
	self = [super init];
	
	if(self)
	{
		[self setAttributes:[NSMutableDictionary dictionary]];
		[self setContents:@""];
	}
	
	return self;
}

- (void) dealloc
{
	if([config objectForKey:@"exportTypes"] != NULL)
	{
		for(NSString * key in [all_conversion_types allKeys])
		{
			fprintf(stdout, "%s=%s\n", [key UTF8String], [[all_conversion_types objectForKey:key] UTF8String]);
		}
		
		
		for(NSString * key in [all_enumeration_types allKeys])
		{
			NSArray * enums = [all_enumeration_types objectForKey:key];
			BOOL first = YES;
			
			fprintf(stdout, "%s:", [key UTF8String]);
			for(NSString * enum_value in enums)
			{
				if(first)
				{
					first = NO;
					fprintf(stdout, "%s", [enum_value UTF8String]);
				}
				else
				{
					fprintf(stdout, ",%s", [enum_value UTF8String]);
				}
			}
			fprintf(stdout, "\n");
		}
	}
}

- (void) set:(id)obj
		 key:(id)key
{
	[attributes setObject:obj forKey:key];
}

- (id) get:(id)key
{
	return [attributes objectForKey:key];
}

- (void) remove:(id)key
{
	[attributes removeObjectForKey:key];
}

- (void) pre_export
{
	
}

- (void) post_export
{
	
}

- (schema_object *) ancestorOfType:(Class)class
{
	NSTreeNode * root_node = node;
	
	while([root_node parentNode] != NULL)
	{
		root_node = [root_node parentNode];
		
		if([[root_node representedObject] isMemberOfClass:class])
		{
			return [root_node representedObject];
		}
	}
	
	return NULL;
}

- (schema_object *) schemaObjectOfClass:(Class)class
							   WithName:(NSString *)name
{
	schema * root_schema = (schema *)[self ancestorOfType:[schema class]];
	if(root_schema)
	{
		return [root_schema nodeWithName:name];
	}
	
	return NULL;
}


- (NSString *)convertType:(NSString *)type
{
	type = [[type componentsSeparatedByString:@":"] lastObject];
	type = [schema_object convertedType:type];
	
	if ([type isEqualToString:@"boolean"])
	{
		return @"BOOL";
	}
	if ([type isEqualToString:@"short"])
	{
		return @"short";
	}
	if ([type isEqualToString:@"int"])
	{
		return @"int";
	}
	if ([type isEqualToString:@"long"])
	{
		return @"long";
	}
	if ([type hasPrefix:@"string"])
	{
		return @"NSString *";
	}
	if ([type isEqualToString:@"base64Binary"])
	{
		return @"NSData *";
	}
	if ([type isEqualToString:@"decimal"])
	{
		return @"float";
	}
	if ([type isEqualToString:@"dateTime"])
	{
		return @"NSDate *";
	}
	if ([type isEqualToString:@"date"])
	{
		return @"NSDate *";
	}
	if ([type isEqualToString:@"byte"])
	{
		return @"char";
	}
	if ([type isEqualToString:@"double"])
	{
		return @"double";
	}
	if ([type isEqualToString:@"float"])
	{
		return @"float";
	}
	
	if ([type isEqualToString:@"any"])
	{
		return @"NSObject *";
	}
	
	return [NSString stringWithFormat:@"%@ *", type];
}

- (NSString *)cocoaConvertObject:(NSString *)name
				ToTypeFromString:(NSString *)type
{
	type = [[type componentsSeparatedByString:@":"] lastObject]; 
	type = [schema_object convertedType:type];
	
	if ([type isEqualToString:@"boolean"])
	{
		return [NSString stringWithFormat:@"([%@ isEqualToString:@\"true\"] ? YES : NO)", name];
	}
	if ([type isEqualToString:@"short"])
	{
		return [NSString stringWithFormat:@"[%@ intValue]", name];
	}
	if ([type isEqualToString:@"int"])
	{
		return [NSString stringWithFormat:@"[%@ intValue]", name];
	}
	if ([type isEqualToString:@"byte"])
	{
		return [NSString stringWithFormat:@"[%@ intValue]", name];
	}
	if ([type isEqualToString:@"long"])
	{
		return [NSString stringWithFormat:@"[%@ intValue]", name];
	}
	if ([type isEqualToString:@"string"])
	{
		return name;
	}
	if ([type hasPrefix:@"string"])
	{
		// this is a length limited string...
		return [NSString stringWithFormat:@"([%@ length] > %@ ? [%@ substringToIndex:%@] : %@)", name, [type substringFromIndex:6], name, [type substringFromIndex:6], name];
	}
	if ([type isEqualToString:@"base64Binary"])
	{
		return [NSString stringWithFormat:@"[NSData decode:%@]", name];
	}
	if ([type isEqualToString:@"dateTime"])
	{
		// 2008-09-18T10:27:37.269-04:00
		// %Y-%m-%dT%H:%M:%S
		return [NSString stringWithFormat:@"[self schemaDateTimeFromString:%@]", name];
	}
	if ([type isEqualToString:@"date"])
	{
		// 2008-09-18
		// %Y-%m-%d
		return [NSString stringWithFormat:@"[self schemaDateFromString:%@]", name];
	}
	if ([type isEqualToString:@"decimal"])
	{
		return [NSString stringWithFormat:@"[%@ floatValue]", name];
	}
	if ([type isEqualToString:@"float"])
	{
		return [NSString stringWithFormat:@"[%@ floatValue]", name];
	}
	if ([type isEqualToString:@"double"])
	{
		return [NSString stringWithFormat:@"[%@ doubleValue]", name];
	}
	
	if ([type isEqualToString:@"any"])
	{
		return [NSString stringWithFormat:@"[[[NSClassFromString(@\"%@\") alloc] initWithString:%@] autorelease]", type, name];
	}
	
	return [NSString stringWithFormat:@"[[[NSClassFromString(@\"%@\") alloc] initWithString:%@] autorelease]", type, name];
}


- (NSString *) cocoaObjectForObject:(NSString *)name
						   WithType:(NSString *) type
{
	type = [[type componentsSeparatedByString:@":"] lastObject];
	type = [schema_object convertedType:type];
	
	if ([type isEqualToString:@"boolean"])
	{
		return [NSString stringWithFormat:@"(%@Exists ? (%@ ? @\"true\" : @\"false\") : NULL)", name, name];
	}
	if ([type isEqualToString:@"short"])
	{
		return [NSString stringWithFormat:@"(%@Exists ? [[NSNumber numberWithShort:%@] stringValue] : NULL)", name, name];
	}
	if ([type isEqualToString:@"int"])
	{
		return [NSString stringWithFormat:@"(%@Exists ? [[NSNumber numberWithInt:%@] stringValue] : NULL)", name, name];
	}
	if ([type isEqualToString:@"byte"])
	{
		return [NSString stringWithFormat:@"(%@Exists ? [[NSNumber numberWithChar:%@] stringValue] : NULL)", name, name];
	}
	if ([type isEqualToString:@"long"])
	{
		return [NSString stringWithFormat:@"(%@Exists ? [[NSNumber numberWithLong:%@] stringValue] : NULL)", name, name];
	}
	if ([type isEqualToString:@"string"])
	{
		return name;
	}
	if ([type hasPrefix:@"string"])
	{
		// this is a length limited string...
		return [NSString stringWithFormat:@"([%@ length] > %@ ? [%@ substringToIndex:%@] : %@)", name, [type substringFromIndex:6], name, [type substringFromIndex:6], name];
	}
	if ([type isEqualToString:@"base64Binary"])
	{
		return [NSString stringWithFormat:@"[NSData encode:%@]", name];
	}
	if ([type isEqualToString:@"dateTime"])
	{
		return [NSString stringWithFormat:@"[self dateTimeStringFromSchema:%@]", name];
	}
	if ([type isEqualToString:@"date"])
	{
		return [NSString stringWithFormat:@"[self dateStringFromSchema:%@]", name];
	}
	if ([type isEqualToString:@"decimal"])
	{
		return [NSString stringWithFormat:@"(%@Exists ? [[NSNumber numberWithFloat:%@] stringValue] : NULL)", name, name];
	}
	if ([type isEqualToString:@"float"])
	{
		return [NSString stringWithFormat:@"(%@Exists ? [[NSNumber numberWithFloat:%@] stringValue] : NULL)", name, name];
	}
	if ([type isEqualToString:@"double"])
	{
		return [NSString stringWithFormat:@"(%@Exists ? [[NSNumber numberWithDouble:%@] stringValue] : NULL)", name, name];
	}
	
	if ([type isEqualToString:@"any"])
	{
		return [NSString stringWithFormat:@"[%@ description]", name];
	}
	
	return [NSString stringWithFormat:@"[%@ description]", name];
}

- (NSString *)cocoaConvertObject:(NSString *)name
				   ToNaturalType:(NSString *)type
{
	type = [[type componentsSeparatedByString:@":"] lastObject]; 
	type = [schema_object convertedType:type];
	
	if ([type isEqualToString:@"boolean"])
	{
		return [NSString stringWithFormat:@"-(void) set%@%@:(BOOL)v { %@Exists=YES; %@ = v; }", [[name capitalizedString] substringToIndex:1], [name substringFromIndex:1], name, name];
	}
	if ([type isEqualToString:@"short"])
	{
		return [NSString stringWithFormat:@"-(void) set%@%@:(short)v { %@Exists=YES; %@ = v; }", [[name capitalizedString] substringToIndex:1], [name substringFromIndex:1], name, name];
	}
	if ([type isEqualToString:@"int"])
	{
		return [NSString stringWithFormat:@"-(void) set%@%@:(int)v { %@Exists=YES; %@ = v; }", [[name capitalizedString] substringToIndex:1], [name substringFromIndex:1], name, name];
	}
	if ([type isEqualToString:@"byte"])
	{
		return [NSString stringWithFormat:@"-(void) set%@%@:(char)v { %@Exists=YES; %@ = v; }", [[name capitalizedString] substringToIndex:1], [name substringFromIndex:1], name, name];
	}
	if ([type isEqualToString:@"long"])
	{
		return [NSString stringWithFormat:@"-(void) set%@%@:(long)v { %@Exists=YES; %@ = v; }", [[name capitalizedString] substringToIndex:1], [name substringFromIndex:1], name, name];
	}
	if ([type isEqualToString:@"decimal"])
	{
		return [NSString stringWithFormat:@"-(void) set%@%@:(float)v { %@Exists=YES; %@ = v; }", [[name capitalizedString] substringToIndex:1], [name substringFromIndex:1], name, name];
	}
	if ([type isEqualToString:@"float"])
	{
		return [NSString stringWithFormat:@"-(void) set%@%@:(float)v { %@Exists=YES; %@ = v; }", [[name capitalizedString] substringToIndex:1], [name substringFromIndex:1], name, name];
	}
	if ([type isEqualToString:@"double"])
	{
		return [NSString stringWithFormat:@"-(void) set%@%@:(double)v { %@Exists=YES; %@ = v; }", [[name capitalizedString] substringToIndex:1], [name substringFromIndex:1], name, name];
	}
	
	return NULL;
}

- (NSString *)convertName:(NSString *)type
{
	if ([type isEqualToString:@"id"])
	{
		return @"_id";
	}
	if ([type isEqualToString:@"class"])
	{
		return @"_class";
	}
	if ([type isEqualToString:@"restrict"])
	{
		return @"_restrict";
	}
	
	return type;
}

- (NSString *)setterName:(NSString *)name
{
	name = [self convertName:name];
	
	if([name hasPrefix:@"_"]) {
		name = [NSString stringWithFormat:@"set%@:", name];
	}else{
		name = [NSString stringWithFormat:@"set%@:", [NSString stringWithFormat:@"%@%@", [[name capitalizedString] substringToIndex:1], [name substringFromIndex:1]]];
	}
	
	return name;
}

@end
