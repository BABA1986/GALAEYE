//
//  GESharedPlaylist.h
//  GETube
//
//  Created by Deepak on 20/06/16.
//  Copyright © 2016 Deepak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTLYouTube.h"

@interface GEPlaylistListPage : NSObject
@property(nonatomic, strong)NSArray*            playlistList;
@property(nonatomic, strong)NSString*           nextPageToken;
@property(nonatomic, strong)NSString*           prevPageToken;
- (id)initWithList: (NSArray*)list
          nextPage: (NSString*)nxtPageToken
  andPrevPageToken: (NSString*)prvPageToken;
@end


@interface GEPlaylistListObj : NSObject
@property(nonatomic, strong)NSMutableArray*     playlistListPages;
@property(nonatomic, copy)NSString*             channelSource;
@property(nonatomic, assign)NSUInteger          totalResult;

- (id)initWithResponse: (GTLYouTubePlaylistListResponse*)response
             forSource: (NSString*)channelSource;
- (void)addplaylistListFromResponse: (GTLYouTubePlaylistListResponse*)response;
@end


@interface GESharedPlaylistList : NSObject
{
    NSMutableArray*                 mPlaylistListObjs;
}

@property(nonatomic, readonly)NSMutableArray*       playlistListObjs;

+ (id)sharedPlaylistList;

- (GEPlaylistListObj*)playlistObjForChannelSource: (NSString*)channelSource;
- (NSString*)pageTokenForPlaylistForSource: (NSString*)channelSource
                              canFetchMore: (BOOL*)canFetch;
- (void)addplaylistSearchResponse: (GTLYouTubePlaylistListResponse*)response
                        forSource: (NSString*)channelSourceID;

@end
