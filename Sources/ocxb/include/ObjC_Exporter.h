//
//  ObjC_Exporter.h
//  ocxb
//
//  Created by Rocco Bowling on 3/27/09.
//  Copyright 2009 Feline Entertainment. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ObjC_Exporter : NSObject
{
	NSTreeNode * schema_root;
}

@property(nonatomic, retain) NSTreeNode * schema_root;

- (BOOL) ExportToDirectory:(NSString *) destination;

@end
