//
//  GTLYouTubePlaylist+GEPlaylist.m
//  GETube
//
//  Created by Deepak on 22/07/16.
//  Copyright © 2016 Deepak. All rights reserved.
//

#import "GTLYouTubePlaylist+GEPlaylist.h"

@implementation GTLYouTubePlaylist (GEPlaylist)

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
    return [self.contentDetails.itemCount integerValue];
}

- (NSString*)GEChannelTitle
{
    return self.snippet.channelTitle;
}

@end
