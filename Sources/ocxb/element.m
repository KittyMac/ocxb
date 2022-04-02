//
//  element.m
//  ocxb
//
//  Created by Rocco Bowling on 3/27/09.
//  Copyright 2009 Feline Entertainment. All rights reserved.
//

#import "element.h"
#import "complexType.h"
#import "simpleType.h"
#import "restriction.h"

extern NSString * gCodeFileExtension;
extern NSMutableDictionary * config;

@implementation element

@synthesize custom_superclass;

@synthesize header_includes;
@synthesize header_prototypes;
@synthesize header_declarations;
@synthesize header_properties;
@synthesize header_methods;

@synthesize class_declarations;
@synthesize class_properties;
@synthesize class_methods;
@synthesize class_superclass;

@synthesize foreign_namespace;

@synthesize create_initializations;
@synthesize delloc_releases;

@synthesize element_attributes;
@synthesize element_children;

- (id) init
{
	self = [super init];
	
	if(self)
	{
		[self setClass_declarations:[NSMutableString string]];
		[self setClass_properties:[NSMutableString string]];
		[self setClass_methods:[NSMutableString string]];
		[self setClass_superclass:[NSMutableString string]];
		
		[self setForeign_namespace:[NSMutableString string]];
		
		[self setHeader_includes:[NSMutableString string]];
		[self setHeader_prototypes:[NSMutableString string]];
		[self setHeader_declarations:[NSMutableString string]];
		[self setHeader_properties:[NSMutableString string]];
		[self setHeader_methods:[NSMutableString string]];
		
		[self setCreate_initializations:[NSMutableString string]];
		[self setDelloc_releases:[NSMutableString string]];
		
		[self setElement_attributes:[NSMutableArray array]];
		[self setElement_children:[NSMutableArray array]];
	}
	
	return self;
}

- (void) pre_exportWithAncestor:(element *) ancestor_element
{
	NSString * reference_name = [[[self get:@"ref"] componentsSeparatedByString:@":"] lastObject];
	NSString * virgin_type = [[[self get:@"type"] componentsSeparatedByString:@":"] lastObject];
	NSString * name = [[[self get:@"name"] componentsSeparatedByString:@":"] lastObject];
	NSString * type = [self get:@"type"];
	NSString * maxOccurs = [self get:@"maxOccurs"];
	
	if(name == NULL)
	{
		name = [[[self get:@"id"] componentsSeparatedByString:@":"] lastObject];
	}
	
	if(maxOccurs == NULL)
	{
		maxOccurs = @"1";
	}
	
	if(name != NULL)
	{
		if([maxOccurs isEqualToString:@"1"] == NO)
		{
			[ancestor_element.element_children addObject:[NSDictionary dictionaryWithObjectsAndKeys:
														  name, @"name",
														  type, @"type",
														  @"simple_plural", @"inner_type",
														  NULL]];
		}
		else
		{
			[ancestor_element.element_children addObject:[NSDictionary dictionaryWithObjectsAndKeys:
														  name, @"name",
														  type, @"type",
														  @"simple", @"inner_type",
														  NULL]];
		}
	}
	
	if(reference_name != NULL)
	{
		if([maxOccurs isEqualToString:@"1"] == NO)
		{
			[ancestor_element.element_children addObject:[NSDictionary dictionaryWithObjectsAndKeys:
														  reference_name, @"name",
														  @"complex_plural", @"inner_type",
														  NULL]];
		}
		else
		{
			[ancestor_element.element_children addObject:[NSDictionary dictionaryWithObjectsAndKeys:
														  reference_name, @"name",
														  @"complex", @"inner_type",
														  NULL]];
		}
	}
	
	name = [self convertName:name];
	
	
	if([maxOccurs isEqualToString:@"1"] == NO)
	{
		NSString * vanilla_type = type;
		
		// Support multiple
		if(reference_name != NULL)
		{
			reference_name = [self convertName:reference_name];
			[ancestor_element.header_declarations appendFormat:@"\tNSMutableArray * %@s;\n", reference_name];
			[ancestor_element.header_properties appendFormat:@"@property(retain) NSMutableArray * %@s;\n", reference_name];
			[ancestor_element.class_properties appendFormat:@"@synthesize %@s;\n", reference_name];
			[ancestor_element.create_initializations appendFormat:@"\t\t%@s = [[NSMutableArray array] retain];\n", reference_name];
			[ancestor_element.delloc_releases appendFormat:@"\t[%@s release];\n", reference_name];
		}
		
		if(type != NULL && name != NULL)
		{
			[ancestor_element.header_declarations appendFormat:@"\tNSMutableArray * %@s;\n", name];
			[ancestor_element.header_properties appendFormat:@"@property(retain) NSMutableArray * %@s;\n", name];
			[ancestor_element.class_properties appendFormat:@"@synthesize %@s;\n", name];
			[ancestor_element.create_initializations appendFormat:@"\t\t%@s = [[NSMutableArray array] retain];\n", name];
			[ancestor_element.delloc_releases appendFormat:@"\t[%@s release];\n", name];
			
			[ancestor_element.header_methods appendFormat:@"- (void) append%@WithString:(NSString *)string;\n", 
			 [[name capitalizedString] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@":"]]];
			
			[ancestor_element.class_methods appendFormat:@"- (void) append%@WithString:(NSString *)string { [%@s addObject:%@]; }\n", 
			 [[name capitalizedString] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@":"]],
			 name,
			 [self cocoaConvertObject:@"string" ToTypeFromString:vanilla_type]];
		}
	}
	else
	{
		// Support single
		if(reference_name != NULL)
		{
			NSString * import_name;
			
			reference_name = [self convertName:reference_name];
			
			if(custom_superclass == NO)
			{
				import_name = [NSString stringWithFormat:@"%@_%@", [config objectForKey:@"prefix"], reference_name];
				[ancestor_element.header_includes appendFormat:@"#import \"%@.h\"\n", import_name];
			}
			else
			{
				import_name = class_superclass;
				[ancestor_element.header_includes appendFormat:@"@class %@;\n", import_name];
			}
			
			[ancestor_element.header_declarations appendFormat:@"\t%@ * %@;\n", import_name, reference_name];
			[ancestor_element.header_properties appendFormat:@"@property(retain) %@ * %@;\n", import_name, reference_name];
			[ancestor_element.class_properties appendFormat:@"@synthesize %@;\n", reference_name];
		}
		
		if(type != NULL && name != NULL)
		{
			NSString * vanilla_type = type;
			
			type = [self convertType:type];
			
			//[ancestor_element.header_prototypes appendFormat:@"#undef %@\n", name];
			[ancestor_element.header_declarations appendFormat:@"\t%@ %@;\n", type, name];
			if([schema_object enumerationsForType:virgin_type] != NULL)
			{
				NSArray * enum_values = [schema_object enumerationsForType:virgin_type];
				
				[ancestor_element.header_methods appendFormat:@"+ (NSArray *) %@ValidValues;\n", name];
				
				[ancestor_element.class_methods appendFormat:@"+ (NSArray *) %@ValidValues { return [NSMutableArray arrayWithObjects:", name];
				for(NSString * enum_value in enum_values)
				{
					[ancestor_element.class_methods appendFormat:@"@\"%@\",", enum_value];
				}
				[ancestor_element.class_methods appendFormat:@"NULL]; } \n"];
			}
			
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
					[ancestor_element.header_properties appendFormat:@"@property(nonatomic) %@ %@;\n", type, name];
					[ancestor_element.header_properties appendFormat:@"@property(nonatomic, readonly) BOOL %@Exists;\n", name];
					[ancestor_element.header_declarations appendFormat:@"BOOL %@Exists;\n", name];
					[ancestor_element.class_properties appendFormat:@"@synthesize %@;\n", name];
					[ancestor_element.class_properties appendFormat:@"@synthesize %@Exists;\n", name];
					[ancestor_element.class_properties appendFormat:@"%@;\n\n", natural_type];
				}
				else
				{
					[ancestor_element.header_properties appendFormat:@"@property %@ %@;\n", type, name];
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

- (void) pre_export
{
	element * ancestor_element = (element *)[self ancestorOfType:[element class]];
	
	// Support embedded elements
	NSString * reference_name = [self get:@"ref"];
	NSString * name = [self get:@"name"];
	NSString * type = [self get:@"type"];
	
	// Check if the reference name exists, and is it in a schema not our own...
	if(reference_name != NULL && [reference_name rangeOfString:@":"].length > 0)
	{
		NSString * reference_namespace = [[reference_name componentsSeparatedByString:@":"] objectAtIndex:0];
		NSDictionary * namespaceMap = [config objectForKey:@"namespaceMap"];
		NSDictionary * fullNamespaceMap = [config objectForKey:@"fullNamespaceMap"];
		
		if([[namespaceMap objectForKey:reference_namespace] isEqualToString:[config objectForKey:@"prefix"]] == NO)
		{
			foreign_namespace = [fullNamespaceMap objectForKey:reference_namespace];
			class_superclass = [NSMutableString stringWithFormat:@"%@_%@", [namespaceMap objectForKey:reference_namespace], [[reference_name componentsSeparatedByString:@":"] objectAtIndex:1]];
			custom_superclass = YES;
		}
	}
		
	if(name == NULL)
	{
		name = [self get:@"id"];
	}
	
	if(name != NULL && type == NULL && ancestor_element != NULL && [[node childNodes] objectAtIndex:0] != NULL)
	{
		NSTreeNode * child = [[node childNodes] objectAtIndex:0];
		
		if([[child representedObject] isMemberOfClass:[simpleType class]])
		{
			child = [[child childNodes] objectAtIndex:0];
			
			if([[child representedObject] isMemberOfClass:[restriction class]])
			{
				[self set:[[child representedObject] get:@"base"] key:@"type"];
				type = [self get:@"type"];
				
				NSTreeNode * p = node;
				while([p parentNode] != NULL)
				{
					p = [p parentNode];
				}
				
				[[p representedObject] remove:self];
			}
		}
	}
	
	if(ancestor_element != NULL && name != NULL && type == NULL && reference_name == NULL)
	{
		// We want to pre-process this element as if it were a external reference...
		[self pre_exportWithAncestor:NULL];
		
		if([self get:@"name"] != NULL)
		{
			[self set:[self get:@"name"] key:@"ref"];
		}
		else if([self get:@"id"] != NULL)
		{
			[self set:[self get:@"id"] key:@"ref"];
		}
	}
	
	
	if(ancestor_element != NULL)
	{
		[self pre_exportWithAncestor:ancestor_element];
	}
	else
	{
		ancestor_element = (element *)[self ancestorOfType:[complexType class]];
		
		if(ancestor_element != NULL)
		{
			[self pre_exportWithAncestor:ancestor_element];
		}
	}
	
	if(ancestor_element != NULL && name != NULL && type == NULL && reference_name == NULL)
	{
		[self remove:@"ref"];
	}
}

- (void) post_export
{
	element * ancestor_element = (element *)[self ancestorOfType:[element class]];
	
	// Support embedded elements
	NSString * reference_name = [self get:@"ref"];
	NSString * name = [self get:@"name"];
	NSString * type = [self get:@"type"];
	
	if(name == NULL)
	{
		name = [self get:@"id"];
	}
	
	if(ancestor_element != NULL && name != NULL && type == NULL && reference_name == NULL)
	{
		ancestor_element = NULL;
	}
	
	if(ancestor_element == NULL)
	{
		NSMutableString * scratch = [NSMutableString string];
		NSString * name = [self get:@"name"];
		
		if(name == NULL)
		{
			name = [self get:@"id"];
		}
		
		name = [self convertName:name];
		
		name = [NSString stringWithFormat:@"%@_%@", [config objectForKey:@"prefix"], name];
		
		// create the header file
		[scratch appendFormat:@"//\n// Autogenerate by ocxb on %@\n//\n\n", [[NSCalendarDate date] description]];
		
		if([config objectForKey:@"iphone"] == NULL)
		{
			[scratch appendFormat:@"\n#import <Cocoa/Cocoa.h>\n"];
		}
		else
		{
			[scratch appendFormat:@"\n#import <UIKit/UIKit.h>\n"];
		}
		
		if([class_superclass length] > 0)
		{
			[scratch appendFormat:@"#import \"%@.h\"\n", class_superclass];
		}
				
		[scratch appendFormat:@"\n%@\n", header_includes];
		[scratch appendFormat:@"\n%@\n", header_prototypes];
		
		if([class_superclass length] > 0)
		{
			[scratch appendFormat:@"@interface %@ : %@\n{\n\n", name, class_superclass];
		}
		else
		{
			[scratch appendFormat:@"@interface %@ : NSObject\n{\nid parent;\n", name];
		}
		[scratch appendFormat:@"%@", header_declarations];
		[scratch appendFormat:@"}\n\n"];
		[scratch appendFormat:@"%@", header_properties];
		if([class_superclass length] == 0)
		{
			[scratch appendFormat:@"@property (nonatomic, assign) id parent;\n"];
		}
		[scratch appendFormat:@"\n\n"];
		[scratch appendFormat:@"%@", header_methods];
		[scratch appendFormat:@"- (void) appendXML:(NSMutableString *)xml;\n"];
		[scratch appendFormat:@"- (void) appendXMLAttributesForSubclass:(NSMutableString *)xml;\n"];
		[scratch appendFormat:@"- (void) appendXMLElementsForSubclass:(NSMutableString *)xml;\n"];
		[scratch appendFormat:@"\n\n@end\n"];

		[scratch writeToFile:[NSString stringWithFormat:@"%@.h", name]
				  atomically:NO
					encoding:NSUTF8StringEncoding
					   error:NULL];
		
		
		// create the class file
		[scratch setString:@""];
		
		[scratch appendFormat:@"//\n// Autogenerate by ocxb on %@\n//\n\n", [[NSCalendarDate date] description]];
		
		if([config objectForKey:@"iphone"] == NULL)
		{
			[scratch appendFormat:@"\n#import <Cocoa/Cocoa.h>\n"];
		}
		else
		{
			[scratch appendFormat:@"\n#import <UIKit/UIKit.h>\n"];
		}
		
		[scratch appendFormat:@"\n#import \"%@.h\"\n\n\n", name];
		[scratch appendFormat:@"\n"
			@"@interface NSData (NSDataAdditions)\n"
			@"+ (NSString*) encode:(NSData*) rawBytes;\n"
			@"+ (NSString*) encode:(const uint8_t*) input length:(NSInteger) length;\n"
			@"+ (NSData*) decode:(const char*) string length:(NSInteger) inputLength;\n"
			@"+ (NSData*) decode:(NSString*) string;\n"
			@"\n"
			@"@end\n"
			@"\n"];
		[scratch appendFormat:@"@implementation %@\n\n", name];
		
		if([class_superclass length] == 0)
		{
			[scratch appendFormat:@"@synthesize parent;\n"];
		}
		
		[scratch appendFormat:@"%@", class_properties];
		[scratch appendFormat:@"\n\n"];
		
		if([create_initializations length] > 0)
		{
			[scratch appendFormat:@"- (id) init {\n\tself = [super init];\n\tif(self != NULL) {\n%@\t}\nreturn self;\n}\n\n", create_initializations];
		}
		if([delloc_releases length] > 0)
		{
			[scratch appendFormat:@"- (void) dealloc {\n%@\t[super dealloc];\n}\n", delloc_releases];
		}
		
		NSMutableString * code = [NSMutableString stringWithFormat:
				@"- (NSDate *) schemaDateTimeFromString:(NSString *)date_string\n"
				@"{ NSDateFormatter * date_format = [[[NSDateFormatter alloc] init] autorelease]; [date_format setDateFormat:@\"%@\"]; return [date_format dateFromString:date_string]; }\n\n"
				@"- (NSDate *) schemaDateFromString:(NSString *)date_string\n"
				@"{ NSDateFormatter * date_format = [[[NSDateFormatter alloc] init] autorelease]; [date_format setDateFormat:@\"%@\"]; return [date_format dateFromString:date_string]; }\n\n"
			  @"- (NSString *) dateTimeStringFromSchema:(NSDate *)_date\n"
			  @"{ NSDateFormatter * date_format = [[[NSDateFormatter alloc] init] autorelease]; [date_format setDateFormat:@\"%@\"]; return [date_format stringFromDate:_date]; }\n\n"
			  @"- (NSString *) dateStringFromSchema:(NSDate *)_date\n"
			  @"{ NSDateFormatter * date_format = [[[NSDateFormatter alloc] init] autorelease]; [date_format setDateFormat:@\"%@\"]; return [date_format stringFromDate:_date]; }\n\n"
				@"\n", @"yyyy-MM-ddTHH:mm:ss", @"yyyy-MM-dd", @"yyyy-MM-ddTHH:mm:ss", @"yyyy-MM-dd"];
		
		
				
		[code appendString:@"- (void) appendXMLAttributesForSubclass:(NSMutableString *)xml\n{\n"];
		if(custom_superclass)
		{
			[code appendString:@"[super appendXMLAttributesForSubclass:xml];\n"];
		}
		for(NSDictionary * info in element_attributes)
		{
			NSString * type = [info objectForKey:@"type"];
			NSString * key = [info objectForKey:@"name"];
			
			[code appendFormat:@"if(%@) { [xml appendFormat:@\" %@='%%@'\", [self translateToXMLSafeString:%@]]; }\n", 
			 [self cocoaObjectForObject:[self convertName:key] WithType:type],
			 key, 
			 [self cocoaObjectForObject:[self convertName:key] WithType:type]];
		}
		[code appendString:@"}\n"];
		
		[code appendString:@"- (void) appendXMLElementsForSubclass:(NSMutableString *)xml\n{\n"];
		if(custom_superclass)
		{
			[code appendString:@"[super appendXMLElementsForSubclass:xml];\n"];
		}
		for(NSDictionary * info in element_children)
		{
			NSString * inner_type = [info objectForKey:@"inner_type"];
			NSString * type = [info objectForKey:@"type"];
			NSString * key = [info objectForKey:@"name"];
			
			if([inner_type isEqualToString:@"simple"])
			{
				if([type isEqualToString:@"base64Binary"])
				{
					[code appendFormat:@"if(%@ != NULL && [%@ length] > 0) {[xml appendFormat:@\"\\t<%@>%%@</%@>\", [self translateToXMLSafeString:%@]];}\n",
					 [self convertName:key],
					 [self convertName:key],
					 key,
					 key,
					 [self cocoaObjectForObject:[self convertName:key] WithType:type]];
				}
				else
				{
					[code appendFormat:@"if(%@ && [%@ isEqualToString:@\"(null)\"] == NO) {[xml appendFormat:@\"\\t<%@>%%@</%@>\", [self translateToXMLSafeString:%@]];}\n",
					 [self cocoaObjectForObject:[self convertName:key] WithType:type],
					 [self cocoaObjectForObject:[self convertName:key] WithType:type],
					 key,
					 key,
					 [self cocoaObjectForObject:[self convertName:key] WithType:type]];
				}
			}
			if([inner_type isEqualToString:@"complex"])
			{
				[code appendFormat:@"[xml appendFormat:@\"\\t\"]; [%@ appendXML:xml];\n", [self convertName:key]];
			}
			if([inner_type isEqualToString:@"simple_plural"])
			{
				if([type isEqualToString:@"base64Binary"])
				{
					[code appendFormat:@"for(id x in %@s) { [xml appendFormat:@\"\\t<%@>%%@</%@>\", [NSData encode:x]]; } \n", [self convertName:key], [self convertName:key], [self convertName:key]];
				}
				else if([type isEqualToString:@"any"])
				{
					[code appendFormat:@"for(id x in %@s) { [x appendXML:xml]; } \n", [self convertName:key]];
				}
				else
				{
					[code appendFormat:@"for(id x in %@s) { [xml appendFormat:@\"\\t<%@>%%@</%@>\", [self translateToXMLSafeString:x]]; } \n", [self convertName:key], [self convertName:key], [self convertName:key]];
				}
			}
			if([inner_type isEqualToString:@"complex_plural"])
			{
				[code appendFormat:@"for(id x in %@s) { [x appendXML:xml]; } \n", [self convertName:key]];
			}
		}
		
		[code appendFormat:@"}\n"];
		
		
		[code appendString:@"- (void) appendXML:(NSMutableString *)xml\n{\n"];
		[code appendFormat:@"[xml appendFormat:@\"<%@ xmlns='%@'\"];\n", [self get:@"name"], [config objectForKey:@"fullNamespace"]];
		[code appendString:@"[self appendXMLAttributesForSubclass:xml];\n"];
		[code appendFormat:@"[xml appendFormat:@\">\"];\n"];
		[code appendString:@"[self appendXMLElementsForSubclass:xml];\n"];
		[code appendFormat:@"[xml appendFormat:@\"</%@>\"];\n", [self get:@"name"]];
		[code appendFormat:@"}\n"];
		
		
		[scratch appendFormat:@"- (NSString *) translateToXMLSafeString:(NSString *)__value\n"
		@"{\n"
		 @"NSMutableString * string = [NSMutableString stringWithString:__value];\n"
		 @"[string replaceOccurrencesOfString:@\"&\" withString:@\"&amp;\" options:NSLiteralSearch range:NSMakeRange(0, [string length])];\n"
		 @"[string replaceOccurrencesOfString:@\"<\" withString:@\"&lt;\" options:NSLiteralSearch range:NSMakeRange(0, [string length])];\n"
		 @"[string replaceOccurrencesOfString:@\">\" withString:@\"&gt;\" options:NSLiteralSearch range:NSMakeRange(0, [string length])];\n"
		 @"[string replaceOccurrencesOfString:@\"\\\"\" withString:@\"&quot;\" options:NSLiteralSearch range:NSMakeRange(0, [string length])];\n"
		 @"[string replaceOccurrencesOfString:@\"'\" withString:@\"&apos;\" options:NSLiteralSearch range:NSMakeRange(0, [string length])];\n"
		 @"return string;\n}\n\n"];
		
		[scratch appendFormat:@"%@", code];
		
		[scratch appendFormat:@"%@", class_methods];
		[scratch appendFormat:@"\n\n\n@end\n"];
		
		[scratch writeToFile:[NSString stringWithFormat:@"%@.%@", name, gCodeFileExtension]
				  atomically:NO
					encoding:NSUTF8StringEncoding
					   error:NULL];
	}
}

@end
