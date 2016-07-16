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
#import "GEConstants.h"

@interface GEServiceManager ()
- (void)initialiseYTService;
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

- (GTLQueryYouTube*)queryForEventFetchType: (FetchEventQueryType)eventType
                                 channelId: (NSString*)channelId
                                 pageToken: (NSString*)pageToken
{
    GTLQueryYouTube* lQuery = [GTLQueryYouTube queryForSearchListWithPart: @"id,snippet"];
    lQuery.maxResults = 20;
    lQuery.type = @"video";
    lQuery.channelId = channelId;
    if (eventType == EFetchEventsLive)
        lQuery.eventType = kGTLYouTubeEventTypeLive;
    else if (eventType == EFetchEventsUpcomming)
        lQuery.eventType = kGTLYouTubeEventTypeUpcoming;
    else if (eventType == EFetchEventsCompleted)
        lQuery.eventType = kGTLYouTubeEventTypeCompleted;
    
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
    GTLQueryYouTube* lQuery = [GTLQueryYouTube queryForPlaylistItemsListWithPart: @"id,snippet,contentDetails"];
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
    NSString* lPageToken = [lManager pageTokenForEventOfType: queryType canFetchMore: &lCanFetchPage];
    
    if (!lCanFetchPage)
        finishCallback(queryType);

    [self channelIdFroChannelSource: kGEChannelID onCompletion: ^(NSString* channelId)
     {
         if (!channelId.length)
         {
             finishCallback(queryType);
             return;
         }
         
         GTLQueryYouTube* lQuery = [self queryForEventFetchType: queryType channelId: channelId pageToken: lPageToken];
         [mYTService executeQuery: lQuery
                completionHandler: ^(GTLServiceTicket* ticket, id object, NSError* error)
          {
              GTLYouTubeSearchListResponse* lResult = (GTLYouTubeSearchListResponse*)object;
              [lManager addEventSearchResponse: lResult forEventType: queryType];
              finishCallback(queryType);
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
             finishCallback(FALSE);
         
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

- (void)loadVideolistFromSource: (GTLYouTubePlaylist*)playlist
                   onCompletion: (GEServiceVideoLoadedFromPlaylistCallbacks)finishCallback
{
    GESharedVideoList* lSharedVideoList = [GESharedVideoList sharedVideoList];
    BOOL lCanFetchPage = TRUE;
    NSString* lPageToken = [lSharedVideoList pageTokenForVideoListForSource: playlist.identifier canFetchMore: &lCanFetchPage];
    
    if (!lCanFetchPage)
        finishCallback(FALSE);
    GTLQueryYouTube* lQuery = [self queryForVideoListOfPlaylist: playlist.identifier pageToken: lPageToken];
    [mYTService executeQuery: lQuery
           completionHandler: ^(GTLServiceTicket* ticket, id object, NSError* error)
     {
         GTLYouTubeVideoListResponse* lResult = (GTLYouTubeVideoListResponse*)object;
         [lSharedVideoList addVideoListSearchResponse: lResult forSource: playlist.identifier];
         finishCallback(TRUE);
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
             finishCallback(FALSE);
             return;
         }
         
         GEEventManager* lManager = [GEEventManager manager];
         BOOL lCanFetchPage = TRUE;
         NSString* lPageToken = [lManager pageTokenForEventOfType: eventType canFetchMore: &lCanFetchPage];
         
         if (!lCanFetchPage)
             finishCallback(FALSE);
         
         GTLQueryYouTube* lQuery = [self queryForEventFetchType: eventType channelId: channelId pageToken: lPageToken];
         [mYTService executeQuery: lQuery
                completionHandler: ^(GTLServiceTicket* ticket, id object, NSError* error)
          {
              GTLYouTubeSearchListResponse* lResult = (GTLYouTubeSearchListResponse*)object;
              [lManager addEventSearchResponse: lResult forEventType: eventType];
              finishCallback(TRUE);
          }];
     }];
}

@end
