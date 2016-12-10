//
//  SharedReminder.h
//  GETube
//
//  Created by Deepak on 07/11/16.
//  Copyright © 2016 Deepak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GEYoutubeResult.h"

@interface SharedReminder : NSObject

+ (id)SharedRemider;

- (NSArray*)remiderVideoIds;
- (void)addReminderVideo: (NSObject<GEYoutubeResult>*)videoItem;
- (void)deleteReminderVideo: (NSObject<GEYoutubeResult>*)videoItem;
- (BOOL)isInReminderList: (NSObject<GEYoutubeResult>*)videoItem;

@end
