//
//  GTLYouTubePlaylistItem+GEPlaylistItem.m
//  GETube
//
//  Created by Deepak on 22/07/16.
//  Copyright © 2016 Deepak. All rights reserved.
//

#import "GTLYouTubePlaylistItem+GEPlaylistItem.h"

@implementation GTLYouTubePlaylistItem (GEPlaylistItem)

- (NSString*)GEId
{
    return self.contentDetails.videoId;
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

- (NSString*)GEChannelTitle
{
    return self.snippet.channelTitle;
}

- (NSString*)GEChannelId
{
    return self.snippet.channelId;
}

@end
