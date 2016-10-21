//
//  GEEventManager.m
//  GETube
//
//  Created by Deepak on 20/06/16.
//  Copyright © 2016 Deepak. All rights reserved.
//

#import "GEEventManager.h"
#import "GEConstants.h"

@implementation GEEventListPage : NSObject
@synthesize eventList;
@synthesize nextPageToken;
@synthesize prevPageToken;
- (id)initWithList: (NSArray*)list
          nextPage: (NSString*)nxtPageToken
  andPrevPageToken: (NSString*)prvPageToken
{
    self = [super init];
    if (self)
    {
        self.eventList = [[NSArray alloc] initWithArray: list];
        self.nextPageToken = nxtPageToken;
        self.prevPageToken = prvPageToken;
    }
    
    return self;
}
@end

@implementation GEEventListObj : NSObject
@synthesize  channelSource;
@synthesize  eventListPages;
@synthesize  eventType;
@synthesize  totalResult;

- (id)initWithResponse: (GTLYouTubeVideoListResponse*)response
             eventType: (FetchEventQueryType)eventQueryType
         channelSource: (NSString*)channelId
{
    self = [super init];
    if (self)
    {
        self.eventType = eventQueryType;
        self.totalResult = [response.pageInfo.totalResults integerValue];
        
        NSArray* lFilteredVideo = nil;
        if (eventQueryType == EFetchEventsLiked)
            lFilteredVideo = [self videoFromGalaChannelFrom: response.items];
        else
            lFilteredVideo = response.items;
        
        GEEventListPage* lGEEventListPage = [[GEEventListPage alloc] initWithList: lFilteredVideo nextPage: response.nextPageToken andPrevPageToken: response.prevPageToken];
        self.eventListPages = [[NSMutableArray alloc] init];
        [self.eventListPages addObject: lGEEventListPage];
        self.channelSource = channelId;
    }
    
    return self;
}

- (NSArray*)videoFromGalaChannelFrom: (NSArray*)videoList
{
    NSMutableArray* lFilterdVideo = [[NSMutableArray alloc] init];

    for (NSObject <GEYoutubeResult>* lVideoItem in videoList)
    {
        if ([[lVideoItem GEChannelId] isEqualToString: kGEChannelID])
        {
            [lFilterdVideo addObject: lVideoItem];
        }
    }
    
    return lFilterdVideo;
}

- (void)addEventsFromResponse: (GTLYouTubeVideoListResponse*)response
{
    NSArray* lFilteredVideo = nil;
    if (self.eventType == EFetchEventsLiked)
        lFilteredVideo = [self videoFromGalaChannelFrom: response.items];
    else
        lFilteredVideo = response.items;
    
    GEEventListPage* lGEEventListPage = [[GEEventListPage alloc] initWithList: lFilteredVideo nextPage: response.nextPageToken andPrevPageToken: response.prevPageToken];
    [self.eventListPages addObject: lGEEventListPage];
}

@end

@interface GEEventManager ()
- (void)initialiseListObjs;
@end

@implementation GEEventManager
@synthesize eventListObjs = mEventListObjs;
+ (id)manager
{
    static dispatch_once_t once;
    static GEEventManager* sGEEventManager = nil;
    dispatch_once(&once, ^
                  {
                      sGEEventManager = [[self alloc] init];
                      [sGEEventManager initialiseListObjs];
                  });
    
    return sGEEventManager;
}

- (void)initialiseListObjs
{
    mEventListObjs = [[NSMutableArray alloc] init];
}

- (GEEventListObj*)eventListObjForEventType: (FetchEventQueryType)fetchType
                                  forSource: (NSString*)channelId
{
    GEEventListObj* lListObj = nil;
    for (lListObj in mEventListObjs)
    {
        if ((fetchType == lListObj.eventType) && ([lListObj.channelSource isEqualToString: channelId]))
        {
            break;
        }
    }
    
    return lListObj;
}

- (NSString*)pageTokenForEventOfType: (FetchEventQueryType)eventQueryType
                           forSource: (NSString*)channelId
                        canFetchMore: (BOOL*)canFetch
{
    GEEventListObj* lGEEventListObj = [self eventListObjForEventType: eventQueryType forSource: channelId];
    if (!lGEEventListObj)
    {
        *canFetch = TRUE;
        return nil;
    }
    
    GEEventListPage* lLastPage = [lGEEventListObj.eventListPages lastObject];    
    if (lLastPage.nextPageToken.length)
    {
        *canFetch = TRUE;
        return lLastPage.nextPageToken;
    }
    
    *canFetch = FALSE;
    return nil;
}

- (void)addEventSearchResponse: (GTLYouTubeVideoListResponse*)response
                  forEventType: (FetchEventQueryType)eventQueryType
                     forSource: (NSString*)channelId;
{
    if (![response.pageInfo.totalResults integerValue] && (eventQueryType == EFetchEventsPrivate || eventQueryType == EFetchEventsLiked))
    {
        return;
    }
    
    GEEventListObj* lGEEventListObj = [self eventListObjForEventType: eventQueryType forSource: channelId];
    
    if(!lGEEventListObj)
    {
        lGEEventListObj = [[GEEventListObj alloc] initWithResponse: response eventType: eventQueryType channelSource: channelId];
        [mEventListObjs addObject: lGEEventListObj];
    }
    else
    {
        [lGEEventListObj addEventsFromResponse: response];
    }
}

- (void)likeCachedVideoItem: (NSObject<GEYoutubeResult>*)videoItem
{
    NSString* lChannelId = videoItem.GEChannelId;
    if (![lChannelId isEqualToString: kGEChannelID])
    {
        return;
    }
    
    GEEventListObj* lGEEventListObj = [self eventListObjForEventType: EFetchEventsLiked forSource: kGEChannelID];
    GEEventListPage* lLastPage = [lGEEventListObj.eventListPages lastObject];
    NSMutableArray* lNewList = [[NSMutableArray alloc] initWithArray: lLastPage.eventList];
    [lNewList addObject: videoItem];
    lLastPage.eventList = lNewList;
}

- (void)unlikeCachedVideoItem: (NSObject<GEYoutubeResult>*)videoItem
{
    NSString* lChannelId = videoItem.GEChannelId;
    if (![lChannelId isEqualToString: kGEChannelID])
    {
        return;
    }
    
    GEEventListObj* lGEEventListObj = [self eventListObjForEventType: EFetchEventsLiked forSource: kGEChannelID];
    for (GEEventListPage* lPage in lGEEventListObj.eventListPages)
    {
        NSMutableArray* lNewList = [[NSMutableArray alloc] init];
        BOOL lIsFound = FALSE;
        
        for (NSObject<GEYoutubeResult>* lItem in lPage.eventList)
        {
            if ([lItem.GEId isEqualToString: videoItem.GEId])
            {
                lIsFound = TRUE;
            }
            else
            {
                [lNewList addObject: lItem];
            }
        }
        
        if (lIsFound)
        {
            lPage.eventList = lNewList;
            break;
        }
    }
}


@end
