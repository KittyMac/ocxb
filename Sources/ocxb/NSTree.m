//
//  sequence.h
//  ocxb
//
//  Created by Rocco Bowling on 3/27/09.
//  Copyright 2009 Feline Entertainment. All rights reserved.
//

#import "NSTree.h"

static BOOL SkipChildrenInTraversal = NO;

void traverseAsXml(NSTreeNode * node,
				   SEL sel,
				   id target,
				   id obj,
				   NSTreeTraversalResult * result);



@implementation NSTree

+ (void) releaseTree:(NSTreeNode *) node
{
	NSArray * children = [node childNodes];
	NSEnumerator * enumerator = [children objectEnumerator];
	NSTreeNode * child_node;
	
	// Release all of my children
	while(child_node = [enumerator nextObject])
	{
		[NSTree releaseTree:child_node];
	}
	
	[[node mutableChildNodes] removeAllObjects];
}


void traverseAsXml(NSTreeNode * node,
				   SEL sel,
				   id target,
				   id obj,
				   NSTreeTraversalResult * result)
{
	// Call the selector with at that start node
	result->node = node;
	result->isStartNode = YES;
	[target performSelector:sel withObject:(__bridge id)result withObject:obj];
	
	if(SkipChildrenInTraversal == NO)
	{
		NSArray * children = [node childNodes];
		int i = 0, c = [children count];
		
		// Process all of my children
		result->level++;
		
		for(i = 0; i < c; i++)
		{
			traverseAsXml([children objectAtIndex:i],
						  sel,
						  target,
						  obj,
						  result);
		}
		result->level--;
	}
	SkipChildrenInTraversal = NO;
	
	// Call the selector with at that start node
	result->node = node;
	result->isStartNode = NO;
	[target performSelector:sel withObject:(__bridge id)result withObject:obj];
}

+ (void) traverseAsXml:(NSTreeNode *) node
		 usingSelector:(SEL) sel
			withTarget:(id)target
			withObject:(id)obj
{
	NSTreeTraversalResult result = {0,0,0};
	
	traverseAsXml(node,
				  sel,
				  target,
				  obj,
				  &result);
}

+ (void) SkipChildrenInTraversal
{
	SkipChildrenInTraversal = YES;
}

@end
