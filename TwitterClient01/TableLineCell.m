//
//  TableLineCell.m
//  TwitterClient01
//
//  Created by 鹿野 孟城 on 2015/01/24.
//  Copyright (c) 2015年 鹿野 孟城. All rights reserved.
//

#import "TableLineCell.h"

@implementation TableLineCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier // Cellの再利用
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) /*初期化がうまくいったら*/{
        _paddingTop = 5;
        _paddingBottom = 5;
    _tweetTextLabel = [[UILabel alloc] initWithFrame:CGRectZero]; //大きさはlayoutSubviewsで設定する
        //_tweetTextLabel.backgroundColor = [UIColor blackColor];
    _tweetTextLabel.font = [UIFont systemFontOfSize:14.0f];
    _tweetTextLabel.textColor = [UIColor redColor];
        //_tweetTextLabel.highlightedTextColor = [UIColor blackColor];
    _tweetTextLabel.numberOfLines = 0;
    [self.contentView addSubview:_tweetTextLabel];
    
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
       // _nameLabel.backgroundColor = [UIColor blackColor];
    _nameLabel.font = [UIFont systemFontOfSize:10.0f];
    _nameLabel.textColor = [UIColor lightGrayColor];
    //_nameLabel.highlightedTextColor = [UIColor blackColor];
    [self.contentView addSubview:_nameLabel];
    
    _profileImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _profileImageView.image = self.image;
    [self.contentView addSubview:_profileImageView];
    }
    return self;
    
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    
    self.profileImageView.frame = CGRectMake(5, self.paddingTop, 48, 48); //(x, y, width, height)
    self.tweetTextLabel.frame = CGRectMake(58, 20, 300, self.tweetTextLabelHeight);
    self.nameLabel.frame = CGRectMake(58, self.paddingTop, 257, 10); // つぶやきの文字数によって行数が可変、高さが変わるためy座標をtweettextlabelheightで設定
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
