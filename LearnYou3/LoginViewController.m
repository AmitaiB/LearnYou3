//
//  CPYLoginViewController.m
//  LearnYou3
//
//  Created by Amitai Blickstein on 7/30/15.
//  Copyright (c) 2015 Amitai Blickstein, LLC. All rights reserved.
//
#define ARC4RANDOM_MAX 0x100000000

#import "LoginViewController.h"
#import <AFNetworking.h>
#import <AFOAuth2Manager/AFOAuth2Manager.h>
#import <AFOAuth2Manager/AFHTTPRequestSerializer+OAuth2.h>
#import "LY2Constants.h"
#import <GitHubOAuthController.h>
#import "LY3RandomOctocatAPIClient.h"
#import <Parse.h>
#import <DLIL.h>
#import <DLILOperation.h>
#import <DLILCacheManager.h>
#import <UIProgressView+AFNetworking.h>

@interface LoginViewController ()
- (IBAction)githubButtonWasTapped:(id)sender;
- (IBAction)invisibleButtonTapped:(id)sender;
@property (nonatomic, strong) NSMutableArray *octocatURLsArray;
@property (weak, nonatomic) IBOutlet DLImageView *octocatDLImageView;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"viewDidLoad...");
        //Just a little demonstration code to show what the DLIL cocoapod cleaned up:
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(50, 50, 100, 100)];
//    imageView.image = [UIImage imageWithCIImage:[CIImage imageWithContentsOfURL:[NSURL URLWithString:@"https://www.google.com/images/srpr/logo11w.png"]]];
//    [self.view addSubview:imageView];
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"viewWillAppear...");
    
    if ([AFOAuthCredential retrieveCredentialWithIdentifier:@"githubOAuthToken"]) {
        NSLog(@"In if statement of retrieveCredential");
            [self performSegueWithIdentifier:@"logInToMasterSegueID" sender:nil];
    }
    
        //Notify this instance of the view controller and call method.
        //...Why??
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationOpenedForURL:) name:@"ApplicationOpenedForURL" object:nil];
}
    //More NSNotificationCenter stuff...
-(NSString *)firstValueForQueryItemNamed:(NSString *)name inURL:(NSURL *)url {
    
    NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:nil];
    NSArray *queryItems = urlComponents.queryItems;
    
        //Amitai added this so he could learn about what was going on...
    NSLog(@"queryItems is:\n%@", [queryItems description]);
    
    for (NSURLQueryItem *queryItem in queryItems) {
        if ([queryItem.name isEqualToString:name]) {
            return queryItem.value;
        }
    }
    return nil;
}

    //And yet more NSNotificationCenter stuff...
-(void)handleApplicationOpenedForURL:(NSNotification *)notification
{
    
    NSURL *url = notification.userInfo[@"url"];
    
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"ApplicationOpenedForURL" object:nil userInfo:@{@"url":url}];
    NSString *code = [self firstValueForQueryItemNamed:@"code" inURL:url];
    NSLog(@"Opened from URL %@", url);
}

    ///AFOAuth2Manager stores passwords etc. in the Keychain.
- (IBAction)githubButtonWasTapped:(id)sender {
//    AFOAuth2Manager *oAuthManager = [self githubOAuth2ManagerCreate];
    
    GitHubOAuthController *oAuthController = [[GitHubOAuthController alloc] initWithClientId:GITHUB_CLIENT_ID clientSecret:GITHIB_CLIENT_SECRET scope:@"repo" success:^(NSString *accessToken, NSDictionary *raw) {
                NSLog(@"access token: %@ \nraw: %@", accessToken, raw);
                AFOAuthCredential *credential = [AFOAuthCredential credentialWithOAuthToken:raw[@"access_token"] tokenType:raw[@"token_type"]];
                [AFOAuthCredential storeCredential:credential withIdentifier:@"githubOAuthToken"];
    } failure:nil];

    [oAuthController showModalFromController:self];
}
/**
 *  Using Parse as a Backend Persistent Data Store, the array is queried
 *  -- returning a URL (as NSString) for a random octocat image from the 'octodex' (Github). This unofficial API was created by Import.io.
 *  @param sender A button overlaying the image of Octocat.
 */
- (IBAction)invisibleButtonTapped:(id)sender {
    PFQuery *octoQuery = [PFQuery queryWithClassName:@"octodex"];
    [octoQuery getObjectInBackgroundWithId:@"WIENIhX2vV" block:^(PFObject *object, NSError *error) {
        NSLog(@"PFObject (response object): %@", object.allKeys);
        [self randomizeOctocat:object];
    }];
    
}

-(void)randomizeOctocat:(PFObject*)object {
    NSLog(@"PFObject.allKeys = %@", object.allKeys);
    NSArray *octodex         = object[@"octocatURLs"];
    NSLog(@"octodex.count    = %@", [@(octodex.count) stringValue]);
    NSUInteger random        = (NSUInteger)[self randomFloatBetweenNumber:0 andNumber:octodex.count - 1];
    NSString *randomOCatURL  = octodex[random];
    NSLog(@"Random0CatURL: %@", randomOCatURL);
    [self.octocatDLImageView displayImageFromUrl:randomOCatURL];
}

    //      arc4random is 0 to its MAX → divided by that MAX normalizes the range (i.e., from 0.0 - 1.0), essentially a percentage. Multiply that by the range, and then add that to the original quantity...
-(CGFloat)randomFloatBetweenNumber:(CGFloat)minRange andNumber:(CGFloat)maxRange {
    return ((float)arc4random() / ARC4RANDOM_MAX) * (maxRange - minRange); //+ minRange;
}


@end
