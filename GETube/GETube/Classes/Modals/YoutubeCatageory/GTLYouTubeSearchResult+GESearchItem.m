//
//  GTLYouTubeSearchResult+GESearchItem.m
//  GETube
//
//  Created by Deepak on 22/07/16.
//  Copyright © 2016 Deepak. All rights reserved.
//

#import "GTLYouTubeSearchResult+GESearchItem.h"

@implementation GTLYouTubeSearchResult (GESearchItem)

- (NSString*)GEId
{
    return self.identifier.videoId;
}

- (NSString*)GETitle
{
    return self.snippet.title;
}

- (NSString*)GEDescription
{
    return self.snippet.description;
}

- (NSString*)GEThumbnailUrl
{
    return self.snippet.thumbnails.medium.url;
}

- (NSDate*)GEPublishedAt
{
    return self.snippet.publishedAt.date;
}

- (NSUInteger)GETotalItemCount
{
    return INT_MAX;
}

@end
