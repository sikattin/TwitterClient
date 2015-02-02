//
//  TableLineCell.h
//  TwitterClient01
//
//  Created by 鹿野 孟城 on 2015/01/24.
//  Copyright (c) 2015年 鹿野 孟城. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableLineCell : UITableViewCell

@property UILabel *tweetTextLabel;
@property UILabel *nameLabel;
@property UIImageView *profileImageView; // imageを貼り付ける
@property int tweetTextLabelHeight;
@property UIImage *image; // 画像そのもの
@property int paddingTop;
@property int paddingBottom;


@end
