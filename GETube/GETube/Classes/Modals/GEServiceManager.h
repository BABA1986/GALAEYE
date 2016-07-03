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

typedef void (^GEServiceEventsLoadedCallbacks)(FetchEventQueryType fetchType);
typedef void (^GEServicePlaylistLoadedCallbacks)(BOOL success);


@interface GEServiceManager : NSObject
{
    GTLServiceYouTube*          mYTService;
}

+ (id)sharedManager;

- (void)loadAllEventsForFirstPage: (GEServiceEventsLoadedCallbacks)finishCallback;
- (void)loadEventOfType: (FetchEventQueryType)queryType
           onCompletion: (GEServiceEventsLoadedCallbacks)finishCallback;

- (void)loadPlaylistFromSource: (NSString*)channelSource
                  onCompletion: (GEServicePlaylistLoadedCallbacks)finishCallback;

- (void)loadVideolistFromSource: (GTLYouTubePlaylist*)playlist
                   onCompletion: (GEServicePlaylistLoadedCallbacks)finishCallback;

@end
