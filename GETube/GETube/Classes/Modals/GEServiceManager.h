//
//  GEServiceManager.h
//  GETube
//
//  Created by Deepak on 19/06/16.
//  Copyright © 2016 Deepak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GEConstants.h"
#import "GEEventManager.h"
#import "GEYoutubeResult.h"

typedef void (^GEServiceEventsLoadedCallbacks)(FetchEventQueryType fetchType);
typedef void (^GEServicePlaylistLoadedCallbacks)(BOOL success);
typedef void (^GEServiceVideoLoadedFromPlaylistCallbacks)(BOOL success);
typedef void (^GEServiceVideoLoadedFromChannelCallbacks)(BOOL success);


@interface GEServiceManager : NSObject
{
    GTLServiceYouTube*          mYTService;
}

+ (id)sharedManager;

- (void)loadAllEventsForFirstPage: (GEServiceEventsLoadedCallbacks)finishCallback;

- (void)loadPlaylistFromSource: (NSString*)channelSource
                  onCompletion: (GEServicePlaylistLoadedCallbacks)finishCallback;

- (void)loadVideolistFromSource: (NSObject<GEYoutubeResult>*)playlist
                   onCompletion: (GEServiceVideoLoadedFromPlaylistCallbacks)finishCallback;

- (void)loadVideosFromChannelSource: (NSString*)channelSource
                          eventType: (FetchEventQueryType)eventType
                       onCompletion: (GEServiceVideoLoadedFromChannelCallbacks)finishCallback;

@end
