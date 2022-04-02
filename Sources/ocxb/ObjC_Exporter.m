//
//  ObjC_Exporter.m
//  ocxb
//
//  Created by Rocco Bowling on 3/27/09.
//  Copyright 2009 Feline Entertainment. All rights reserved.
//

#import "ObjC_Exporter.h"
#import "NSTree.h"
#import "schema_object.h"

@implementation ObjC_Exporter

@synthesize schema_root;

- (void) ExportResult:(NSTreeTraversalResult *) result
		 withObject:(id) args
{
	schema_object * object = [result->node representedObject];
	
	if(result->isStartNode)
	{
		[object pre_export];
	}
	else
	{
		[object post_export];
	}
}

- (BOOL) ExportToDirectory:(NSString *) destination
{
	[[NSFileManager defaultManager] createDirectoryAtPath:destination
							  withIntermediateDirectories:YES
											   attributes:NULL
													error:NULL];
	
	[[NSFileManager defaultManager] changeCurrentDirectoryPath:destination];
	
	[NSTree traverseAsXml:schema_root
			usingSelector:@selector(ExportResult:withObject:)
			   withTarget:self
			   withObject:NULL];
	
	return YES;
}

@end
