//
//  UserDataManager.h
//  GETube
//
//  Created by Deepak on 18/08/16.
//  Copyright © 2016 Deepak. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GEUserData  : NSObject
@property(nonatomic, copy)NSString*         userId;
@property(nonatomic, copy)NSString*         email;
@property(nonatomic, copy)NSString*         name;
@property(nonatomic, strong)NSURL*          imageUrl;
@property(nonatomic, copy)NSString*         clientId;
@property(nonatomic, copy)NSString*         accessToken;
@property(nonatomic, strong)NSDate*         accessTokenExpDate;
@property(nonatomic, copy)NSString*         idToken;
@property(nonatomic, strong)NSDate*         idTokenExpDate;
@property(nonatomic, copy)NSString*         refreshToken;
@end

@interface UserDataManager : NSObject
{
    GEUserData*             mGEUserData;
}

@property(nonatomic, readonly)GEUserData*       userData;

+ (UserDataManager*)userDataManager;
- (void)flushUserData;

- (void)setUserId: (NSString*)userId;
- (void)setEmail: (NSString*)email;
- (void)setName: (NSString*)name;
- (void)setImageUrl: (NSURL*)imageUrl;
- (void)setClientId: (NSString*)clientId;
- (void)setAccessToken: (NSString*)accessToken;
- (void)setAccessTokenExpDate: (NSDate*)accessTokenExpDate;
- (void)setIdToken: (NSString*)idToken;
- (void)setIdTokenExpDate: (NSDate*)idTokenExpDate;
- (void)setRefreshToken: (NSString*)refreshToken;

@end
