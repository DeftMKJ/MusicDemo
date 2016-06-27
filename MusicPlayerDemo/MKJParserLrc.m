//
//  MKJParserLrc.m
//  MusicPlayerDemo
//
//  Created by 宓珂璟 on 16/6/26.
//  Copyright © 2016年 UITableView. All rights reserved.
//

#import "MKJParserLrc.h"

@implementation MKJParserLrc

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.timeArr = [[NSMutableArray alloc] init];
        self.lrcArr = [[NSMutableArray alloc] init];
    }
    return self;
}


- (void)parserLrcWithFileURL:(NSString *)lrcPath
{
    [self.lrcArr removeAllObjects];
    [self.timeArr removeAllObjects];
    NSString *lrcStr = [NSString stringWithContentsOfFile:lrcPath encoding:NSUTF8StringEncoding error:nil];
    
    NSArray *lrcArr = [lrcStr componentsSeparatedByString:@"["];
    
    for (NSString *sepStr in lrcArr) {
        
        NSArray *sepArr = [sepStr componentsSeparatedByString:@"]"];
        if (!([sepArr[0] isEqualToString:@""] || [sepArr[1] isEqualToString:@"\n"] || [sepArr[1] isEqualToString:@"\r\n"])) {
            [self.timeArr addObject:sepArr[0]];
            [self.lrcArr addObject:sepArr[1]];
        }
    }
    
}
@end
