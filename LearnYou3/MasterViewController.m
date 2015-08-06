//
//  MasterViewController.m
//  LearnYou2
//
//  Created by Amitai Blickstein on 7/23/15.
//  Copyright (c) 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "LoginViewController.h"
#import "LY3GithubAPIClient.h"
#import <Parse.h>
#import <Regexer.h>
#import <SWTableViewCell/SWTableViewCell.h>


@interface MasterViewController () <SWTableViewCellDelegate>

@property (nonatomic, strong) NSMutableArray *objects;
@property (nonatomic, strong) NSString *userName;

@end

@implementation MasterViewController

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //Our beautiful logout button.
    UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"logout"] style:UIBarButtonItemStylePlain target:self action:@selector(logout:)];
    self.navigationItem.leftBarButtonItem = logoutButton;
    
    __block NSMutableArray *results = [NSMutableArray new];
    __block NSMutableArray *raw = [NSMutableArray new];
    __block NSUInteger pagination = 1;
    /**
     *  process me differently! Spelunk in the method, not here!
     *
     *  @param task  <#task description#>
     *  @param repos <#repos description#>
     *
     *  @return <#return value description#>
     */
    [LY3GithubAPIClient getCurrentUserRepositoriesWithCompletion:^(NSURLSessionDataTask *task, NSArray *repos) {
            //Populates an array with the repos requested.
        for (NSDictionary *repo in repos) {
            [results addObject:repo[@"full_name"]];
        }
NSLog(@"Inside currentUserRepos completion block -- Results: %@", [results description]);
        [self.tableView reloadData];
        
NSLog(@"Results is of length: %lu", (unsigned long)results.count);
        NSString *username = repos[0][@"owner"][@"login"];
        NSLog(@"userName: %@", username);
        
        NSLog(@"NSURLResponse digging: %@", [[(NSHTTPURLResponse*)task.response allHeaderFields] description]);
        NSHTTPURLResponse *response = (NSHTTPURLResponse*)task.response;
        NSString *linkHeaderText = response.allHeaderFields[@"Link"];
        NSLog(@"link header tedxt: %@", linkHeaderText);
        NSString *rxPattern = @"\\d+(?=>; rel=\"last\")";
        NSString *paginationString = [linkHeaderText rx_textsForMatchesWithPattern:rxPattern][0];
        NSLog(@"pagination string: %@", paginationString);
    }];
        self.objects = results;
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    
    NSLog(@"Count of objects; %ld", [self.objects count]);

}

- (void)logout:(id)sender {
    NSLog (@"Logout");
    
    [self githubLogout];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)githubLogout {
    
    [AFOAuthCredential deleteCredentialWithIdentifier:@"githubOAuthToken"];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDate *object = self.objects[indexPath.row];
        [[segue destinationViewController] setDetailItem:object];
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1; //Labs forked-not-pulled, and labs forked-and-pulled.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.objects.count;
}



- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SWTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    cell.textLabel.text = self.objects[indexPath.row];
    cell.leftUtilityButtons = [self leftButtons];
    cell.delegate = self;
        
    return cell;
}



- (NSArray *)leftButtons
{
    NSMutableArray *leftUtilityButtons = [NSMutableArray new];
    
    [leftUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:0.988 green:0.745 blue:0.122 alpha:1]
                                                icon:[UIImage imageNamed:@"star.png"]];
    [leftUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:0.263 green:0.522 blue:0.961 alpha:1]
                                                icon:[UIImage imageNamed:@"question.png"]];
    
    return leftUtilityButtons;
}



- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self performSegueWithIdentifier:@"showDetail" sender:self];
}

-(bool)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell{
    return YES;
}

-(void) swipeableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index{
    NSLog(@"Button at index %ld tapped", index);
    
    if (index == 0) {
        NSLog (@"Index 0 tapped from inside the if statement");
        
    }
    
    if (index == 1) {
        NSLog (@"Index 1 tapped from inside the if statement");
    }
}

@end
