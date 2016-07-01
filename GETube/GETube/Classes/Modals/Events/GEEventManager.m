//
//  GEEventManager.m
//  GETube
//
//  Created by Deepak on 20/06/16.
//  Copyright © 2016 Deepak. All rights reserved.
//

#import "GEEventManager.h"

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
@synthesize  eventListPages;
@synthesize  eventType;
@synthesize  totalResult;

- (id)initWithResponse: (GTLYouTubeSearchListResponse*)response
             eventType: (FetchEventQueryType)eventQueryType
{
    self = [super init];
    if (self)
    {
        self.eventType = eventQueryType;
        self.totalResult = [response.pageInfo.totalResults integerValue];
        GEEventListPage* lGEEventListPage = [[GEEventListPage alloc] initWithList: response.items nextPage: response.nextPageToken andPrevPageToken: response.prevPageToken];
        self.eventListPages = [[NSMutableArray alloc] init];
        [self.eventListPages addObject: lGEEventListPage];
    }
    
    return self;
}

- (void)addEventsFromResponse: (GTLYouTubeSearchListResponse*)response
{
    GEEventListPage* lGEEventListPage = [[GEEventListPage alloc] initWithList: response.items nextPage: response.nextPageToken andPrevPageToken: response.prevPageToken];
    [self.eventListPages addObject: lGEEventListPage];
}

@end


@interface GEEventManager ()
- (void)initialiseListObjs;
- (GEEventListObj*)eventListObjForEventType: (FetchEventQueryType)fetchType;
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
{
    GEEventListObj* lListObj = nil;
    for (lListObj in mEventListObjs)
    {
        if (fetchType == lListObj.eventType)
        {
            break;
        }
    }
    
    return lListObj;
}

- (NSString*)pageTokenForEventOfType: (FetchEventQueryType)eventQueryType
                        canFetchMore: (BOOL*)canFetch
{
    GEEventListObj* lGEEventListObj = [self eventListObjForEventType: eventQueryType];
    if (!lGEEventListObj)
    {
        *canFetch = TRUE;
        return nil;
    }
    
    GEEventListPage* lLastPage = [lGEEventListObj.eventListPages lastObject];
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

- (void)addEventSearchResponse: (GTLYouTubeSearchListResponse*)response
                  forEventType: (FetchEventQueryType)eventQueryType
{
    GEEventListObj* lGEEventListObj = [self eventListObjForEventType: eventQueryType];
    
    if(!lGEEventListObj)
    {
        lGEEventListObj = [[GEEventListObj alloc] initWithResponse: response eventType: eventQueryType];
        [mEventListObjs addObject: lGEEventListObj];
    }
    else
    {
        [lGEEventListObj addEventsFromResponse: response];
    }
}

@end
