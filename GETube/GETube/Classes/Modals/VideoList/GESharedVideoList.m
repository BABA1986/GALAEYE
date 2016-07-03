//
//  GESharedVideoList.m
//  GETube
//
//  Created by Deepak on 02/07/16.
//  Copyright © 2016 Deepak. All rights reserved.
//

#import "GESharedVideoList.h"

@implementation GEVideoListPage : NSObject
@synthesize videoList;
@synthesize nextPageToken;
@synthesize prevPageToken;
- (id)initWithList: (NSArray*)list
          nextPage: (NSString*)nxtPageToken
  andPrevPageToken: (NSString*)prvPageToken
{
    self = [super init];
    if (self)
    {
        self.videoList = [[NSArray alloc] initWithArray: list];
        self.nextPageToken = nxtPageToken;
        self.prevPageToken = prvPageToken;
    }
    
    return self;
}
@end

@implementation GEVideoListObj : NSObject
@synthesize  videoListPages;
@synthesize  listSource;
@synthesize  totalResult;

- (id)initWithResponse: (GTLYouTubeVideoListResponse*)response
             forSource:(NSString *)listSourceID
{
    self = [super init];
    if (self)
    {
        self.listSource = listSourceID;
        self.totalResult = [response.pageInfo.totalResults integerValue];
        GEVideoListPage* lGEVideoListPage = [[GEVideoListPage alloc] initWithList: response.items nextPage: response.nextPageToken andPrevPageToken: response.prevPageToken];
        self.videoListPages = [[NSMutableArray alloc] init];
        [self.videoListPages addObject: lGEVideoListPage];
    }
    
    return self;
}

- (void)addVideoListFromResponse:(GTLYouTubeVideoListResponse *)response
{
    GEVideoListPage* lGEVideoListPage = [[GEVideoListPage alloc] initWithList: response.items nextPage: response.nextPageToken andPrevPageToken: response.prevPageToken];
    [self.videoListPages addObject: lGEVideoListPage];
}

@end

@interface GESharedVideoList ()
- (void)initialiseListObjs;
@end

@implementation GESharedVideoList

@synthesize videoListObjs = mVideoListObjs;

+ (id)sharedVideoList
{
    static dispatch_once_t once;
    static GESharedVideoList* sGESharedVideoList = nil;
    dispatch_once(&once, ^
                  {
                      sGESharedVideoList = [[self alloc] init];
                      [sGESharedVideoList initialiseListObjs];
                  });
    
    return sGESharedVideoList;
}

- (void)initialiseListObjs
{
    mVideoListObjs = [[NSMutableArray alloc] init];
}

- (GEVideoListObj*)videoListObjForChannelSource: (NSString*)listSource
{
    GEVideoListObj* lListObj = nil;
    for (lListObj in mVideoListObjs)
    {
        if ([listSource isEqualToString: lListObj.listSource])
        {
            break;
        }
    }
    
    return lListObj;
}

- (NSString*)pageTokenForVideoListForSource: (NSString*)channelSource
                               canFetchMore: (BOOL*)canFetch
{
    GEVideoListObj* lGEVideoListObj = [self videoListObjForChannelSource: channelSource];
    if (!lGEVideoListObj)
    {
        *canFetch = TRUE;
        return nil;
    }
    
    GEVideoListPage* lLastPage = [lGEVideoListObj.videoListPages lastObject];
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

- (void)addVideoListSearchResponse: (GTLYouTubeVideoListResponse*)response
                         forSource: (NSString*)channelSource
{
    GEVideoListObj* lGEVideoListObj = [self videoListObjForChannelSource: channelSource];
    
    if(!lGEVideoListObj)
    {
        lGEVideoListObj = [[GEVideoListObj alloc] initWithResponse: response forSource: channelSource];
        [mVideoListObjs addObject: lGEVideoListObj];
    }
    else
    {
        [lGEVideoListObj addVideoListFromResponse: response];
    }
}

@end
