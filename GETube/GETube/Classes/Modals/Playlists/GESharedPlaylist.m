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
@synthesize  listSource;
@synthesize  totalResult;

- (id)initWithResponse: (GTLYouTubePlaylistListResponse*)response
             forSource:(NSString *)listSourceID
{
    self = [super init];
    if (self)
    {
        self.listSource = listSourceID;
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

- (GEPlaylistListObj*)playlistObjForChannelSource: (NSString*)listSource
{
    GEPlaylistListObj* lListObj = nil;
    for (lListObj in mPlaylistListObjs)
    {
        if ([listSource isEqualToString: lListObj.listSource])
        {
            break;
        }
    }
    
    return lListObj;
}

- (NSString*)pageTokenForPlaylistForSource: (NSString*)listSource
                              canFetchMore: (BOOL*)canFetch
{
    GEPlaylistListObj* lPlaylistListObj = [self playlistObjForChannelSource: listSource];
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
                        forSource: (NSString*)listSource
{
    GEPlaylistListObj* lPlaylistListObj = [self playlistObjForChannelSource: listSource];
    
    if(!lPlaylistListObj)
    {
        lPlaylistListObj = [[GEPlaylistListObj alloc] initWithResponse: response forSource: listSource];
        [mPlaylistListObjs addObject: lPlaylistListObj];
    }
    else
    {
        [lPlaylistListObj addplaylistListFromResponse: response];
    }
}

@end
