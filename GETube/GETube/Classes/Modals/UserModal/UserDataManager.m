//
//  UserDataManager.m
//  GETube
//
//  Created by Deepak on 18/08/16.
//  Copyright © 2016 Deepak. All rights reserved.
//

#import "UserDataManager.h"

@implementation GEUserData

@synthesize userId;
@synthesize email;
@synthesize name;
@synthesize imageUrl;
@synthesize clientId;
@synthesize accessToken;
@synthesize accessTokenExpDate;
@synthesize idToken;
@synthesize idTokenExpDate;

- (NSDictionary*)userDataDict
{
    NSMutableDictionary* lDict = [[NSMutableDictionary alloc] init];
    
    NSString* lUserId = !self.userId.length ? @"" : self.userId;
    NSString* lEmail = !self.email.length ? @"" : self.email;
    NSString* lName = !self.name.length ? @"" : self.name;
    NSString* lImageUrl = !self.imageUrl ? @"" : [self.imageUrl absoluteString];
    NSString* lClientId = !self.clientId? @"" : self.clientId;
    NSString* lAccessToken = !self.accessToken? @"" : self.accessToken;
    NSDate* lAccessTokenExpDate = !self.accessTokenExpDate? [NSDate date] : self.accessTokenExpDate;
    NSString* lIdToken = !self.idToken.length ? @"" : self.idToken;
    NSDate* lIdTokenExpDate = !self.idTokenExpDate? [NSDate date] : self.idTokenExpDate;
    
    [lDict setObject: lUserId forKey: @"userId"];
    [lDict setObject: lEmail forKey: @"email"];
    [lDict setObject: lName forKey: @"name"];
    [lDict setObject: lImageUrl forKey: @"imageUrl"];
    [lDict setObject: lClientId forKey: @"clientId"];
    [lDict setObject: lAccessToken forKey: @"accessToken"];
    [lDict setObject: lAccessTokenExpDate.description forKey: @"accessTokenExpDate"];
    [lDict setObject: lIdToken forKey: @"idToken"];
    [lDict setObject: lIdTokenExpDate.description forKey: @"idTokenExpDate"];
    
    return lDict;
}

@end


@interface UserDataManager()
- (void)initUserData;
- (void)initUserPlist;
- (void)saveState;
@end

@implementation UserDataManager

@synthesize userData = mGEUserData;

+ (id)userDataManager
{
    static dispatch_once_t once;
    static UserDataManager* sUserDataManager = nil;
    dispatch_once(&once, ^
                  {
                      sUserDataManager = [[self alloc] init];
                      [sUserDataManager initUserData];
                  });
    
    return sUserDataManager;
}

- (void)initUserData
{
    mGEUserData = [[GEUserData alloc] init];
}

- (void)flushUserData
{
    [self setUserId: nil];
    [self setEmail: nil];
    [self setName: nil];
    [self setImageUrl: nil];
    [self setClientId: nil];
    [self setAccessToken: nil];
    [self setAccessTokenExpDate: nil];
    [self setIdToken: nil];
    [self setIdTokenExpDate: nil];
    [self setRefreshToken: nil];
}

-(void)initUserPlist
{
    NSFileManager* lManager = [NSFileManager defaultManager];
    NSString *lDirPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
    
    BOOL lIsDirectory = FALSE;
    if(![lManager fileExistsAtPath: lDirPath isDirectory: &lIsDirectory])
    {
        assert(TRUE);
        return;
    }
    
    NSString* lAppUserData = [lDirPath stringByAppendingPathComponent: @"userData"];
    
    if(![lManager fileExistsAtPath: lAppUserData isDirectory: &lIsDirectory])
    {
        NSError* lError = nil;
        [lManager createDirectoryAtPath: lAppUserData withIntermediateDirectories: NO attributes: NULL error: &lError];
        if(lError)
        {
            assert(!lError);
            return;
        }
    }
    
    if ([lManager fileExistsAtPath: lAppUserData isDirectory: &lIsDirectory])
    {
        NSString *lPlistFilePath = [lAppUserData stringByAppendingPathComponent:@"userData.plist"];
        
        if (![lManager fileExistsAtPath: lPlistFilePath isDirectory: &lIsDirectory])
        {
            NSDictionary* lDict = [mGEUserData userDataDict];
            [lDict writeToFile: lPlistFilePath atomically: true];
        }
    }
}

- (void)saveState
{
    NSDictionary* lDict = [mGEUserData userDataDict];
    NSString *lLibDirPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
    NSString* lDirPath = [lLibDirPath stringByAppendingPathComponent: @"userData"];
    NSString *lPlistFilePath=[lDirPath stringByAppendingPathComponent:@"userData.plist"];
    
    NSFileManager* lManager = [NSFileManager defaultManager];
    if (![lManager fileExistsAtPath: lPlistFilePath])
        [self initUserPlist];
    
    [lDict writeToFile: lPlistFilePath atomically: true];
}

- (void)setUserId: (NSString*)userId
{
    mGEUserData.userId = userId;
    [self saveState];
}

- (void)setEmail: (NSString*)email
{
    mGEUserData.email = email;
    [self saveState];
}

- (void)setName: (NSString*)name
{
    mGEUserData.name = name;
    [self saveState];
}

- (void)setImageUrl: (NSURL*)imageUrl
{
    mGEUserData.imageUrl = imageUrl;
    [self saveState];
}

- (void)setClientId: (NSString*)clientId
{
    mGEUserData.clientId = clientId;
    [self saveState];
}

- (void)setAccessToken: (NSString*)accessToken
{
    mGEUserData.accessToken = accessToken;
    [self saveState];
}

- (void)setAccessTokenExpDate: (NSDate*)accessTokenExpDate
{
    mGEUserData.accessTokenExpDate = accessTokenExpDate;
    [self saveState];
}

- (void)setIdToken: (NSString*)idToken
{
    mGEUserData.idToken = idToken;
    [self saveState];
}

- (void)setIdTokenExpDate: (NSDate*)idTokenExpDate
{
    mGEUserData.idTokenExpDate = idTokenExpDate;
    [self saveState];
}

- (void)setRefreshToken: (NSString*)refreshToken
{
    mGEUserData.refreshToken = refreshToken;
    [self saveState];
}

@end
