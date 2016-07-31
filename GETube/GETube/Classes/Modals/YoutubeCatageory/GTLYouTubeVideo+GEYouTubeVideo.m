//
//  GTLYouTubeVideo+GEYouTubeVideo.m
//  GETube
//
//  Created by Deepak on 22/07/16.
//  Copyright © 2016 Deepak. All rights reserved.
//

#import "GTLYouTubeVideo+GEYouTubeVideo.h"

@implementation GTLYouTubeVideo (GEYouTubeVideo)

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

- (NSNumber*)GEViewCount
{
    return self.statistics.viewCount;
}

- (NSDate*)eventStartStreamDate
{
    return self.liveStreamingDetails.scheduledStartTime.date;
}

- (NSDate*)eventEndStreamDate
{
    return self.liveStreamingDetails.actualEndTime.date;
}

@end
