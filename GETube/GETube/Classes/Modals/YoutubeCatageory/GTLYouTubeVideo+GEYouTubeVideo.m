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

- (NSString*)GEChannelId
{
    return self.snippet.channelId;
}

- (NSString*)GEChannelTitle
{
    return self.snippet.channelTitle;
}

- (NSUInteger)GETotalViews;
{
    return [self.statistics.viewCount integerValue];
}

- (NSUInteger)GETotalLiveViewers
{
    return [self.liveStreamingDetails.concurrentViewers integerValue];
}

- (NSString*)GETotalLikes
{
    NSUInteger lCount = [self.statistics.likeCount integerValue];
    return [NSString stringWithFormat: @"%ld", lCount];
}

- (NSString*)GETotalDisLikes
{
    NSUInteger lCount = [self.statistics.dislikeCount integerValue];
    return [NSString stringWithFormat: @"%ld", lCount];
}

- (void)GESetLike
{
    NSUInteger lCount = [self.statistics.likeCount integerValue];
    lCount += 1;
    self.statistics.likeCount = [NSNumber numberWithInteger: lCount];
}

- (void)GESetMyLikeRemove
{
    NSUInteger lCount = [self.statistics.likeCount integerValue];
    lCount -= 1;
    self.statistics.likeCount = [NSNumber numberWithInteger: lCount];
}

- (void)GESetDisLike
{
    NSUInteger lCount = [self.statistics.dislikeCount integerValue];
    lCount += 1;
    self.statistics.dislikeCount = [NSNumber numberWithInteger: lCount];
}

- (void)GESetMyDisLikeRemove
{
    NSUInteger lCount = [self.statistics.dislikeCount integerValue];
    lCount -= 1;
    self.statistics.dislikeCount = [NSNumber numberWithInteger: lCount];
}

@end
