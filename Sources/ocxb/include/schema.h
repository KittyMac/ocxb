//
//  schema.h
//  ocxb
//
//  Created by Rocco Bowling on 3/27/09.
//  Copyright 2009 Feline Entertainment. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "schema_object.h"

@interface schema : schema_object
{
	NSMutableDictionary * all_nodes_by_class;
	NSMutableDictionary * all_elements_referenced;
	
	NSMutableString * all_import_inits;
	NSMutableString * all_import_imports;
}

@property (readonly) NSMutableString * all_import_inits;
@property (readonly) NSMutableString * all_import_imports;

- (void) record:(schema_object *) object;
- (schema_object *) nodeWithName:(NSString *)reference_name;

@end
