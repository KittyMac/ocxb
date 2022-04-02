//
//  schema.m
//  ocxb
//
//  Created by Rocco Bowling on 3/27/09.
//  Copyright 2009 Feline Entertainment. All rights reserved.
//

#import "schema.h"
#import "element.h"

extern NSString * gCodeFileExtension;
extern NSMutableDictionary * config;

@implementation schema

@synthesize all_import_inits;
@synthesize all_import_imports;

- (id) init
{
	self = [super init];
	
	if(self)
	{
		all_nodes_by_class = [NSMutableDictionary dictionary];
		all_elements_referenced = [NSMutableDictionary dictionary];
		all_import_inits = [NSMutableString string];
		all_import_imports = [NSMutableString string];
	}
	
	return self;
}

- (void) remove:(schema_object *) object
{
	if([object get:@"name"])
	{
		NSString * reference_name = [[[object get:@"name"] componentsSeparatedByString:@":"] lastObject];
		
		[all_elements_referenced removeObjectForKey:reference_name];
	}
}

- (void) record:(schema_object *) object
{
	if([object get:@"name"])
	{
		NSString * reference_name = [[[object get:@"name"] componentsSeparatedByString:@":"] lastObject];
		
		[all_nodes_by_class setObject:object forKey:reference_name];
		
		if(	[object isKindOfClass:[element class]] &&
			[object get:@"type"] == NULL)
		{
			[all_elements_referenced setObject:object forKey:reference_name];
		}
	}
}

- (schema_object *) nodeWithName:(NSString *)reference_name
{
	return [all_nodes_by_class objectForKey:reference_name];
}

#pragma mark -

- (void) pre_export
{
	
}

- (void) post_export
{
	NSMutableString * scratch = [NSMutableString string];
	NSString * targetNamespace = [self get:@"targetNamespace"];
	NSString * name = [[self get:@"targetNamespace"] lastPathComponent];
	NSString * code;
	NSMutableString * init_all_objects = [NSMutableString string];
	
	name = [NSString stringWithFormat:@"%@_XMLLoader", [config objectForKey:@"prefix"]];
	
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
	
	for(NSString * reference in all_elements_referenced)
	{
        NSString * modreference = [NSString stringWithFormat:@"%@_%@", [config objectForKey:@"prefix"], reference];
		[scratch appendFormat:@"#import \"%@.h\"\n", modreference];
		
		[init_all_objects appendFormat:@"[[[%@ alloc] init] release];\n", modreference];
	}
	
	
	code = [NSString stringWithFormat:
			@"\n\n@interface %@ : NSObject\n"
			@"{"
			@"NSMutableArray * element_stack;"
			@"NSString * last_element_name;"
			@"NSMutableString * scratch_string;"
			@"id parent;"
			@"}"
			@"@property (nonatomic, retain) NSMutableArray * element_stack;"
			@"+ (id) readFromFile:(NSString *)path;\n"
			@"+ (id) readFromData:(NSData *)data;\n"
			@"+ (id) readFromData:(NSData *)data withParent:(id)parent;\n"
			@"+ (id) readFromString:(NSString *)xml_string;\n"
			@"+ (void) write:(id)object toFile:(NSString *)path;\n"
			@"+ (NSData *) writeToData:(id)object;\n"
			@"+ (NSString *) writeToString:(id)object;\n"
			@"- (id) initWithParent:(id)p;\n"
			@"@end\n",
			name];
	
		
	[scratch appendFormat:@"%@", code];
	
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
	
	
	code = [NSString stringWithFormat:
			@"%@\n\n\n"
			@"@implementation NSData (NSDataAdditions%@)\n"
			@"\n"
			@"static char encodingTable[] = \"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/\";\n"
			@"static char decodingTable[128];\n"
			@"\n"
			@"+ (void) initialize {\n"
			@"	if (self == [NSData class]) {\n"
			@"      NSInteger i;"
			@"		memset(decodingTable, 0, sizeof(decodingTable));\n"
			@"		for (i = 0; i < sizeof(encodingTable); i++) {\n"
			@"			decodingTable[encodingTable[i]] = i;\n"
			@"		}\n"
			@"	}\n"
			@"}\n"
			@"\n"
			@"\n"
			@"+ (NSString*) encode:(const uint8_t*) input length:(NSInteger) length {\n"
			@"    NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];\n"
			@"    uint8_t* output = (uint8_t*)data.mutableBytes;\n"
			@"	  NSInteger i, j;\n"
			@"    for (i = 0; i < length; i += 3) {\n"
			@"        NSInteger value = 0;\n"
			@"        for (j = i; j < (i + 3); j++) {\n"
			@"            value <<= 8;\n"
			@"			\n"
			@"            if (j < length) {\n"
			@"                value |= (0xFF & input[j]);\n"
			@"            }\n"
			@"        }\n"
			@"		\n"
			@"        NSInteger index = (i / 3) * 4;\n"
			@"        output[index + 0] =                    encodingTable[(value >> 18) & 0x3F];\n"
			@"        output[index + 1] =                    encodingTable[(value >> 12) & 0x3F];\n"
			@"        output[index + 2] = (i + 1) < length ? encodingTable[(value >> 6)  & 0x3F] : '=';\n"
			@"        output[index + 3] = (i + 2) < length ? encodingTable[(value >> 0)  & 0x3F] : '=';\n"
			@"    }\n"
			@"	\n"
			@"    return [[[NSString alloc] initWithData:data\n"
			@"                                  encoding:NSASCIIStringEncoding] autorelease];\n"
			@"}\n"
			@"\n"
			@"\n"
			@"+ (NSString*) encode:(NSData*) rawBytes {\n"
			@"    return [self encode:(const uint8_t*) rawBytes.bytes length:rawBytes.length];\n"
			@"}\n"
			@"\n"
			@"\n"
			@"+ (NSData*) decode:(const char*) string length:(NSInteger) inputLength {\n"
			@"	if ((string == NULL) || (inputLength %% 4 != 0)) {\n"
			@"		return nil;\n"
			@"	}\n"
			@"	\n"
			@"	while (inputLength > 0 && string[inputLength - 1] == '=') {\n"
			@"		inputLength--;\n"
			@"	}\n"
			@"	\n"
			@"	NSInteger outputLength = inputLength * 3 / 4;\n"
			@"	NSMutableData* data = [NSMutableData dataWithLength:outputLength];\n"
			@"	uint8_t* output = (uint8_t*)data.mutableBytes;\n"
			@"	\n"
			@"	NSInteger inputPoint = 0;\n"
			@"	NSInteger outputPoint = 0;\n"
			@"	while (inputPoint < inputLength) {\n"
			@"		char i0 = string[inputPoint++];\n"
			@"		char i1 = string[inputPoint++];\n"
			@"		char i2 = inputPoint < inputLength ? string[inputPoint++] : 'A'; /* 'A' will decode to \0 */\n"
			@"		char i3 = inputPoint < inputLength ? string[inputPoint++] : 'A';\n"
			@"		\n"
			@"		output[outputPoint++] = (decodingTable[i0] << 2) | (decodingTable[i1] >> 4);\n"
			@"		if (outputPoint < outputLength) {\n"
			@"			output[outputPoint++] = ((decodingTable[i1] & 0xf) << 4) | (decodingTable[i2] >> 2);\n"
			@"		}\n"
			@"		if (outputPoint < outputLength) {\n"
			@"			output[outputPoint++] = ((decodingTable[i2] & 0x3) << 6) | decodingTable[i3];\n"
			@"		}\n"
			@"	}\n"
			@"	\n"
			@"	return data;\n"
			@"}\n"
			@"\n"
			@"\n"
			@"+ (NSData*) decode:(NSString*) string {\n"
			@"	return [self decode:[string UTF8String] length:string.length];\n"
			@"}\n"
			@"\n"
			@"\n"
			@"@end\n"
			@"\n"
			@"@implementation %@\n"
			@"\n"
			@"@synthesize element_stack;\n"
			@"\n"
			@"+(void) initialize"
			@"{\n"
			@"  %@\n%@\n"
			@"}\n"
			@"+ (NSString *)convertName:(NSString *)name {\n"
			@"	if ([name isEqualToString:@\"id\"]) {\n"
			@"		return @\"_id\";\n"
			@"	}\n"
			@"	if ([name isEqualToString:@\"class\"]) {\n"
			@"		return @\"_class\";\n"
			@"	}\n"
			@"	if ([name isEqualToString:@\"restrict\"]) {\n"
			@"		return @\"_restrict\";\n"
			@"	}\n"
			@"	\n"
			@"	return name;\n"
			@"}\n"
			@"\n"
			@"+ (NSString *)setterName:(NSString *)name {\n"
			@"	name = [self convertName:name];\n"
			@"	\n"
			@"	if([name hasPrefix:@\"_\"]) {\n"
			@"		name = [NSString stringWithFormat:@\"set%%@:\", name];\n"
			@"	}else{\n"
			@"		name = [NSString stringWithFormat:@\"set%%@:\", [NSString stringWithFormat:@\"%%@%%@\", [[name capitalizedString] substringToIndex:1], [name substringFromIndex:1]]];\n"
			@"	}\n"
			@"	\n"
			@"	return name;\n"
			@"}\n"
			@"\n"
			@"+ (NSString *)setterNameWithString:(NSString *)name {\n"
			@"	name = [self convertName:name];\n"
			@"	\n"
			@"	if([name hasPrefix:@\"_\"]) {\n"
			@"		name = [NSString stringWithFormat:@\"set%%@WithString:\", name];\n"
			@"	}else{\n"
			@"		name = [NSString stringWithFormat:@\"set%%@WithString:\", [NSString stringWithFormat:@\"%%@%%@\", [[name capitalizedString] substringToIndex:1], [name substringFromIndex:1]]];\n"
			@"	}\n"
			@"	\n"
			@"	return name;\n"
			@"}\n"
			@"\n"
			@"+ (NSString *)getterName:(NSString *)name {\n"
			@"	name = [self convertName:name];\n"
			@"	name = [NSString stringWithFormat:@\"%%@\", name];	\n"
			@"	return name;\n"
			@"}\n"
			@"\n"
			@"+ (NSString *)getterNamePlural:(NSString *)name {\n"
			@"	name = [self convertName:name];\n"
			@"	name = [NSString stringWithFormat:@\"%%@s\", name];	\n"
			@"	return name;\n"
			@"}\n"
			@"\n"
			@"+ (id) readFromData:(NSData *)data withParent:(id)p {\n"
			@"	%@ * loader = [[[%@ alloc] initWithParent:p] autorelease];\n"
			@"	NSXMLParser * parser = [[NSXMLParser alloc] initWithData:data];\n"
			@"	[parser setShouldProcessNamespaces:YES];\n"
			@"	[parser setDelegate:loader];\n"
			@"	if([parser parse] == NO){NSLog(@\"%%@\", [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]);}\n"
			@"	[parser release];\n"
			@"	\n"
			@"	if([loader.element_stack count] > 0)\n"
			@"	{\n"
			@"		return [loader.element_stack objectAtIndex:0];\n"
			@"	}\n"
			@"	\n"
			@"	return NULL;\n"
			@"}\n"
			@"\n"
			@"+ (id) readFromData:(NSData *)data {\n"
			@"	return [%@ readFromData:data withParent:NULL];\n"
			@"}\n"
			@"+ (id) readFromFile:(NSString *)path {\n"
			@"	return [%@ readFromData:[NSData dataWithContentsOfFile:path options:0 error:NULL]];\n"
			@"}\n"
			@"\n"
			@"+ (id) readFromString:(NSString *)xml_string {\n"
			@"	return [%@ readFromData:[xml_string dataUsingEncoding:NSUTF8StringEncoding]];\n"
			@"}\n"
			@"\n"
			@"\n"
			@"+ (NSString *) writeToString:(id)object\n"
			@"{\n"
			@"	NSMutableString * scratch = [NSMutableString string];\n"
			@"	\n"
			@"	[scratch appendString:@\"<?xml version=\\\"1.0\\\" encoding=\\\"UTF-8\\\"?>\"];\n"
			@"	\n"
			@"	if([object respondsToSelector:@selector(appendXML:)])\n"
			@"	{\n"
			@"		[object performSelector:@selector(appendXML:) withObject:scratch];\n"
			@"	}\n"
			//@"	int i = [scratch rangeOfString:@\">\" options:NSLiteralSearch range:NSMakeRange(40, [scratch length]-40)].location;\n"
			//@"	[scratch insertString:[NSString stringWithFormat:@\" xmlns='%%@'\", targetNamespace] atIndex:i];\n"
			@"	\n"
			@"	return scratch;\n"
			@"}\n"
			@"\n"
			@"+ (void) write:(id)object toFile:(NSString *)path\n"
			@"{\n"
			@"	[[self writeToString:object] writeToFile:path atomically:NO encoding:NSUTF8StringEncoding error:NULL];\n"
			@"}\n"
			@"\n"
			@"+ (NSData *) writeToData:(id)object\n"
			@"{\n"
			@"	return [[self writeToString:object] dataUsingEncoding:NSUTF8StringEncoding];\n"
			@"}\n"
			@"\n"
			@"#pragma mark -\n"
			@"\n"
			@""
			@"- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {NSLog(@\"%%@\", [NSString stringWithFormat:@\"Error %%i, Description: %%@, Line: %%i, Column: %%i\", [parseError code], [parser parserError], [parser lineNumber],[parser columnNumber]]);}"
			@"- (void)  parser:(NSXMLParser *)parser\n"
			@" didStartElement:(NSString *)elementName  \n"
			@"	namespaceURI:(NSString *)namespaceURI  \n"
			@"   qualifiedName:(NSString *)qName  \n"
			@"	  attributes:(NSDictionary *)attributeDict  \n"
			@"{\n"
			@"  elementName = [[elementName componentsSeparatedByString:@\":\"] lastObject];\n"
			@"	NSString * prefix = [namespaceURI lastPathComponent];//@\"%@\";\n"
			@"	NSString * class_name = [%@ convertName:elementName];\n"
			@"	Class c = NSClassFromString([NSString stringWithFormat:@\"%%@_%%@\", prefix, class_name]);\n"
			@"	last_element_name = elementName;\n\n"
			@"	\n"
			@"	if(c) {\n"
			@"		id object = [[[c alloc] init] autorelease];\n"
			@"		[object performSelector:@selector(setParent:) withObject:([element_stack lastObject] ? [element_stack lastObject] : parent)];\n"
			@"		\n"
			@"		for(NSString * attrib_name in [attributeDict allKeys]) {\n"
			@"			SEL method = NSSelectorFromString([%@ setterNameWithString:attrib_name]);\n"
			@"			\n"
			@"			if([object respondsToSelector:method]) {\n"
			@"				[object performSelector:method withObject:[attributeDict objectForKey:attrib_name]];\n"
			@"			}else{\n"
			@"				//NSLog(@\"Unable to load attribute %%@ for object %%@\", [%@ convertName:attrib_name], [object description]);\n"
			@"			}\n"
			@"		}\n"
			@"		//NSLog(@\"element = %%@\", [object description]);\n"
			@"		if([element_stack lastObject] != NULL) {\n"
			@"			SEL method = NSSelectorFromString([%@ getterNamePlural:elementName]);\n"
			@"			if([[element_stack lastObject] respondsToSelector:method]) {\n"
			@"				id ret_val = [[element_stack lastObject] performSelector:method];\n"
			@"				if([ret_val isKindOfClass:[NSMutableArray class]])\n"
			@"				{\n"
			@"					method = NSSelectorFromString([NSString stringWithFormat:@\"append%%@WithString:\", [elementName capitalizedString]]);"
			@"					if([[element_stack lastObject] respondsToSelector:method]) {\n"
			@"						[[element_stack lastObject] performSelector:method withObject:object];\n"
			@"					} else {\n"
			@"						NSMutableArray * array = ret_val;\n"
			@"						[array addObject:object];\n"
			@"					}\n"
			@"				}\n"
			@"			}else{\n"
			@"				method = NSSelectorFromString([%@ setterName:elementName]);\n"
			@"				if([[element_stack lastObject] respondsToSelector:method]) { \n"
			@"					[[element_stack lastObject] performSelector:method withObject:object];\n"
			@"				}else{\n"
			@"					if([[element_stack lastObject] respondsToSelector:@selector(setAny:)]) {\n"
			@"						[[element_stack lastObject] performSelector:@selector(setAny:) withObject:object];\n"
			@"					}\n"
			@"					if([[element_stack lastObject] respondsToSelector:@selector(setAnys:)]) {\n"
			@"						[[[element_stack lastObject] performSelector:@selector(anys)] addObject:object];\n"
			@"					}\n"
			@"					//NSLog(@\"Unable to load single data element %%@ for object %%@\", [%@ convertName:elementName], [[element_stack lastObject] description]);\n"
			@"				}\n"
			@"			}\n"
			@"		}\n"
			@"		\n"
			@"		[element_stack addObject:object];\n"
			@"	}[scratch_string setString:@\"\"];\n"
			@"}\n"
			@"\n"
			@"- (void)parser:(NSXMLParser *)parser foundCharacters:(NSMutableString *)string  \n"
			@"{\n"
			@"	if(scratch_string == NULL) { scratch_string = [[NSMutableString string] retain]; }\n"
			@"	[scratch_string appendString:string];\n"
			@"}  \n"
			@"\n"
			@"- (void) parser:(NSXMLParser *)parser  \n"
			@"  didEndElement:(NSString *)elementName  \n"
			@"   namespaceURI:(NSString *)namespaceURI  \n"
			@"  qualifiedName:(NSString *)qName  \n"
			@"{\n"
			@"  elementName = [[elementName componentsSeparatedByString:@\":\"] lastObject];\n"
			@"  NSString * string = [scratch_string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];"
			@"	if([string length] > 0){\n"
			@"		SEL method = NSSelectorFromString([%@ getterNamePlural:last_element_name]);\n"
			@"		if([[element_stack lastObject] respondsToSelector:method]) {\n"
			@"			id ret_val = [[element_stack lastObject] performSelector:method];\n"
			@"			if([ret_val isKindOfClass:[NSMutableArray class]])\n"
			@"			{\n"
			@"					method = NSSelectorFromString([NSString stringWithFormat:@\"append%%@WithString:\", [elementName capitalizedString]]);"
			@"					if([[element_stack lastObject] respondsToSelector:method]) { \n"
			@"						[[element_stack lastObject] performSelector:method withObject:[scratch_string copy]];\n"
			@"					} else {\n"
			@"						NSMutableArray * array = ret_val;\n"
			@"						[array addObject:[scratch_string copy]];\n"
			@"					}\n"
			@"			}\n"
			@"		}else{\n"
			@"			method = NSSelectorFromString([%@ setterNameWithString:last_element_name]);\n"
			@"			if([[element_stack lastObject] respondsToSelector:method]) {\n"
			@"				[[element_stack lastObject] performSelector:method withObject:[scratch_string copy]];\n"
			@"			}else{\n"
			@"				//NSLog(@\"Unable to load single child element %%@ for object %%@\", [%@ convertName:last_element_name], [[element_stack lastObject] description]);\n"
			@"			}\n"
			@"		}\n"
			@"	}\n[scratch_string setString:@\"\"];\n"
			@"	NSString * prefix = [namespaceURI lastPathComponent];//@\"%@\";\n"
			@"	NSString * class_name = [%@ convertName:elementName];\n"
			@"  Class c = NSClassFromString([NSString stringWithFormat:@\"%%@_%%@\", prefix, class_name]);\n"
			@"	if([element_stack count] > 1 && c != NULL) { [element_stack removeLastObject]; }\n"
			@"}\n"
			@"\n"
			@"- (id) initWithParent:(id)p\n"
			@"{\n"
			@"	self = [super init];\n"
			@"	\n"
			@"	if(self)\n"
			@"	{\n"
			@"		parent = p;  element_stack = [[NSMutableArray array] retain];\n"
			@"	}\n"
			@"	\n"
			@"	return self;\n"
			@"}\n"
			@"- (void) dealloc\n"
			@"{\n"
			@"	[element_stack release];\n"
			@"	[scratch_string release];\n"
			@"	[super dealloc];\n"
			@"}\n"
			@"\n"
			@"@end\n"
			@"\n"
			@"\n"
			@"\n"
			@"\n"
			@"\n"
			@"\n",
			all_import_imports,
			name,
			name,
			init_all_objects,
			all_import_inits,
			name,
			name,
			name,
			name,
			name,
			[config objectForKey:@"prefix"],
			name,
			name,
			name,
			name,
			name,
			name,
			name,
			name,
			name,
			[config objectForKey:@"prefix"],
			name,
			NULL];
	
	[scratch appendFormat:@"%@", code];
	
	[scratch writeToFile:[NSString stringWithFormat:@"%@.%@", name, gCodeFileExtension]
			  atomically:NO
				encoding:NSUTF8StringEncoding
				   error:NULL];
}

@end
