//
//  TimeLineTableViewController.m
//  TwitterClient01
//
//  Created by 鹿野 孟城 on 2015/01/24.
//  Copyright (c) 2015年 鹿野 孟城. All rights reserved.
//

#import "TimeLineTableViewController.h"

@interface TimeLineTableViewController ()

@property dispatch_queue_t main_Queue;
@property dispatch_queue_t image_Queue;
@property NSString *httpErrorMessage;
@property NSArray *timeLineData;



@end

@implementation TimeLineTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.main_Queue = dispatch_get_main_queue();
    self.image_Queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    
    //ios6以降のカスタムせる再利用のパターン
    [self.tableView registerClass:[TableLineCell class]forCellReuseIdentifier:@"TableLineCell"];
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    
    ACAccount *account = [accountStore accountWithIdentifier:self.identifier];
    NSURL *url = [NSURL URLWithString:@"https://api.twitter.com"
                  @"/1.1/statuses/home_timeline.json"]; //タイムライン取得のURL
    
    NSDictionary *params = @{@"count" : @"100",
                             @"trim_user" : @"0",
                             @"include_entities" : @"0"};

    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:url parameters:params];
    [request setAccount:account];

    UIApplication *application = [UIApplication sharedApplication];
    application.networkActivityIndicatorVisible = YES; //インジケータON
    
    [request performRequestWithHandler:^(NSData *responseData,
                                         NSHTTPURLResponse *urlResponse,
                                         NSError *error) { //ここからは別スレッド（キュー）
        if (responseData) {
            NSLog(@"paas1");
            
            self.httpErrorMessage = nil;
            if(urlResponse.statusCode >= 200 && urlResponse.statusCode < 300) {
                NSError *jsonError;
                self.timeLineData =     //複数件のNSDictionaryが返される
                [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&jsonError];
                if (self.timeLineData) {
                    NSLog(@"Timeline Response: %@\n", self.timeLineData);
                    dispatch_async(self.main_Queue, ^{
                        [self.tableView reloadData]; //tableview書き換え
                    });
                } else { //JSONシリアライズエラー発生時
                    NSLog(@"JSON Error: %@", [jsonError localizedDescription]);
                }
            }
            else {
                NSLog(@"pass3");
                self.httpErrorMessage =
                [NSString stringWithFormat:@"The response Status code is %ld",(long)urlResponse.statusCode];
                NSLog(@"HTTP Error: %@", self.httpErrorMessage);
            }
        } else {
            NSLog(@"Error: An error occured while requesting: %@", [error localizedDescription]);
        }
        dispatch_async(self.main_Queue, ^{
            UIApplication *application = [UIApplication sharedApplication];
            application.networkActivityIndicatorVisible = NO; //インジケータのOFF
        });
    }];
}

-(NSAttributedString *)labelAttributedString:(NSString *)labelString //ラベルの文字列を属性付き文字列に変換
{
    // ラベル文字列
    NSString *text = (labelString == nil) ? @"" : labelString; //三項算子のサンプルとして、普通のif文で可
    
    // フォントを指定
    UIFont * font = [UIFont fontWithName:@"HiraKakuProN-W3" size:13];
    
    
    
    //カスタムLineHeightを指定
    CGFloat customLineHeight = 19.5f;
    
    //パラグラフスタイルにlineHeightをセット
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.minimumLineHeight = customLineHeight; //paragraphStyleのminimumLineHeightオブジェクトに上で指定したcustomLineHeightをセット
    paragraphStyle.maximumLineHeight = customLineHeight;
    
    //属性としてパラグラフスタイルとフォントをセット
    NSDictionary *attributes = @{NSParagraphStyleAttributeName:paragraphStyle,
                                 NSFontAttributeName:font};
    // NSAttributedStringを生成して文字列と属性をセット
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:text attributes:attributes];
    /* カスタムLineHeightとフォントを属性としてセットしたNSDictionaryクラスのインスタンスattributesとラベル文字列を表すtextをNSMutableAttributedStringにセット
     */
    return attributedText;
}

- (CGFloat)labelHeight:(NSAttributedString *)attributedText //属性付きテキストを引数として渡している
{
    //　ラベルの高さ計算
    CGFloat aHeight = [attributedText boundingRectWithSize:CGSizeMake(257, MAXFLOAT)
                                                   options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.height;
    return aHeight;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (!self.timeLineData) { // レスポンス取得前はtimeLineDataがない
        return 1;
    } else {
        return [self.timeLineData count]; //タイムラインの数を返り値として返す＝行数
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TableLineCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TableLineCell" forIndexPath:indexPath];
    
    // Configure the cell...
    //NSSTring *status;
    if (self.httpErrorMessage) { //重要
        cell.tweetTextLabel.text = @"HTTP Error!"; //httpエラー時はここにメッセージ表示
        cell.tweetTextLabelHeight = 24.0;
    } else if (!self.timeLineData) { // レスポンスはあったが、まだタイムラインデータが取得できてない場合
        cell.tweetTextLabel.text = @"Loading...";
        cell.tweetTextLabelHeight = 24.0;
    } else {
        NSString *tweetText = self.timeLineData[indexPath.row][@"text"]; // ツイート本文のセット
        NSAttributedString *attributedTweetText = [self labelAttributedString:tweetText]; //ラベルの文字列を属性付き文字列に変換するメソッドの実行　引数としてtweetTextを渡している つまりツイート本文を属性付きテキストに変換して表示する作業
        cell.tweetTextLabel.attributedText = attributedTweetText; // UILabelクラスにはattributedTextという属性に関係するオブジェクトがある 属性付きツイート本文をtweetTextLabelにセット
        cell.nameLabel.text = self.timeLineData[indexPath.row][@"user"][@"screen_name"]; // 名前を取得したい... 取得したJSONタイムラインデータのuserの中のscreen_nameに入っているのでそれをnameLabel.textに貼り付けている
        cell.profileImageView.image = [UIImage imageNamed:@"blank.png"]; //とりあえず空の画像をセット
        cell.tweetTextLabelHeight = [self labelHeight:attributedTweetText]; // ラベルの高さ計算　属性付きツイート本文がセットされたtweetTextLabelを引数として渡し、ラベルの高さを求めるlabelHeightメソッドの実行
        UIApplication *application =[UIApplication sharedApplication];
        application.networkActivityIndicatorVisible = YES;
        
        dispatch_async(self.image_Queue, ^{
            NSString *url;
            NSDictionary *tweetDictionary = self.timeLineData[indexPath.row]; //timeLineDataの何個目なのかをセット
            
            if([[tweetDictionary allKeys] containsObject:@"retweeted_status"]) { //tweetDictionaryのすべてのキー項目の中にretweeted_statusが含まれていれば
                url= tweetDictionary[@"retweeted_status"][@"user"][@"profile_image_url"]; //リツイートされた者のプロフィール画像ウRLを取得
            } else {
                url = tweetDictionary[@"user"][@"profile_image_url"];
                //通常は発言者のプロフィール画像URLを取得
            }
            NSData *data = [NSData dataWithContentsOfURL:[NSURL  URLWithString:url]];
            //プロフィール画像取得　裏で１００件分のイメージ取得の並列処理が行われる
            dispatch_async(self.main_Queue, ^{
                UIApplication *application = [UIApplication sharedApplication];
                application.networkActivityIndicatorVisible = NO; //ぐるぐるインジケータオフ
                UIImage *image = [[UIImage alloc] initWithData:data];
                cell.profileImageView.image = image;
                [cell setNeedsLayout]; //せるの再描画
            });
        });
                                                               
        
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *tweetText = self.timeLineData[indexPath.row][@"text"]; // つぶやき本文を取得したい...取得したタイムラインデータのtextに格納されているのでこれをtweetTextにセットしている
    NSAttributedString *attributedTweetText = [self labelAttributedString:tweetText]; //取得した本文を引数として、属性付き本文に変えるメソッドの実行
    CGFloat tweetTextLabelHeight = [self labelHeight:attributedTweetText]; //上で実行されて返り値として返ってきた属性付き本文attributedTweetTextを引数として渡し、ラベルの高さを計算するメソッドの実行
    return tweetTextLabelHeight + 35; // セルのツイート本文ラベル以外の高さが合計で３５ピクセル
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TableLineCell *cell = (TableLineCell *)[tableView cellForRowAtIndexPath:indexPath];
    DetailViewController *detailViewController =
    [self.storyboard instantiateViewControllerWithIdentifier:@"DetailViewController"];
    detailViewController.text = cell.tweetTextLabel.text;
    detailViewController.name = cell.nameLabel.text;
    detailViewController.image = cell.profileImageView.image;
    detailViewController.identifier = self.identifier;
    detailViewController.idStr = self.timeLineData[indexPath.row][@"id_str"];
    [self.navigationController pushViewController:detailViewController animated:YES];
    
    
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
