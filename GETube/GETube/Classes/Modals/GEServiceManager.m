//
//  GEServiceManager.m
//  GETube
//
//  Created by Deepak on 19/06/16.
//  Copyright © 2016 Deepak. All rights reserved.
//

#import "GEServiceManager.h"
#import "GEEventManager.h"
#import "GESharedPlaylist.h"
#import "GESharedVideoList.h"
#import "UserDataManager.h"
#import "GEConstants.h"
#import "SharedReminder.h"
#import <GTMOAuth2/GTMOAuth2Authentication.h>

@interface GEServiceManager ()
- (void)initialiseYTService;
- (void)subscribeMe;
- (GTLQueryYouTube*)queryForVideoListFromSearch: (GTLYouTubeSearchListResponse*)result;
- (GTLQueryYouTube*)queryForMyLikedVideos;
- (GTLQueryYouTube*)queryForVideoListFromPlaylistVideoList: (GTLYouTubePlaylistItemListResponse*)result;
- (GTLQueryYouTube*)queryForEventFetchType: (FetchEventQueryType)eventType
                                 channelId: (NSString*)channelId
                                 pageToken: (NSString*)pageToken;

- (GTLQueryYouTube*)queryForPlaylistListOfChannel: (NSString*)channelId
                                        pageToken: (NSString*)pageToken;
- (void)channelIdFroChannelSource: (NSString*)channelSrc
                     onCompletion: (void(^)(NSString* channelId))onCompletion;

- (GTLQueryYouTube*)queryForVideoListOfPlaylist: (NSString*)playlistId
                                      pageToken: (NSString*)pageToken;


- (void)loadEventOfType: (FetchEventQueryType)queryType
           onCompletion: (GEServiceEventsLoadedCallbacks)finishCallback;

@end

@implementation GEServiceManager

+ (id)sharedManager
{
    static dispatch_once_t once;
    static GEServiceManager* sGEServiceManager = nil;
    dispatch_once(&once, ^
                  {
                      sGEServiceManager = [[self alloc] init];
                      [sGEServiceManager initialiseYTService];
                  });
    
    return sGEServiceManager;
}

- (void)initialiseYTService
{
    mYTService = [[GTLServiceYouTube alloc] init];
    mYTService.APIKey = kGEAPIKey;
}

- (void)loginDone
{
    UserDataManager* lManager = [UserDataManager userDataManager];
    GTMOAuth2Authentication* lAuth = [[GTMOAuth2Authentication alloc] init];
    [lAuth setClientID: lManager.userData.clientId];
    [lAuth setUserEmail: lManager.userData.email];
    [lAuth setUserID: lManager.userData.userId];
    [lAuth setAccessToken: lManager.userData.accessToken];
    [lAuth setRefreshToken: lManager.userData.refreshToken];
    [lAuth setExpirationDate: lManager.userData.accessTokenExpDate];
    if (lAuth.canAuthorize)
    {
        [mYTService setAuthorizer: lAuth];
    }
    
    [mYTService setAuthorizer: lAuth];
    
    [self subscribeMe];
}

- (void)subscribeMe
{
    GTLYouTubeSubscriptionSnippet* lSnippet = [GTLYouTubeSubscriptionSnippet object];
    GTLYouTubeResourceId* lResourceObject = [GTLYouTubeResourceId object];
    lResourceObject.channelId = kGEChannelID;
    lSnippet.resourceId = lResourceObject;
    
    GTLYouTubeSubscription* lSubscription = [GTLYouTubeSubscription object];
    lSubscription.snippet = lSnippet;
    
    GTLQueryYouTube *query = [GTLQueryYouTube queryForSubscriptionsInsertWithObject:lSubscription part:@"contentDetails,snippet"];
    
    [mYTService executeQuery:query
        completionHandler:^(GTLServiceTicket *ticket,
                            GTLYouTubeSubscription *subscription,
                            NSError *error) {
            /* Callback */
            NSLog(@"subscription:%@", subscription);
            NSLog(@"error:%@", error);
            
        }];
}

- (void)getMyRatingForVideo: (NSObject<GEYoutubeResult>*)videoItem
               onCompletion: (void(^)(NSString* rating))finishCallback
{
    GTLQueryYouTube *query = [GTLQueryYouTube queryForVideosGetRatingWithIdentifier: videoItem.GEId];
    
    [mYTService executeQuery:query
           completionHandler:^(GTLServiceTicket *ticket,
                               GTLYouTubeVideoGetRatingResponse *ratingResponse,
                               NSError *error) {
               if(error)
               {
                   finishCallback(@"None");
               }
               else
               {
                   GTLYouTubeVideoRating* lRating = [ratingResponse.items firstObject];
                   finishCallback(lRating.rating);
               }
           }];
}

- (void)addMyRating: (NSString*)rating
           forVideo: (NSObject<GEYoutubeResult>*)videoItem
       onCompletion: (void(^)(bool sucess))finishCallback
{
    GTLQueryYouTube *query = [GTLQueryYouTube queryForVideosRateWithIdentifier: videoItem.GEId rating: rating];
    
    [mYTService executeQuery:query
           completionHandler:^(GTLServiceTicket *ticket,
                               id response,
                               NSError *error) {
               if(error)
               {
                   finishCallback(FALSE);
               }
               else
               {
                   finishCallback(TRUE);
               }
           }];
}

- (GTLQueryYouTube*)queryForVideoListFromPlaylistVideoList: (GTLYouTubePlaylistItemListResponse*)result
{
    GTLQueryYouTube* lQuery = [GTLQueryYouTube queryForVideosListWithPart: @"id,snippet,statistics"];
    lQuery.maxResults = 20;
    lQuery.type = @"video";
    NSString* lVideos = @"";
    for (GTLYouTubePlaylistItem* lItem in result)
    {
        if ([result.items lastObject] != lItem) {
            lVideos = [lVideos stringByAppendingFormat: @"%@,", lItem.snippet.resourceId.videoId];
            continue;
        }
        lVideos = [lVideos stringByAppendingFormat: @"%@", lItem.snippet.resourceId.videoId];
    }
    lQuery.identifier = lVideos;
    return lQuery;
}

- (GTLQueryYouTube*)queryForVideoListFromSearch: (GTLYouTubeSearchListResponse*)result
{
    GTLQueryYouTube* lQuery = [GTLQueryYouTube queryForVideosListWithPart: @"id,snippet,liveStreamingDetails,statistics"];
    lQuery.maxResults = 20;
    lQuery.type = @"video";
    NSString* lVideos = @"";
    for (GTLYouTubeSearchResult* lItem in result)
    {
        if ([result.items lastObject] != lItem) {
            lVideos = [lVideos stringByAppendingFormat: @"%@,", lItem.identifier.videoId];
            continue;
        }
        lVideos = [lVideos stringByAppendingFormat: @"%@", lItem.identifier.videoId];
    }
    lQuery.identifier = lVideos;
    return lQuery;
}

- (GTLQueryYouTube*)queryForVideoListFromReminders
{
    GTLQueryYouTube* lQuery = [GTLQueryYouTube queryForVideosListWithPart: @"id,snippet,liveStreamingDetails,statistics"];
    lQuery.maxResults = 50;
    lQuery.type = @"video";
    lQuery.order = @"date";
    NSArray* lVideos = [[SharedReminder SharedRemider] remiderVideoIds];
    NSString* lIds = @"";
    for (NSString* lItem in lVideos)
    {
        if ([lVideos lastObject] != lItem) {
            lIds = [lIds stringByAppendingFormat: @"%@,", lItem];
            continue;
        }
        lIds = [lIds stringByAppendingFormat: @"%@", lItem];
    }
    lQuery.identifier = lIds;
    return lQuery;
}

- (GTLQueryYouTube*)queryForMyLikedVideos
{
    GTLQueryYouTube* lQuery = [GTLQueryYouTube queryForVideosListWithPart: @"id,snippet,liveStreamingDetails,statistics"];
    lQuery.maxResults = 20;
    lQuery.type = @"video";
    lQuery.myRating = @"like";
    return lQuery;
}

- (GTLQueryYouTube*)queryForEventFetchType: (FetchEventQueryType)eventType
                                 channelId: (NSString*)channelId
                                 pageToken: (NSString*)pageToken
{
    GTLQueryYouTube* lQuery = [GTLQueryYouTube queryForSearchListWithPart: @"id"];
    lQuery.maxResults = 20;
    lQuery.type = @"video";
    lQuery.channelId = channelId;
    lQuery.order = @"date";
    
    if (eventType == EFetchEventsLive) {
        lQuery.eventType = kGTLYouTubeEventTypeLive;
    }
    else if (eventType == EFetchEventsUpcomming) {
        lQuery.eventType = kGTLYouTubeEventTypeUpcoming;
    }
    else if (eventType == EFetchEventsCompleted) {
        lQuery.eventType = kGTLYouTubeEventTypeCompleted;
    }
    else if (eventType == EFetchEventsPopularCompleted) {
        lQuery.eventType = kGTLYouTubeEventTypeCompleted;
        lQuery.order = kGTLYouTubeOrderViewCount;
    }
    
    lQuery.pageToken = pageToken;
    return lQuery;
}

- (GTLQueryYouTube*)queryForPlaylistListOfChannel: (NSString*)channelId
                                        pageToken: (NSString*)pageToken
{
    GTLQueryYouTube* lQuery = [GTLQueryYouTube queryForPlaylistsListWithPart: @"id,snippet,contentDetails"];
    lQuery.maxResults = 20;
    lQuery.channelId = channelId;
    lQuery.pageToken = pageToken;
    return lQuery;
}

- (GTLQueryYouTube*)queryForVideoListOfPlaylist: (NSString*)playlistId
                                      pageToken: (NSString*)pageToken
{
    GTLQueryYouTube* lQuery = [GTLQueryYouTube queryForPlaylistItemsListWithPart: @"id, snippet"];
    lQuery.maxResults = 20;
    lQuery.playlistId = playlistId;
    lQuery.pageToken = pageToken;
    return lQuery;
}

- (void)channelIdFroChannelSource: (NSString*)channelSrc
                          onCompletion: (void(^)(NSString* channelId))onCompletion
{
    GTLQueryYouTube* lQuery = [GTLQueryYouTube queryForChannelsListWithPart: @"id"];
    lQuery.maxResults = 1;
    lQuery.forUsername = channelSrc;
    [mYTService executeQuery: lQuery
           completionHandler: ^(GTLServiceTicket* ticket, id object, NSError* error)
     {
         GTLYouTubeChannelListResponse* lResult = (GTLYouTubeChannelListResponse*)object;
         if (!lResult.items.count) {
             onCompletion(nil);
             return;
         }
         GTLYouTubeChannel* lChannel = [lResult.items objectAtIndex: 0];
         onCompletion(lChannel.identifier);
     }];
}

- (void)loadAllEventsForFirstPage: (GEServiceEventsLoadedCallbacks)finishCallback
{
    [self loadEventOfType: EFetchEventsLive onCompletion: ^(FetchEventQueryType fetchType)
     {
         [self loadEventOfType: EFetchEventsUpcomming onCompletion: ^(FetchEventQueryType fetchType)
          {
              [self loadEventOfType: EFetchEventsCompleted onCompletion: ^(FetchEventQueryType fetchType)
               {
                   finishCallback(fetchType);
               }];
          }];
     }];
}

- (void)loadEventOfType: (FetchEventQueryType)queryType
           onCompletion: (GEServiceEventsLoadedCallbacks)finishCallback
{
    GEEventManager* lManager = [GEEventManager manager];
    BOOL lCanFetchPage = TRUE;
    NSString* lPageToken = [lManager pageTokenForEventOfType: queryType forSource: kGEChannelID canFetchMore: &lCanFetchPage];
    
    if (!lCanFetchPage)
    {
        finishCallback(queryType);
        return;
    }

    [self channelIdFroChannelSource: kGEChannelID onCompletion: ^(NSString* channelId)
     {
         if (!channelId.length)
         {
             channelId = kGEChannelID;
         }
    
         GTLQueryYouTube* lQuery = [self queryForEventFetchType: queryType channelId: channelId pageToken: lPageToken];
         [mYTService executeQuery: lQuery
                completionHandler: ^(GTLServiceTicket* ticket, id object, NSError* error)
          {
              GTLYouTubeSearchListResponse* lResult = (GTLYouTubeSearchListResponse*)object;
              GTLQueryYouTube* lVideoListQuery = [self queryForVideoListFromSearch: lResult];
              [mYTService executeQuery: lVideoListQuery
                     completionHandler: ^(GTLServiceTicket* ticket, id object, NSError* error)
               {
                   GTLYouTubeVideoListResponse* lResponse = (GTLYouTubeVideoListResponse*)object;
                   lResponse.nextPageToken = lResult.nextPageToken;
                   lResponse.prevPageToken = lResult.prevPageToken;
                   [lManager addEventSearchResponse: lResponse forEventType: queryType forSource: kGEChannelID];
                   finishCallback(queryType);
               }];
          }];
     }];
}

- (void)loadPlaylistFromSource: (NSString*)channelSource
                  onCompletion: (GEServicePlaylistLoadedCallbacks)finishCallback
{
    [self channelIdFroChannelSource: channelSource onCompletion: ^(NSString* channelId)
     {
         if (!channelId.length)
         {
             finishCallback(FALSE);
             return;
         }
         
         GESharedPlaylistList* lSharedPlaylist = [GESharedPlaylistList sharedPlaylistList];
         BOOL lCanFetchPage = TRUE;
         NSString* lPageToken = [lSharedPlaylist pageTokenForPlaylistForSource: channelSource canFetchMore: &lCanFetchPage];
         
         if (!lCanFetchPage)
         {
             finishCallback(FALSE);
             return;
         }
         
         GTLQueryYouTube* lQuery = [self queryForPlaylistListOfChannel: channelId pageToken: lPageToken];
         [mYTService executeQuery: lQuery
                completionHandler: ^(GTLServiceTicket* ticket, id object, NSError* error)
          {
              GTLYouTubePlaylistListResponse* lResult = (GTLYouTubePlaylistListResponse*)object;
              [lSharedPlaylist addplaylistSearchResponse: lResult forSource: channelSource];
              finishCallback(TRUE);
          }];
     }];
}

- (void)loadVideolistFromSource: (NSObject<GEYoutubeResult>*)playlist
                   onCompletion: (GEServiceVideoLoadedFromPlaylistCallbacks)finishCallback
{
    GESharedVideoList* lSharedVideoList = [GESharedVideoList sharedVideoList];
    BOOL lCanFetchPage = TRUE;
    NSString* lIdentifier = [playlist GEId];
    NSString* lPageToken = [lSharedVideoList pageTokenForVideoListForSource: lIdentifier canFetchMore: &lCanFetchPage];
    
    if (!lCanFetchPage)
    {
        finishCallback(FALSE);
        return;
    }
    
    GTLQueryYouTube* lQuery = [self queryForVideoListOfPlaylist: lIdentifier pageToken: lPageToken];
    [mYTService executeQuery: lQuery
           completionHandler: ^(GTLServiceTicket* ticket, id object, NSError* error)
     {
         GTLYouTubePlaylistItemListResponse* lResult = (GTLYouTubePlaylistItemListResponse*)object;
         GTLQueryYouTube* lVideoListQuery = [self queryForVideoListFromPlaylistVideoList: lResult];
         [mYTService executeQuery: lVideoListQuery
                completionHandler: ^(GTLServiceTicket* ticket, id object, NSError* error)
          {
              GTLYouTubeVideoListResponse* lVideoList = (GTLYouTubeVideoListResponse*)object;
              lVideoList.nextPageToken = lResult.nextPageToken;
              lVideoList.prevPageToken = lResult.prevPageToken;
              [lSharedVideoList addVideoListSearchResponse: lVideoList forSource: lIdentifier];
              finishCallback(TRUE);
          }];
     }];
}

- (void)loadVideosFromChannelSource: (NSString*)channelSource
                          eventType: (FetchEventQueryType)eventType
                       onCompletion: (GEServiceVideoLoadedFromChannelCallbacks)finishCallback
{
    [self channelIdFroChannelSource: channelSource onCompletion: ^(NSString* channelId)
     {
         if (!channelId.length)
         {
             channelId = channelSource;
         }
    
         GEEventManager* lManager = [GEEventManager manager];
         BOOL lCanFetchPage = TRUE;
         NSString* lPageToken = [lManager pageTokenForEventOfType: eventType forSource: channelSource canFetchMore: &lCanFetchPage];
         
         if (!lCanFetchPage)
         {
             finishCallback(FALSE);
             return;
         }
         if (eventType == EFetchEventsLiked)
         {
             GTLQueryYouTube* lVideoListQuery = [self queryForMyLikedVideos];
             [mYTService executeQuery: lVideoListQuery
                    completionHandler: ^(GTLServiceTicket* ticket, id object, NSError* error)
              {
                  GTLYouTubeVideoListResponse* lResponse = (GTLYouTubeVideoListResponse*)object;
                  [lManager addEventSearchResponse: lResponse forEventType: eventType forSource: channelSource];
                  finishCallback(eventType);
              }];
         }
         else if (eventType == EFetchEventsReminders)
         {
             GTLQueryYouTube* lVideoListQuery = [self queryForVideoListFromReminders];
             [mYTService executeQuery: lVideoListQuery
                    completionHandler: ^(GTLServiceTicket* ticket, id object, NSError* error)
              {
                  GTLYouTubeVideoListResponse* lResponse = (GTLYouTubeVideoListResponse*)object;
                  [lManager addEventSearchResponse: lResponse forEventType: eventType forSource: channelSource];
                  finishCallback(eventType);
              }];
         }
         else
         {
             GTLQueryYouTube* lQuery = [self queryForEventFetchType: eventType channelId: channelId pageToken: lPageToken];
             [mYTService executeQuery: lQuery
                    completionHandler: ^(GTLServiceTicket* ticket, id object, NSError* error)
              {
                  GTLYouTubeSearchListResponse* lResult = (GTLYouTubeSearchListResponse*)object;
                  GTLQueryYouTube* lVideoListQuery = [self queryForVideoListFromSearch: lResult];
                  [mYTService executeQuery: lVideoListQuery
                         completionHandler: ^(GTLServiceTicket* ticket, id object, NSError* error)
                   {
                       GTLYouTubeVideoListResponse* lResponse = (GTLYouTubeVideoListResponse*)object;
                       lResponse.nextPageToken = lResult.nextPageToken;
                       lResponse.prevPageToken = lResult.prevPageToken;
                       
                       [lManager addEventSearchResponse: lResponse forEventType: eventType forSource: channelSource];
                       finishCallback(eventType);
                   }];
              }];
         }
     }];
}

@end
