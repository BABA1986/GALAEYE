//
//  SharedReminder.m
//  GETube
//
//  Created by Deepak on 07/11/16.
//  Copyright © 2016 Deepak. All rights reserved.
//

#import "SharedReminder.h"
#import <UIKit/UIKit.h>

@import EventKit;
@interface SharedReminder()
{
    NSMutableArray*         mReminders;
    
    EKEventStore*           mEventStore;
    EKCalendar*             mCalender;
}

@property(nonatomic, strong)EKEventStore*   eventStore;
@property(nonatomic, strong)EKCalendar*     calender;
@property (nonatomic)BOOL                   isAccessToEventStoreGranted;

- (void)initReminders;
- (void)saveReminders;

@end

@implementation SharedReminder

@synthesize eventStore = mEventStore;
@synthesize calender = mCalender;

+ (id)SharedRemider
{
    static dispatch_once_t once;
    static SharedReminder* sSharedReminder = nil;
    dispatch_once(&once, ^
                  {
                      sSharedReminder = [[self alloc] init];
                      [sSharedReminder initReminders];
                  });
    
    return sSharedReminder;
}

- (EKEventStore *)eventStore {
    if (!mEventStore) {
        mEventStore = [[EKEventStore alloc] init];
    }
    return mEventStore;
}

- (EKCalendar *)calendar {
    if (!mCalender) {
        
        // 1
        NSArray *calendars = [self.eventStore calendarsForEntityType:EKEntityTypeReminder];
        
        // 2
        NSString *calendarTitle = @"GalaTube";
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title matches %@", calendarTitle];
        NSArray *filtered = [calendars filteredArrayUsingPredicate:predicate];
        
        if ([filtered count]) {
            mCalender = [filtered firstObject];
        } else {
            
            // 3
            mCalender = [EKCalendar calendarForEntityType:EKEntityTypeReminder eventStore:self.eventStore];
            mCalender.title = @"GalaTube";
            mCalender.source = self.eventStore.defaultCalendarForNewReminders.source;
            
            // 4
            NSError *calendarErr = nil;
            BOOL calendarSuccess = [mEventStore saveCalendar:mCalender commit:YES error:&calendarErr];
            if (!calendarSuccess) {
                // Handle error
            }
        }
    }
    return mCalender;
}

- (void)updateAuthorizationStatusToAccessEventStore {
    // 2
    EKAuthorizationStatus authorizationStatus = [EKEventStore authorizationStatusForEntityType:EKEntityTypeReminder];
    
    switch (authorizationStatus) {
            // 3
        case EKAuthorizationStatusDenied:
        case EKAuthorizationStatusRestricted: {
            self.isAccessToEventStoreGranted = NO;
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Access Denied"
                                                                message:@"This app doesn't have access to your Reminders." delegate:nil
                                                      cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
            [alertView show];
            break;
        }
            
            // 4
        case EKAuthorizationStatusAuthorized:
            self.isAccessToEventStoreGranted = YES;
            break;
            
            // 5
        case EKAuthorizationStatusNotDetermined: {
            [self.eventStore requestAccessToEntityType:EKEntityTypeReminder
                                            completion:^(BOOL granted, NSError *error) {
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    self.isAccessToEventStoreGranted = granted;
                                                });
                                            }];
            break;
        }
    }
}

- (NSDateComponents *)dateComponentsForDate: (NSDate*)date
{
    NSUInteger unitFlags = NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSCalendar * cal = [NSCalendar currentCalendar];
    NSDateComponents *comps = [cal components:unitFlags fromDate:date];
    return comps;
}

- (void)initReminders
{
    [self updateAuthorizationStatusToAccessEventStore];
    NSString *lDirPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString* lRemindersDirPath = [lDirPath stringByAppendingPathComponent: @"Reminders"];
    NSFileManager* lManager = [NSFileManager defaultManager];
    BOOL lIsDirectory = FALSE;
    if(![lManager fileExistsAtPath: lRemindersDirPath isDirectory: &lIsDirectory])
    {
        NSError* lError = nil;
        [lManager createDirectoryAtPath: lRemindersDirPath withIntermediateDirectories: NO attributes: NULL error: &lError];
        if(lError)
        {
            NSLog(@"AppSetting Directory is Not Created");
            assert(!lError);
            return;
        }
    }

    NSString* lPlistFilePath = [lRemindersDirPath stringByAppendingPathComponent:@"Reminders.plist"];
    NSDictionary* lDict = [[NSDictionary alloc] initWithContentsOfFile:lPlistFilePath];
    
    NSMutableArray* lReminders = [lDict objectForKey: @"Reminders"];
    mReminders = [[NSMutableArray alloc] initWithArray: lReminders];
}

- (void)saveReminders
{
    NSDictionary* lReminderDict = [NSDictionary dictionaryWithObject: mReminders forKey: @"Reminders"];
    NSData *lData = [NSPropertyListSerialization dataWithPropertyList:lReminderDict
                                                               format:NSPropertyListBinaryFormat_v1_0
                                                              options:0
                                                                error:NULL];
    
    NSString *lDirPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
    NSString* lAppSettingDirPath = [lDirPath stringByAppendingPathComponent: @"Reminders"];
    NSString *lPlistFilePath=[lAppSettingDirPath stringByAppendingPathComponent:@"Reminders.plist"];
    
    NSFileManager* lManager = [NSFileManager defaultManager];
    if (![lManager fileExistsAtPath: lPlistFilePath]) {
        [lManager createFileAtPath:lPlistFilePath contents:lData attributes:NULL];
    }
    
    [lData writeToFile: lPlistFilePath atomically: TRUE];
}

- (NSArray*)remiderVideoIds
{
    NSMutableArray* lVideos = [[NSMutableArray alloc] init];
    for (NSMutableDictionary* lItem in mReminders)
    {
        NSString* lVideoID = [lItem objectForKey: @"VideoID"];
        [lVideos addObject: lVideoID];
    }
    
    return lVideos;
}

- (void)addReminderVideo: (NSObject<GEYoutubeResult>*)videoItem
{
    NSMutableDictionary* lDict = [[NSMutableDictionary alloc] init];
    [lDict setObject: videoItem.GEId forKey: @"VideoID"];
    [lDict setObject: videoItem.GETitle forKey: @"VideoTitle"];
    [lDict setObject: videoItem.eventStartStreamDate forKey: @"UpcommingDate"];
    
    [mReminders addObject: lDict];
    [self saveReminders];
    
    if (!self.isAccessToEventStoreGranted)
        return;
    
    // 2
    EKReminder *reminder = [EKReminder reminderWithEventStore:self.eventStore];
    reminder.title = videoItem.GETitle;
    reminder.calendar = self.calendar;
    reminder.dueDateComponents = [self dateComponentsForDate: videoItem.eventStartStreamDate];
    
    // 3
    NSError *error = nil;
    BOOL success = [self.eventStore saveReminder:reminder commit:YES error:&error];
    if (!success) {
        // Handle error.
    }
}

- (void)deleteReminderVideo: (NSObject<GEYoutubeResult>*)videoItem
{
    NSMutableDictionary* lItem = nil;
    
    for (lItem in mReminders)
    {
        NSString* lVideoID = [lItem objectForKey: @"VideoID"];
        if ([lVideoID compare: videoItem.GEId options: NSCaseInsensitiveSearch] == NSOrderedSame)
        {
            break;
        }
    }
    if (lItem)
        [mReminders removeObject: lItem];
    
    [self saveReminders];
    

    if (self.isAccessToEventStoreGranted) {
        // 1
        NSPredicate *predicate =
        [self.eventStore predicateForRemindersInCalendars:@[self.calendar]];
        
        // 2
        [self.eventStore fetchRemindersMatchingPredicate:predicate completion:^(NSArray *reminders) {
            // 3
            for (EKReminder* lReminder in reminders)
            {
                if ([lReminder.title compare: videoItem.GETitle options: NSCaseInsensitiveSearch] == NSOrderedSame) {
                    NSError *error = nil;
                    BOOL success = [self.eventStore removeReminder:lReminder commit:NO error:&error];
                    if (!success) {
                        // Handle delete error
                    }
                }
            }
                 // 4
            NSError *commitErr = nil;
            BOOL success = [self.eventStore commit:&commitErr];
            if (!success) {
                // Handle commit error.
            }
        }];
    }
}

- (BOOL)isInReminderList: (NSObject<GEYoutubeResult>*)videoItem
{
    BOOL lRetVal = FALSE;
    NSMutableDictionary* lItem = nil;
    
    for (lItem in mReminders)
    {
        NSString* lVideoID = [lItem objectForKey: @"VideoID"];
        if ([lVideoID compare: videoItem.GEId options: NSCaseInsensitiveSearch] == NSOrderedSame)
        {
            lRetVal = TRUE;
            break;
        }
    }

    return lRetVal;
}


@end
