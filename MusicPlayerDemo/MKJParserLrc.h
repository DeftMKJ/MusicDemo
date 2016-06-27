//
//  MKJParserLrc.h
//  MusicPlayerDemo
//
//  Created by 宓珂璟 on 16/6/26.
//  Copyright © 2016年 UITableView. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MKJParserLrc : NSObject

@property (nonatomic,strong) NSMutableArray *timeArr;
@property (nonatomic,strong) NSMutableArray *lrcArr;

- (void)parserLrcWithFileURL:(NSString *)lrcPath;

@end
