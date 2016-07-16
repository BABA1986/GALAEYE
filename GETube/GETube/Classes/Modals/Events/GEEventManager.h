//
//  GEEventManager.h
//  GETube
//
//  Created by Deepak on 20/06/16.
//  Copyright © 2016 Deepak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTLYouTube.h"

typedef enum : NSUInteger {
    EFetchEventsCompleted,
    EFetchEventsUpcomming,
    EFetchEventsLive,
    EFetchEventsNone
} FetchEventQueryType;

@interface GEEventListPage : NSObject
@property(nonatomic, strong)NSArray*            eventList;
@property(nonatomic, strong)NSString*           nextPageToken;
@property(nonatomic, strong)NSString*           prevPageToken;
- (id)initWithList: (NSArray*)list
          nextPage: (NSString*)nxtPageToken
  andPrevPageToken: (NSString*)prvPageToken;
@end


@interface GEEventListObj : NSObject
@property(nonatomic, strong)NSMutableArray*     eventListPages;
@property(nonatomic, assign)FetchEventQueryType eventType;
@property(nonatomic, assign)NSUInteger          totalResult;

- (id)initWithResponse: (GTLYouTubeSearchListResponse*)response
             eventType: (FetchEventQueryType)eventQueryType;
- (void)addEventsFromResponse: (GTLYouTubeSearchListResponse*)response;
@end


@interface GEEventManager : NSObject
{
    NSMutableArray*                 mEventListObjs;
}

@property(nonatomic, readonly)NSMutableArray*       eventListObjs;

+ (id)manager;

- (NSString*)pageTokenForEventOfType: (FetchEventQueryType)eventQueryType
                        canFetchMore: (BOOL*)canFetch;
- (void)addEventSearchResponse: (GTLYouTubeSearchListResponse*)response
                  forEventType: (FetchEventQueryType)eventQueryType;
@end
