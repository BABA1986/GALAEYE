//
//  GEYoutubeResult.h
//  GETube
//
//  Created by Deepak on 22/07/16.
//  Copyright © 2016 Deepak. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GEYoutubeResult <NSObject>
- (NSString*)GEId;
- (NSString*)GETitle;
- (NSString*)GEDescription;
- (NSString*)GEThumbnailUrl;
- (NSDate*)GEPublishedAt;
- (NSUInteger)GETotalItemCount;

@optional
- (NSString*)GEChannelTitle;
- (NSString*)GEChannelId;
- (NSNumber*)GEViewCount;
- (NSDate*)eventStartStreamDate;
- (NSDate*)eventEndStreamDate;
- (NSUInteger)GETotalViews;
- (NSUInteger)GETotalLiveViewers;
- (NSString*)GETotalLikes;
- (NSString*)GETotalDisLikes;
- (void)GESetLike;
- (void)GESetMyLikeRemove;
- (void)GESetDisLike;
- (void)GESetMyDisLikeRemove;

@end
