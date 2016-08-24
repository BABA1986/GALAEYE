//
//  GEEventManager.h
//  GETube
//
//  Created by Deepak on 20/06/16.
//  Copyright © 2016 Deepak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTLYouTube.h"
#import "GEEventManager.h"

typedef enum : NSUInteger {
    EFetchEventsNone = 0,
    EFetchEventsCompleted,
    EFetchEventsUpcomming,
    EFetchEventsPopularCompleted,
    EFetchEventsLive,
    EFetchEventsPlaylistItem
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
@property(nonatomic, strong)NSString*           channelSource;
@property(nonatomic, assign)NSUInteger          totalResult;

- (id)initWithResponse: (GTLYouTubeVideoListResponse*)response
             eventType: (FetchEventQueryType)eventQueryType
         channelSource: (NSString*)channelId;
- (void)addEventsFromResponse: (GTLYouTubeVideoListResponse*)response;
@end


@interface GEEventManager : NSObject
{
    NSMutableArray*                 mEventListObjs;
}

@property(nonatomic, readonly)NSMutableArray*       eventListObjs;

+ (id)manager;

- (NSString*)pageTokenForEventOfType: (FetchEventQueryType)eventQueryType
                           forSource: (NSString*)channelId
                        canFetchMore: (BOOL*)canFetch;
- (void)addEventSearchResponse: (GTLYouTubeVideoListResponse*)response
                  forEventType: (FetchEventQueryType)eventQueryType
                     forSource: (NSString*)channelId;
- (GEEventListObj*)eventListObjForEventType: (FetchEventQueryType)fetchType
                                  forSource: (NSString*)channelId;
@end
