//
//  sequence.h
//  ocxb
//
//  Created by Rocco Bowling on 3/27/09.
//  Copyright 2009 Feline Entertainment. All rights reserved.
//

#import <Cocoa/Cocoa.h>


typedef struct
{
	BOOL isStartNode;
	NSTreeNode * node;
	int level;
}NSTreeTraversalResult;

@interface NSTree : NSObject
{

}

+ (void) releaseTree:(NSTreeNode *) node;

+ (void) traverseAsXml:(NSTreeNode *) node
		 usingSelector:(SEL) sel
			withTarget:(id)target
			withObject:(id)obj;

+ (void) SkipChildrenInTraversal;

@end
