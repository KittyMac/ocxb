//
//  element.h
//  ocxb
//
//  Created by Rocco Bowling on 3/27/09.
//  Copyright 2009 Feline Entertainment. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "schema_object.h"

@interface element : schema_object
{
	NSMutableString * header_includes;
	NSMutableString * header_prototypes;
	NSMutableString * header_declarations;
	NSMutableString * header_properties;
	NSMutableString * header_methods;
	
	NSMutableString * class_declarations;
	NSMutableString * class_properties;
	NSMutableString * class_methods;
	NSMutableString * class_superclass;
	
	NSMutableString * create_initializations;
	NSMutableString * delloc_releases;
	
	NSMutableArray * element_attributes;
	NSMutableArray * element_children;
	
	NSMutableString * foreign_namespace;
	
	BOOL custom_superclass;
}

@property(nonatomic, retain) NSMutableString * header_includes;
@property(nonatomic, retain) NSMutableString * header_prototypes;
@property(nonatomic, retain) NSMutableString * header_declarations;
@property(nonatomic, retain) NSMutableString * header_properties;
@property(nonatomic, retain) NSMutableString * header_methods;

@property(nonatomic, retain) NSMutableString * class_declarations;
@property(nonatomic, retain) NSMutableString * class_properties;
@property(nonatomic, retain) NSMutableString * class_methods;
@property(nonatomic, retain) NSMutableString * class_superclass;
@property(nonatomic) BOOL custom_superclass;

@property(nonatomic, retain) NSMutableString * foreign_namespace;

@property(nonatomic, retain) NSMutableString * create_initializations;
@property(nonatomic, retain) NSMutableString * delloc_releases;

@property(nonatomic, retain) NSMutableArray * element_attributes;
@property(nonatomic, retain) NSMutableArray * element_children;



@end
