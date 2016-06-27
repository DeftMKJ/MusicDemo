//
//  ViewController.m
//  MusicPlayerDemo
//
//  Created by 宓珂璟 on 16/6/26.
//  Copyright © 2016年 UITableView. All rights reserved.
//

// 底部三个按钮平分屏幕的宽度做法
// 1.首先固定左侧第一个按钮的下和左的约束固定好，其中高度可以给也可以不给，让文字自动填充
// 2.然后选中三个按钮，选中垂直对齐以及等宽的必要条件
// 3.之后中间的按钮只要设置距离左侧按钮的约束就好
// 4.最后让最右侧的按钮距离右边的约束，左侧的约束固定好，选中三个，按下option + command + =，对齐即可

// (lldb) po indexPath
//<NSIndexPath: 0xc000000007a00016> {length = 2, path = 0 - 61}
//    
//    2016-06-27 16:22:47.557 MusicPlayerDemo[5176:272368] *** Terminating app due to uncaught exception 'NSRangeException', reason: '*** -[__NSArrayM objectAtIndex:]: index 61 beyond bounds [0 .. 51]'
//    *** First throw call stack:
#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "MKJParserLrc.h"
#import "UIImage+ImageEffects.h"
@interface ViewController () <UITableViewDataSource,UITableViewDelegate,AVAudioPlayerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISlider *volSlider;
@property (weak, nonatomic) IBOutlet UISlider *progressSlider;


@property (nonatomic,strong) AVAudioPlayer *audioPlayer; // AVAudioPlayer  ---->  音频 本地
@property (nonatomic,strong) NSArray *mp3Arr;
@property (nonatomic,strong) NSArray *lrcArr;
@property (nonatomic,assign) NSInteger mp3Index;
@property (nonatomic,assign) NSUInteger currentRow;

@property (nonatomic,strong) MKJParserLrc *mkj;

@end

static NSString *ID = @"MKJTableViewCell";
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor colorWithRed:193/255.4 green:193/255.0 blue:193/255.4 alpha:0.7];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = 60;
    UIImage *image = [UIImage imageNamed:@"436c1b64a2b6a4cbab09ee22db3851f4-1400x2100.jpg"];
    image = [image applyBlurWithRadius:15 tintColor:nil saturationDeltaFactor:1.5 maskImage:nil];
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:image];
    self.mp3Arr = @[[[NSBundle mainBundle] pathForResource:@"Love Story" ofType:@"mp3"],[[NSBundle mainBundle] pathForResource:@"薛之谦-演员" ofType:@"mp3"],[[NSBundle mainBundle] pathForResource:@"华晨宇-异类" ofType:@"mp3"]];
    
    self.lrcArr = @[[[NSBundle mainBundle] pathForResource:@"Love Story" ofType:@"lrc"],[[NSBundle mainBundle] pathForResource:@"薛之谦-演员" ofType:@"lrc"],[[NSBundle mainBundle] pathForResource:@"华晨宇-异类" ofType:@"lrc"]];
    
    self.mkj = [[MKJParserLrc alloc] init];
    
    [self loadMp3:self.mp3Arr[self.mp3Index] lrcPath:self.lrcArr[self.mp3Index]];
    
    
    
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(changeTime:) userInfo:nil repeats:YES];
}

- (void)changeTime:(NSTimer *)timer
{
    self.progressSlider.value = self.audioPlayer.currentTime;
    
    [self.mkj.timeArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
       
        NSString *timeStr = self.mkj.timeArr[idx];
        NSArray *timeArr = [timeStr componentsSeparatedByString:@":"];
        CGFloat seconds = [timeArr[0] floatValue] * 60 + [timeArr[1] floatValue];
        if (seconds >= self.audioPlayer.currentTime) {
            if (idx == 0)
            {
                self.currentRow = idx;
            }
            else
            {
                self.currentRow = idx - 1;
            }
            *stop = YES;
        }
    }];
    [self.tableView reloadData];
    if (self.currentRow < self.mkj.lrcArr.count) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.currentRow inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
    
    
}

- (void)loadMp3:(NSString *)mp3Str lrcPath:(NSString *)lrcStr
{
    // 这个方法是获取网上的
//    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:mp3Str] error:nil];
    // 下面的是本地的
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:mp3Str] error:nil];
    self.audioPlayer.delegate = self;
    self.audioPlayer.volume = 0.5f;
    
    [self.mkj parserLrcWithFileURL:lrcStr];
    
    self.progressSlider.maximumValue = self.audioPlayer.duration;
    [self.audioPlayer prepareToPlay];
    
}

// 上一首
- (IBAction)previousSong:(id)sender
{
    [self.audioPlayer stop];
    self.mp3Index--;
    if (_mp3Index==-1) {
        self.mp3Index = 2;
    }
    [self loadMp3:self.mp3Arr[self.mp3Index] lrcPath:self.lrcArr[self.mp3Index]];
    [self.audioPlayer play];
    
}
// 播放或者暂停
- (IBAction)play:(id)sender {
    
    if (self.audioPlayer.playing) {
        [self.audioPlayer pause];
    }
    else
    {
        [self.audioPlayer play];
    }
}
// 下一首
- (IBAction)NextSong:(id)sender
{
    [self.audioPlayer stop];
    self.mp3Index++;
    if (self.mp3Index == 3) {
        self.mp3Index = 0;
    }
    [self loadMp3:self.mp3Arr[self.mp3Index] lrcPath:self.lrcArr[self.mp3Index]];
    [self.audioPlayer play];
}

// 声音change
- (IBAction)volChange:(UISlider *)sender {
    
    self.audioPlayer.volume = sender.value;
}
// 进度change
- (IBAction)rateChange:(UISlider *)sender {
    self.audioPlayer.currentTime = sender.value;
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self NextSong:nil];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.mkj.lrcArr.count;  // 52 46 81 三个不同数据会在不同时间段越界
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (indexPath.row < self.mkj.lrcArr.count) {
        cell.textLabel.text = self.mkj.lrcArr[indexPath.row];
    }
    
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.numberOfLines = 0;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    cell.textLabel.font = [UIFont fontWithName:@"STHeitiTC-Light" size:15];
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    cell.backgroundColor = [UIColor clearColor];
    if (self.currentRow == indexPath.row)
    {
        cell.textLabel.textColor = [UIColor redColor];
    }
    else
    {
        cell.textLabel.textColor = [UIColor whiteColor];
    }
    
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
