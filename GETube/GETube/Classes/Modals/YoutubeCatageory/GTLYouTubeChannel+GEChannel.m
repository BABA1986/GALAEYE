//
//  GTLYouTubeChannel+GEChannel.m
//  GETube
//
//  Created by Deepak on 22/07/16.
//  Copyright © 2016 Deepak. All rights reserved.
//

#import "GTLYouTubeChannel+GEChannel.h"

@implementation GTLYouTubeChannel (GEChannel)

- (NSString*)GEId
{
    return self.identifier;
}

- (NSString*)GETitle
{
    return self.snippet.title;
}

- (NSString*)GEDescription
{
    return self.snippet.descriptionProperty;
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
