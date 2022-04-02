//
//  schema_object.h
//  ocxb
//
//  Created by Rocco Bowling on 3/27/09.
//  Copyright 2009 Feline Entertainment. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface schema_object : NSObject
{
	NSTreeNode * node;
	NSString * contents;
	NSMutableDictionary * attributes;
}

@property(nonatomic, retain) NSTreeNode * node;
@property(nonatomic, retain) NSString * contents;
@property(nonatomic, retain) NSMutableDictionary * attributes;


- (void)set:(id)obj key:(id)key;
- (id) get:(id)key;
- (void) remove:(id)key;

- (void) pre_export;
- (void) post_export;

- (schema_object *) ancestorOfType:(Class)class;

- (schema_object *) schemaObjectOfClass:(Class)class
								WithName:(NSString *)name;

- (NSString *)convertType:(NSString *)type;
- (NSString *)cocoaConvertObject:(NSString *)name
				ToTypeFromString:(NSString *)type;
- (NSString *) cocoaObjectForObject:(NSString *)name
						   WithType:(NSString *) type;
- (NSString *)cocoaConvertObject:(NSString *)name
				   ToNaturalType:(NSString *)type;
- (NSString *)convertName:(NSString *)type;

- (NSString *)setterName:(NSString *)name;


+ (void) markConversionFromType:(NSString *) from_type
						 ToType:(NSString *) to_type;
+ (NSString *) convertedType:(NSString *)type;


+ (void) addEnumeration:(NSString *) value
				ForType:(NSString *) type;
+ (NSArray *) enumerationsForType:(NSString *)type;

@end
