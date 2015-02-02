//
//  DetailViewController.m
//  TwitterClient01
//
//  Created by 鹿野 孟城 on 2015/01/24.
//  Copyright (c) 2015年 鹿野 孟城. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()

@property NSString *httpErrorMessage;
@property (weak, nonatomic) IBOutlet UIImageView *imageview;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *nameview;
@property (weak, nonatomic) IBOutlet UITextView *textview;
@property (weak, nonatomic) IBOutlet UILabel *popup;







@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor darkGrayColor];
    self.navigationItem.title = @"Detail view";
    self.imageview.image = self.image;
    self.nameview.text = self.name;
    self.textview.text = self.text;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)retweetAction:(id)sender {
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccount *account = [accountStore accountWithIdentifier:self.identifier];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/1.1/statuses/retweet/%@.json", self.idStr]];
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:url parameters:nil]; //今回はurlにidstrを含めるので不要
    
    request.account = account;
    
    UIApplication *application = [UIApplication sharedApplication];
    application.networkActivityIndicatorVisible = YES;
    
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (responseData) {
            self.httpErrorMessage = nil;
            if(urlResponse.statusCode >=200 && urlResponse.statusCode <300) {
                NSDictionary *postResponseData =
                [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:NULL];
                self.popup.text = @"Success";
                NSLog(@"SUCCESS! Created Retweet with ID: %@", postResponseData[@"id_str"]);
            } else { //HTTPエラー発生時
                self.httpErrorMessage = [NSString stringWithFormat:@"The response status code is %ld", (long)urlResponse.statusCode];
                NSLog(@"HTTPError: %@",self.httpErrorMessage);
                //リツイート時のHッTPエラーメッセイジを画面に表示する領域がない　作る
            }
        } else { //リクエスト送信エラー発生時
            NSLog(@"ERROR! : An error occurred while position: %@", [error localizedDescription]);
            //リクエスト時の送信エラーメッセージを画面に表示する領域がない。作る。
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            UIApplication *application = [UIApplication sharedApplication];
            application.networkActivityIndicatorVisible = NO;
        });
    }];
}

@end
