//
//  DetailViewController.h
//  TwitterClient01
//
//  Created by 鹿野 孟城 on 2015/01/24.
//  Copyright (c) 2015年 鹿野 孟城. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "AppDelegate.h"

@interface DetailViewController : UIViewController

@property (nonatomic, readwrite, strong) UIImage *image;
@property (nonatomic, readwrite, strong) NSString *name;
@property (nonatomic, readwrite, strong) NSString *text;
@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSString *idStr; //つぶやきの個数が入ってる

@end
