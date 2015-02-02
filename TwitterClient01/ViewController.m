//
//  ViewController.m
//  TwitterClient01
//
//  Created by 鹿野 孟城 on 2015/01/17.
//  Copyright (c) 2015年 鹿野 孟城. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *tweetActionButton;
@property (weak, nonatomic) IBOutlet UILabel *accountDisplayLabel;
@property ACAccountStore *accountStore;
@property NSString *identifier;
@property NSArray *twitterAccounts;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor lightGrayColor];
    self.accountStore = [[ACAccountStore alloc] init];
    ACAccountType *twitterType =
    [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [self.accountStore requestAccessToAccountsWithType:twitterType options:NULL
        completion:^(BOOL granted, NSError *error) {
            if (granted) { //認証成功時
                self.twitterAccounts = [self.accountStore accountsWithAccountType:twitterType];
                if (self.twitterAccounts.count > 0) { //アカウントが一つ以上あれば
                    NSLog(@"twitterAccounts = %@", self.twitterAccounts);
                    ACAccount *account = self.twitterAccounts[0]; //とりあえず先頭のアカウントをセット
                    self.identifier = account.identifier; //このidentifierを持ち回す
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.accountDisplayLabel.text = account.username; // UI処理はメインキューで
                    });
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.accountDisplayLabel.text = @"アカウントなし";
                    });
                }
            }
            else { //認証失敗時
                NSLog(@"Account Error: %@", [error localizedDescription]);
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.accountDisplayLabel.text = @"アカウント認証エラー";
                });
            }
        }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)tweetAction:(id)sender {
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) { //利用可能チェック
        NSString *serviceType = SLServiceTypeTwitter;
        SLComposeViewController *composeCtl = [SLComposeViewController composeViewControllerForServiceType:serviceType];
        [composeCtl setCompletionHandler:^(SLComposeViewControllerResult result) {
            if (result == SLComposeViewControllerResultDone){
                //投稿成功時の処理
            }
        }];
        [self presentViewController:composeCtl animated:YES completion:nil];
    }
}
- (IBAction)setAccountAction:(id)sender {
    
    UIActionSheet *sheet = [[UIActionSheet alloc] init]; //UIActionSheetクラスの初期化（インスタンス化）
    sheet.delegate = self;//UIviewControllerに処理を任せる
    
    sheet.title = @"選択してください。";
    for(ACAccount *account in self.twitterAccounts) { //twitterアカウントの数だけ繰り返し
        [sheet addButtonWithTitle:account.username];
    }
    [sheet addButtonWithTitle:@"キャンセル"];
    sheet.cancelButtonIndex = self.twitterAccounts.count; //アカウントの数が最後のボタンのIndex(account数が２個ならばキャンセルボタンは３番目）
    [sheet showInView:self.view]; //viewにアクションシートを挿入
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex { // タップしたボタンは何番目かがbuttonIndexに数字として入る（一番上なら0二番目なら１、３番目なら２といったように
    if (self.twitterAccounts.count > 0) { //アカウントが１つ以上あれば
        if (buttonIndex != self.twitterAccounts.count) { //キャンセルボタンのindexでなければ...キャンセルがタップされてない場合
            ACAccount *account = self.twitterAccounts[buttonIndex]; //ボタンのindexのアカウント　あとで使うために
            self.identifier = account.identifier; //identifierをセット　あとで使う
            self.accountDisplayLabel.text = account.username; //すぐに表示される
            NSLog(@"Account set! %@",account.username);//デバッグ用に表示
        } else {
            NSLog(@"cancel!"); //デバッグ用に表示
        }
    }
    
}

 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"timeLineSegue"]) { //セグエのid確認
        NSLog(@"pass");
        TimeLineTableViewController *timeLineVC = segue.destinationViewController;
        if ([timeLineVC isKindOfClass:[TimeLineTableViewController class]]) {
            timeLineVC.identifier = self.identifier; //アカウントidを持ち回す ViewController.mのidentifierをTimeLineTableViewControllerのidentifierに受け渡す
        }
    }
}

@end
