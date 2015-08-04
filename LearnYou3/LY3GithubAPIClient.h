//
//  LY3GithubAPIClient.h
//  LearnYou3
//
//  Created by Amitai Blickstein on 8/2/15.
//  Copyright (c) 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LY3GithubAPIClient : NSObject

+(NSDictionary*)defaultParams;
+(NSDictionary*)defaultParamsWithPage:(NSInteger)pageRequested;

+(void)getCurrentUserRepositoriesWithCompletion:(void (^)(NSURLSessionDataTask *task, NSArray *repos))completionBlock;
+(void)getRepositoriesforUser:(NSString*)userName WithCompletion:(void (^)(NSURLSessionDataTask *task, NSArray *repos))completionBlock;
+(void)getMembershipforOrg:(NSString*)orgName WithCompletion:(void (^)(NSURLSessionDataTask *task, NSArray *repos))completionBlock;
+(void)getRepositoriesforOrg:(NSString*)orgName WithCompletion:(void (^)(NSURLSessionDataTask *task, NSArray *repos))completionBlock;
+(void)getRepositoriesForkedFromParentRepo:(NSString *)repoFullName WithCompletion:(void (^)(NSURLSessionDataTask *task, NSArray *repos))completionBlock;


@end
