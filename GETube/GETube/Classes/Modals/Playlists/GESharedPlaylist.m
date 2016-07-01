//
//  GESharedPlaylist.m
//  GETube
//
//  Created by Deepak on 20/06/16.
//  Copyright © 2016 Deepak. All rights reserved.
//

#import "GESharedPlaylist.h"

@implementation GEPlaylistListPage : NSObject
@synthesize playlistList;
@synthesize nextPageToken;
@synthesize prevPageToken;
- (id)initWithList: (NSArray*)list
          nextPage: (NSString*)nxtPageToken
  andPrevPageToken: (NSString*)prvPageToken
{
    self = [super init];
    if (self)
    {
        self.playlistList = [[NSArray alloc] initWithArray: list];
        self.nextPageToken = nxtPageToken;
        self.prevPageToken = prvPageToken;
    }
    
    return self;
}
@end

@implementation GEPlaylistListObj : NSObject
@synthesize  playlistListPages;
@synthesize  channelSource;
@synthesize  totalResult;

- (id)initWithResponse: (GTLYouTubePlaylistListResponse*)response
             forSource:(NSString *)channelSourceID
{
    self = [super init];
    if (self)
    {
        self.channelSource = channelSourceID;
        self.totalResult = [response.pageInfo.totalResults integerValue];
        GEPlaylistListPage* lGEPlaylistListPage = [[GEPlaylistListPage alloc] initWithList: response.items nextPage: response.nextPageToken andPrevPageToken: response.prevPageToken];
        self.playlistListPages = [[NSMutableArray alloc] init];
        [self.playlistListPages addObject: lGEPlaylistListPage];
    }
    
    return self;
}

- (void)addplaylistListFromResponse:(GTLYouTubePlaylistListResponse *)response
{
    GEPlaylistListPage* lGEPlaylistListPage = [[GEPlaylistListPage alloc] initWithList: response.items nextPage: response.nextPageToken andPrevPageToken: response.prevPageToken];
    [self.playlistListPages addObject: lGEPlaylistListPage];
}

@end

@interface GESharedPlaylistList ()
- (void)initialiseListObjs;
@end

@implementation GESharedPlaylistList

+ (id)sharedPlaylistList
{
    static dispatch_once_t once;
    static GESharedPlaylistList* sGESharedPlaylistList = nil;
    dispatch_once(&once, ^
                  {
                      sGESharedPlaylistList = [[self alloc] init];
                      [sGESharedPlaylistList initialiseListObjs];
                  });
    
    return sGESharedPlaylistList;
}

- (void)initialiseListObjs
{
    mPlaylistListObjs = [[NSMutableArray alloc] init];
}

- (GEPlaylistListObj*)playlistObjForChannelSource: (NSString*)channelSource
{
    GEPlaylistListObj* lListObj = nil;
    for (lListObj in mPlaylistListObjs)
    {
        if ([channelSource isEqualToString: lListObj.channelSource])
        {
            break;
        }
    }
    
    return lListObj;
}

- (NSString*)pageTokenForPlaylistForSource: (NSString*)channelSource
                              canFetchMore: (BOOL*)canFetch
{
    GEPlaylistListObj* lPlaylistListObj = [self playlistObjForChannelSource: channelSource];
    if (!lPlaylistListObj)
    {
        *canFetch = TRUE;
        return nil;
    }
    
    GEPlaylistListPage* lLastPage = [lPlaylistListObj.playlistListPages lastObject];
    if (!lLastPage)
    {
        *canFetch = TRUE;
        return nil;
    }
    
    if (lLastPage.nextPageToken.length)
    {
        *canFetch = TRUE;
        return lLastPage.nextPageToken;
    }
    
    *canFetch = FALSE;
    return nil;
}

- (void)addplaylistSearchResponse: (GTLYouTubePlaylistListResponse*)response
                        forSource: (NSString*)channelSource
{
    GEPlaylistListObj* lPlaylistListObj = [self playlistObjForChannelSource: channelSource];
    
    if(!lPlaylistListObj)
    {
        lPlaylistListObj = [[GEPlaylistListObj alloc] initWithResponse: response forSource: channelSource];
        [mPlaylistListObjs addObject: lPlaylistListObj];
    }
    else
    {
        [lPlaylistListObj addplaylistListFromResponse: response];
    }
}

@end
