//
//  FBFunViewController.m
//  FBFun
//
//  Created by Ray Wenderlich on 7/13/10.
//  Copyright Ray Wenderlich 2010. All rights reserved.
//

#import "FBFunViewController.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "JSON.h"

@implementation FBFunViewController
@synthesize loginStatusLabel = _loginStatusLabel;
@synthesize loginButton = _loginButton;
@synthesize loginDialog = _loginDialog;
@synthesize loginDialogView = _loginDialogView;
@synthesize textView = _textView;
@synthesize imageView = _imageView;
@synthesize segControl = _segControl;
@synthesize webView = _webView;
@synthesize accessToken = _accessToken;

#pragma mark Main

- (void)dealloc {
    self.loginStatusLabel = nil;
    self.loginButton = nil;
    self.loginDialog = nil;
    self.loginDialogView = nil;
    self.textView = nil;
    self.imageView = nil;
    self.segControl = nil;
    self.webView = nil;
    self.accessToken = nil;
    [super dealloc];
}

- (void)refresh {
    if (_loginState == LoginStateStartup || _loginState == LoginStateLoggedOut) {
        _loginStatusLabel.text = @"Not connected to Facebook";
        [_loginButton setTitle:@"Login" forState:UIControlStateNormal];
        _loginButton.hidden = NO;
    } else if (_loginState == LoginStateLoggingIn) {
        _loginStatusLabel.text = @"Connecting to Facebook...";
        _loginButton.hidden = YES;
    } else if (_loginState == LoginStateLoggedIn) {
        _loginStatusLabel.text = @"Connected to Facebook";
        [_loginButton setTitle:@"Logout" forState:UIControlStateNormal];
        _loginButton.hidden = NO;
    }   
}

- (void)viewWillAppear:(BOOL)animated {
    [self refresh];
}

#pragma mark Login Button

- (IBAction)loginButtonTapped:(id)sender {
    
    NSString *appId = @"8fa673a06891cac667e55d690e27ecbb";
    NSString *permissions = @"publish_stream";
    
    if (_loginDialog == nil) {
        self.loginDialog = [[[FBFunLoginDialog alloc] initWithAppId:appId requestedPermissions:permissions delegate:self] autorelease];
        self.loginDialogView = _loginDialog.view;
    }
    
    if (_loginState == LoginStateStartup || _loginState == LoginStateLoggedOut) {
        _loginState = LoginStateLoggingIn;
        [_loginDialog login];
    } else if (_loginState == LoginStateLoggedIn) {
        _loginState = LoginStateLoggedOut;        
        [_loginDialog logout];
    }
    
    [self refresh];
    
}

#pragma mark FB Requests

- (void)getFacebookProfile {
    NSString *urlString = [NSString stringWithFormat:@"https://graph.facebook.com/me?access_token=%@", [_accessToken stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSURL *url = [NSURL URLWithString:urlString];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setDidFinishSelector:@selector(getFacebookProfileFinished:)];
    
    [request setDelegate:self];
    [request startAsynchronous];
}

- (void)rateTapped:(id)sender {
    
}

#pragma mark FB Responses

- (void)getFacebookProfileFinished:(ASIHTTPRequest *)request
{
    // Use when fetching text data
    NSString *responseString = [request responseString];
    NSLog(@"Got Facebook Profile: %@", responseString);
    
    NSString *likesString;
    NSMutableDictionary *responseJSON = [responseString JSONValue];   
    NSArray *interestedIn = [responseJSON objectForKey:@"interested_in"];
    if (interestedIn != nil) {
        NSString *firstInterest = [interestedIn objectAtIndex:0];
        if ([firstInterest compare:@"male"] == 0) {
            [_imageView setImage:[UIImage imageNamed:@"depp.jpg"]];
            likesString = @"dudes";
        } else if ([firstInterest compare:@"female"] == 0) {
            [_imageView setImage:[UIImage imageNamed:@"angelina.jpg"]];
            likesString = @"babes";
        }        
    } else {
        [_imageView setImage:[UIImage imageNamed:@"maltese.jpg"]];
        likesString = @"puppies";
    }
    
    NSString *username;
    NSString *firstName = [responseJSON objectForKey:@"first_name"];
    NSString *lastName = [responseJSON objectForKey:@"last_name"];
    if (firstName && lastName) {
        username = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    } else {
        username = @"mysterious user";
    }
    
    _textView.text = [NSString stringWithFormat:@"Hi %@!  I noticed you like %@, so tell me if you think this pic is hot or not!",
                      username, likesString];
    
    [self refresh];    
}

#pragma mark FBFunLoginDialogDelegate

- (void)accessTokenFound:(NSString *)accessToken {
    NSLog(@"Access token found: %@", accessToken);
    self.accessToken = accessToken;
    _loginState = LoginStateLoggedIn;
    [self dismissModalViewControllerAnimated:YES];    
    [self getFacebookProfile];        
    [self refresh];
}

- (void)displayRequired {
    [self presentModalViewController:_loginDialog animated:YES];
}

- (void)closeTapped {
    [self dismissModalViewControllerAnimated:YES];
    _loginState = LoginStateLoggedOut;        
    [_loginDialog logout];
    [self refresh];
}

@end
