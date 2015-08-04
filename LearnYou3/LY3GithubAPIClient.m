//
//  LY3GithubAPIClient.m
//  LearnYou3
//
//  Created by Amitai Blickstein on 8/2/15.
//  Copyright (c) 2015 Amitai Blickstein, LLC. All rights reserved.
//
/**
 *  sorry for the LY2 and LY3 confusion. We'll have to refactor this...
 */
#import "LY3GithubAPIClient.h"
#import "LY2Constants.h"
#import <Regexer.h>
#import <AFNetworking.h>
#import <AFOAuth2Manager/AFOAuth2Manager.h>
#import <AFOAuth2Manager/AFHTTPRequestSerializer+OAuth2.h>

@implementation LY3GithubAPIClient
NSString *const GITHUB_API_baseURL = @"https://api.github.com";

+ (NSDictionary*)defaultParams
{
    static NSDictionary *params;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
    params = @{@"client_id"    : GITHUB_CLIENT_ID,
               @"client_secret" : GITHIB_CLIENT_SECRET,
               @"per_page"   : @"100"};
    });
    return params;
}

+(NSDictionary *)defaultParamsWithPage:(NSInteger)pageRequested
{
    NSMutableDictionary *defaultsWithPage = [[LY3GithubAPIClient defaultParams] mutableCopy];
    [defaultsWithPage setObject:@(pageRequested) forKey:@"page"];
    return [defaultsWithPage copy];
}

+(void)getCurrentUserRepositoriesWithCompletion:(void (^)(NSURLSessionDataTask *, NSArray *))completionBlock {
    NSString *getCurrentUserReposURL = [NSString stringWithFormat:@"%@/user/repos", GITHUB_API_baseURL];
    
        //    AFOAuth2Manager *authManager = [AFOAuth2Manager alloc] initWithBaseURL:<#(NSURL *)#> clientID:<#(NSString *)#> secret:<#(NSString *)#>
    
//    NSDictionary *params = @{@"client_id" : GITHUB_CLIENT_ID,
//                             @"client_secret" : GITHIB_CLIENT_SECRET,
//                             @"per_page" : @"100"};
//    
    AFOAuthCredential *sessionToken = [AFOAuthCredential retrieveCredentialWithIdentifier:@"githubOAuthToken"];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setAuthorizationHeaderFieldWithCredential:sessionToken];
    
    void (^GETwithPage)(NSUInteger) = ^void(NSUInteger pagination) {
        
        
        
        [manager GET:getCurrentUserReposURL parameters:[self defaultParams]
             success:^(NSURLSessionDataTask *task, id responseObject) {
                    completionBlock(task, responseObject);
             } failure:^(NSURLSessionDataTask *task, NSError *error) {
                    NSLog(@"Fail line 44: %@", error.localizedDescription);
        }];
    };
}

+(void)getMembershipforOrg:(NSString *)orgName WithCompletion:(void (^)(NSURLSessionDataTask *, NSArray *))completionBlock {
    NSString *getOrgMembershipURL = [NSString stringWithFormat:@"%@/orgs/%@/members?", GITHUB_API_baseURL, orgName];
    NSDictionary *params = @{@"client_id"       : GITHUB_CLIENT_ID,
                             @"client_secret"   : GITHIB_CLIENT_SECRET,
                             @"per_page"        : @"100",
                             @"role"            : @"all"};
    
    AFOAuthCredential *sessionToken = [AFOAuthCredential retrieveCredentialWithIdentifier:@"githubOAuthToken"];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    [manager.requestSerializer setAuthorizationHeaderFieldWithCredential:sessionToken];
    
        //Get the org's repos, and pass the info on to the completion block.
    [manager GET:getOrgMembershipURL
      parameters:params
         success:^(NSURLSessionDataTask *task, id responseObject) {
             completionBlock(task, responseObject);
         } failure:^(NSURLSessionDataTask *task, NSError *error) {
             NSLog(@"Fail line 67: %@", error.localizedDescription);
         }];
}

+(void)getRepositoriesforOrg:(NSString *)orgName WithCompletion:(void (^)(NSURLSessionDataTask *, NSArray *))completionBlock {
    NSString *getOrgReposURL = [NSString stringWithFormat:@"%@/orgs/%@/repos?", GITHUB_API_baseURL, orgName];
    NSDictionary *params = @{@"client_id"       : GITHUB_CLIENT_ID,
                             @"client_secret"   : GITHIB_CLIENT_SECRET,
                             @"per_page"        : @"100"};
    
    AFOAuthCredential *sessionToken = [AFOAuthCredential retrieveCredentialWithIdentifier:@"githubOAuthToken"];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    [manager.requestSerializer setAuthorizationHeaderFieldWithCredential:sessionToken];
    
        //Get the org's repos, and pass the info on to the completion block.
    [manager GET:getOrgReposURL
      parameters:params
         success:^(NSURLSessionDataTask *task, id responseObject) {
             completionBlock(task, responseObject);
         } failure:^(NSURLSessionDataTask *task, NSError *error) {
             NSLog(@"Fail line 89: %@", error.localizedDescription);
         }];
}

+(void)getRepositoriesforUser:(NSString *)userName WithCompletion:(void (^)(NSURLSessionDataTask *, NSArray *))completionBlock {
    NSString *getUserReposURL = [NSString stringWithFormat:@"%@/users/%@/repos?", GITHUB_API_baseURL, userName];
    NSDictionary *params = @{@"client_id"       : GITHUB_CLIENT_ID,
                             @"client_secret"   : GITHIB_CLIENT_SECRET,
                             @"per_page"        : @"100"};
    
    AFOAuthCredential *sessionToken = [AFOAuthCredential retrieveCredentialWithIdentifier:@"githubOAuthToken"];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    [manager.requestSerializer setAuthorizationHeaderFieldWithCredential:sessionToken];
    
        //Get the org's repos, and pass the info on to the completion block.
    [manager GET:getUserReposURL
      parameters:params
         success:^(NSURLSessionDataTask *task, id responseObject) {
             completionBlock(task, responseObject);
         } failure:^(NSURLSessionDataTask *task, NSError *error) {
             NSLog(@"Fail line 111: %@", error.localizedDescription);
         }];
}


+(void)getRepositoriesForkedFromParentRepo:(NSString *)repoFullName WithCompletion:(void (^)(NSURLSessionDataTask *, NSArray *))completionBlock {
    NSString *getRepoForksURL = [NSString stringWithFormat:@"%@/repos/%@/forks", GITHUB_API_baseURL, repoFullName]; //Fullname = owner|org : repoName, e.g., "octocat/helloWorld"
    NSDictionary *params = @{@"client_id"       : GITHUB_CLIENT_ID,
                             @"client_secret"   : GITHIB_CLIENT_SECRET,
                             @"per_page"        : @"100"};
    
    AFOAuthCredential *sessionToken = [AFOAuthCredential retrieveCredentialWithIdentifier:@"githubOAuthToken"];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    [manager.requestSerializer setAuthorizationHeaderFieldWithCredential:sessionToken];
    
        //Get the org's repos, and pass the info on to the completion block.
    [manager GET:getRepoForksURL
      parameters:params
         success:^(NSURLSessionDataTask *task, id responseObject) {
             completionBlock(task, responseObject);
         } failure:^(NSURLSessionDataTask *task, NSError *error) {
             NSLog(@"Fail line 134: %@", error.localizedDescription);
         }];
}

-(NSUInteger)paginationFromResponseHeader:(NSHTTPURLResponse*)response {
    NSLog(@"NSURLResponse digging: %@", [[response allHeaderFields] description]);
    NSString *linkHeaderText = response.allHeaderFields[@"Link"];
    NSLog(@"link header tedxt: %@", linkHeaderText);
    NSString *rxPattern = @"\\d+(?=>; rel=\"last\")";
    NSString *paginationString = [linkHeaderText rx_textsForMatchesWithPattern:rxPattern][0];
    NSLog(@"pagination string: %@", paginationString);
    
    return [paginationString integerValue];
}

@end
