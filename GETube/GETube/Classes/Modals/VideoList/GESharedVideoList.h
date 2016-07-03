//
//  GESharedVideoList.h
//  GETube
//
//  Created by Deepak on 02/07/16.
//  Copyright © 2016 Deepak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTLYouTube.h"

@interface GEVideoListPage : NSObject
@property(nonatomic, strong)NSArray*            videoList;
@property(nonatomic, strong)NSString*           nextPageToken;
@property(nonatomic, strong)NSString*           prevPageToken;
- (id)initWithList: (NSArray*)list
          nextPage: (NSString*)nxtPageToken
  andPrevPageToken: (NSString*)prvPageToken;
@end


@interface GEVideoListObj : NSObject
@property(nonatomic, strong)NSMutableArray*     videoListPages;
@property(nonatomic, copy)NSString*             listSource;
@property(nonatomic, assign)NSUInteger          totalResult;

- (id)initWithResponse: (GTLYouTubeVideoListResponse*)response
             forSource: (NSString*)channelSource;
- (void)addVideoListFromResponse: (GTLYouTubeVideoListResponse*)response;
@end

@interface GESharedVideoList : NSObject
{
    NSMutableArray*                 mVideoListObjs;
}

@property(nonatomic, readonly)NSMutableArray*       videoListObjs;

+ (id)sharedVideoList;

- (GEVideoListObj*)videoListObjForChannelSource: (NSString*)listSource;
- (NSString*)pageTokenForVideoListForSource: (NSString*)listSource
                               canFetchMore: (BOOL*)canFetch;
- (void)addVideoListSearchResponse: (GTLYouTubeVideoListResponse*)response
                         forSource: (NSString*)listSourceID;

@end
