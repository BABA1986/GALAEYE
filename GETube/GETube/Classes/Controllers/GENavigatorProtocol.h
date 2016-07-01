//
//  GENavigatorProtocol.h
//  GETube
//
//  Created by Deepak on 01/07/16.
//  Copyright © 2016 Deepak. All rights reserved.
//

#ifndef GENavigatorProtocol_h
#define GENavigatorProtocol_h

@protocol GENavigatorProtocol <NSObject>

- (void)moveToViewController: (id)toViewController fromViewCtr: (id)fromViewCtr;

@end

#endif /* GENavigatorProtocol_h */
