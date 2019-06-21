//
//  NSObject+Objective_CBridgingHeader.h
//  ChatAppClients
//
//  Created by Dushko Cizaloski on 5/21/19.
//  Copyright © 2019 Big Nerd Ranch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChatAppClients-Bridging-Header.h"

//#import "ChatLogController.swift"
NS_ASSUME_NONNULL_BEGIN

@interface ScrollView: UIViewController  //NSObject (Objective_CBridgingHeader)
@property (nonatomic, weak) IBOutlet UIScrollView * scrollVIew;
@property (nonatomic, strong) UIRefreshControl *topRefreshController;
@end

NS_ASSUME_NONNULL_END
