//
//  MoviePlayViewController.m
//  playerDemo
//
//  Created by gaozhihong on 2018/4/4.
//  Copyright © 2018年 gaozhihong. All rights reserved.
//

#import "MoviePlayViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>


#define KTopViewHeight  44
#define KBottomViewHeight 44
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGTH [UIScreen mainScreen].bounds.size.height
#define KViewAlpha  0.55

@interface MoviePlayViewController ()
 /** argument*/
@property(nonatomic,copy)NSString *movieTitle;
@property(nonatomic,copy) NSString *currentPlayUrl;
@property(nonatomic,assign)int currentPlayIndex;
@property(nonatomic,strong)NSArray *moviePlayUrlList;

 /** AVPlayer */
@property(nonatomic,strong)AVPlayer *player;
@property(nonatomic,strong)AVPlayerItem *playerItem;
@property(nonatomic,strong) id  playerTimeObserver;

 /** 判断是否竖屏状态*/
@property(nonatomic,assign)BOOL isPortrait;

 /** subViews*/
@property(nonatomic,strong)UIView *topView;
@property(nonatomic,strong)UIView *bottomView;
 /** 侧滑的view*/
@property(nonatomic,strong)UIView *sideView;
 /** 进度条 */
@property(nonatomic,strong)UISlider *moviePlaySlider;
@property(nonatomic,strong) UILabel *timeDisplayLable;
@property(nonatomic,assign) float currentMoviePlayTime;

 /** playId chapterId */
@property(nonatomic,copy)NSString *playId;
@property(nonatomic,copy) NSString *chapterId;



@end

@implementation MoviePlayViewController



-(void)judgeIsPorprait{
    if (self.view.bounds.size.height > self.view.bounds.size.width) {
        _isPortrait = YES;
    }else{
        _isPortrait = NO;
    }
    NSLog(@"%d",_isPortrait);
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - init MoviePlayViewController
-(instancetype)initWithPlayerUrlStr:(NSString *)playUrlStr movieTitle:(NSString *)movieTitle argument:(NSDictionary *)argument{
    if (self = [super init]) {
        _movieTitle= movieTitle;
        _currentPlayUrl = playUrlStr;
        if (argument) {
            _playId = argument[@"playId"];
            _chapterId = argument[@"chapterId"];
        }
        
    }
    return self;
}
-(instancetype)initWithPlayerUrlStr:(NSArray *)playUrlList titleName:(NSString *)titleName playIndex:(int)playIndex imgPath:(NSString *)imgPath argument:(NSDictionary *)argument{
    if (self =[super init]) {
        _movieTitle = titleName;
        _moviePlayUrlList = playUrlList;
        _currentPlayIndex = playIndex;
        if (argument) {
            _playId = argument[@"playId"];
            _chapterId = argument[@"chapterId"];
        }
        
        
    }
    return self;
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self judgeIsPorprait];
    [self setupUI];
    [self createAVPlayer];
    
    // 未完成的内容
    // 手势滑动 快进 进度条 锁
    // 音量 打电话 打断 亮度调整
//     更换UI   **第一次进入怎么怎么处
    // 不通用户怎么搞呢  userID
    
    /**
     如何准确获取一个时时的播放时间
     1、  CMTime  ==  获取
     2、 == 进度条 进度 * 总时长
     3 、为何自己会归零呢
     
     */
    
    
}
#pragma mark  -- create AVPlayer
-(void)createAVPlayer{
    if ( !_currentPlayUrl ) {
        return;
    }
    NSURL *playUrl  = [NSURL URLWithString:_currentPlayUrl];
//    NSURL *playUrl  = [NSURL URLWithString:[NSString stringWithFormat:@"%@",_moviePlayUrlList[_currentPlayIndex]]];
     // player
    self.playerItem = [AVPlayerItem playerItemWithURL:playUrl];
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
     // AVPlayerLayer
    AVPlayerLayer *playerLayer  = [AVPlayerLayer playerLayerWithPlayer:self.player];
    playerLayer.videoGravity =  AVLayerVideoGravityResizeAspectFill;
    float width = 0;
    float height = 0;
    if (_isPortrait) {
        width = self.view.bounds.size.height;
        height = self.view.bounds.size.width;
    }else{
        width = self.view.bounds.size.width;
        height = self.view.bounds.size.height;
    }
    CGRect layerFrame  = CGRectMake(0, 0, width, height);
    playerLayer.frame = layerFrame;
    [self.view.layer insertSublayer:playerLayer below:_topView.layer];
    
    if (self.player) {
//        [self.player play];
    }
     // 监听播放状态
    [self addPlayStatusObserver];
    [self addmoviePlayTimeObserver];
    
    
}
#pragma  mark  -- setupUI
-(void)setupUI{
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupTopView];
    [self setupBottomView];
}
-(void)setupTopView{
    _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_HEIGTH, KTopViewHeight)];
   _topView.backgroundColor = [UIColor blackColor];
   _topView.alpha = KViewAlpha;
    [self.view addSubview:_topView];
    [self.view bringSubviewToFront:_topView];
      // banckView  128 64  32 16
    float backViewW = 46;
    float backViewH = 23;
    UIImageView *backView = [[UIImageView alloc] initWithFrame:CGRectMake(25, (KTopViewHeight -backViewH)/2.0, backViewW, backViewH)];
//    backView.backgroundColor = [UIColor purpleColor];
    backView.image = [UIImage imageNamed:@"back"];
    [_topView addSubview:backView];
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backViewPopGesture)];
    backView.userInteractionEnabled = YES;
    [backView addGestureRecognizer:tapGes];
    
   
}
#pragma  mark  -- bottomView
-(void)setupBottomView {
    _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_WIDTH-KBottomViewHeight, SCREEN_HEIGTH, KBottomViewHeight)];
    _bottomView.backgroundColor = [UIColor blackColor];
    _bottomView.alpha = KViewAlpha;
    [self.view addSubview:_bottomView];
    [self.view bringSubviewToFront:_bottomView];
    
     // 添加播放点击按钮
    [self setupPlayClickButton];
    // 添加进度条
    [self setupMoviePlaySlider];
    //当前播放时间和总时长
    [self setupTimeDisplayLable];
    
    
}

-(void)setupPlayClickButton{
    float  leftMargin = 50;
    float butW = 16;
    float butH = butW;
    UIButton *playClickButton = [[UIButton alloc] initWithFrame:CGRectMake((leftMargin -butW)/2.0, (KBottomViewHeight -butH)/2.0, butW, butH)];
//    playClickButton.backgroundColor = [UIColor yellowColor];
    [playClickButton setBackgroundImage:[UIImage imageNamed:@"pause_nor"] forState:UIControlStateNormal];
    [playClickButton setBackgroundImage:[UIImage imageNamed:@"play_nor"] forState:UIControlStateSelected];
    [playClickButton addTarget:self action:@selector(playButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:playClickButton];
    
}
-(void)playButtonClick:(UIButton*)sender{
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self.player pause];
    }else{
        [self.player play];
    }
}
-(void)setupMoviePlaySlider{
    float sliderHeight = 8;
    float sliderWidth = SCREEN_HEIGTH *0.72;
    _moviePlaySlider = [[UISlider alloc] initWithFrame:CGRectMake(50, (KBottomViewHeight-sliderHeight)/2.0, sliderWidth, sliderHeight)];
    //    _moviePlaySlider.backgroundColor =[UIColor orangeColor];
    [_moviePlaySlider setMinimumTrackTintColor:[UIColor whiteColor]];
    [_moviePlaySlider setMaximumTrackTintColor:[UIColor colorWithRed:0.49f green:0.48f blue:0.49f alpha:1.00f]];
     [_moviePlaySlider setThumbImage:[UIImage imageNamed:@"progressThumb.png"] forState:UIControlStateNormal];
    [_moviePlaySlider addTarget:self action:@selector(sliderDragDidEnd:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchCancel];
    // 改变拖拽按钮样式
    // 拖拽改变播放进度
    [_bottomView addSubview:_moviePlaySlider];
    
}
-(void)setupTimeDisplayLable{
    float  lableWidth = 100;
    float labX = self.view.bounds.size.height -lableWidth -10;
    float lableHeight = 24;
    self.timeDisplayLable = [[UILabel alloc] initWithFrame:CGRectMake(labX, (KTopViewHeight-lableHeight)/2.0, lableWidth, lableHeight)];
    self.timeDisplayLable.backgroundColor = [UIColor cyanColor];
    self.timeDisplayLable.font = [UIFont systemFontOfSize:13.0];
    self.timeDisplayLable.text = @"00:00 / 00:00";
    self.timeDisplayLable.textAlignment = NSTextAlignmentCenter;
    [_bottomView addSubview:self.timeDisplayLable];
    
}
#pragma  mark  -- 进度条拖拽监听
-(void)sliderDragDidEnd:(UISlider*)slieder{
    if (!self.player) return;
    double totalPlayLength  = 0;
    if (self.player.currentItem.duration.timescale != 0) {
        totalPlayLength = self.player.currentItem.duration.value / self.player.currentItem.duration.timescale;
    }
    __weak typeof(self) weakSelf  = self;
    [self.player seekToTime:CMTimeMakeWithSeconds(totalPlayLength *slieder.value, self.player.currentItem.duration.timescale) completionHandler:^(BOOL finished) {
        if (weakSelf.player) {
              [weakSelf.player play];
        }
      
    }];
}
-(void)setupViewShowOrHidden{
    CGRect topFrame  = _topView.frame;
    CGRect bottomFrame = _bottomView.frame;
    float width = 0 ;
    float height  = 0;
    if (self.view.bounds.size.height > self.view.bounds.size.width) {
        width = self.view.bounds.size.height;
        height = self.view.bounds.size.width;
    }else{
        width = self.view.bounds.size.width;
        height = self.view.bounds.size.height;
    }
    if (topFrame.origin.y < 0 ) {
        topFrame.origin.y = 0 ;
        bottomFrame.origin.y = height -KBottomViewHeight;
    }else{
        topFrame.origin.y = -KTopViewHeight;
        bottomFrame.origin.y = height;

    }
    [UIView animateWithDuration:0.5 animations:^{
        _topView.frame = topFrame;
        _bottomView.frame = bottomFrame;
    }];
}

  // 侧边栏
-(void) setupSideView{
    
}

#pragma mark  -- 添加状态通知
-(void)addPlayStatusObserver{
    if (self.player.currentItem) {
        [self.player.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
        [self.player.currentItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
        [self.player.currentItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
        
    }
    
}
#pragma mark  -- playerTimeObserver/实时监听方法
-(void)addmoviePlayTimeObserver{
    __block double totalPlayLength  = 0;
    __weak typeof(self) weakSelf  = self;
    self.playerTimeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        float seconds = CMTimeGetSeconds(time);
        weakSelf.currentMoviePlayTime = CMTimeGetSeconds(time);
        NSString *currentTime= [weakSelf displayTime:seconds];
        if (weakSelf.player.currentItem.duration.timescale != 0) {
            totalPlayLength = weakSelf.player.currentItem.duration.value / weakSelf.player.currentItem.duration.timescale;
        }
         NSString  *timeLength = [weakSelf displayTime:totalPlayLength];
        weakSelf.timeDisplayLable.text = [NSString stringWithFormat:@"%@ / %@",currentTime,timeLength];
        
    }];
}
 // 处理时间格式
-(NSString*)displayTime:(float)second{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:second];
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];
    if (second >= 3600) {
        formater.dateFormat = @"HH:mm:ss";
    }else{
        formater.dateFormat = @"mm:ss";
    }
    NSString *timeStr = [formater stringFromDate:date];
    return timeStr;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    AVPlayerItem *playerItem = (AVPlayerItem*)object;
    if ([keyPath isEqualToString:@"status"]) {
        if (playerItem.status ==AVPlayerItemStatusReadyToPlay) {
//             _moviePlaySlider
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setObject:_playId forKey:@"playId"];
            [dict setObject:_chapterId forKey:@"chapterId"];
          
//            [self.player play];
             // 须调用此方法
                NSString *seconds = [[MoviePlayTool shareTool] getplayProgesss:dict];
                float totalTime  = self.player.currentItem.duration.value /self.player.currentItem.duration.timescale;
                _moviePlaySlider.value = seconds.floatValue / totalTime;
                [self sliderDragDidEnd:_moviePlaySlider];
        
        }else if (playerItem.status == AVPlayerStatusFailed){
            
        }
    }

}

#pragma mark  -- 更新播放记录
-(void)updatePlayRecord{
    if (self.player == nil) {
        return;
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"playId"] = _playId;
    dict[@"chapterId"] = _chapterId;;
    NSNumber *number = [NSNumber numberWithFloat:self.currentMoviePlayTime];
    dict[@"second"] = number;
    [[MoviePlayTool shareTool] updatePlayRecord:dict];
     // 判断是否有观看记录
    if ([[MoviePlayTool shareTool] hasPlayRecord:dict]) {
          [[MoviePlayTool shareTool] updatePlayRecord:dict];
    }else{
        [[MoviePlayTool shareTool] insertPlayInfo:dict];
    }
    
}

-(void)backViewPopGesture{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    [self updatePlayRecord];
    
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    [self dismissViewControllerAnimated:YES completion:nil];
    [self setupViewShowOrHidden];
    
 }
#pragma mark  --添加屏幕手势
-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch =  [touches anyObject];
    
}


// 设置设备支持朝向
-(BOOL)shouldAutorotate{
    return NO;
}
-(UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
    
}
-(void)dealloc{
    NSLog(@"%s",__func__);
    [self.player.currentItem removeObserver:self forKeyPath:@"status"];
    [self.player.currentItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [self.player.currentItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    
}
@end


 /**
  ### MoviePlayTools
  */

@interface  MoviePlayTool()


@end

static  FMDatabase *_db;
@implementation MoviePlayTool

+(MoviePlayTool *)shareTool{
    return [[self alloc] init];
}

+(void)initialize{
    // 设置数据库
    NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:@"player.db"];
    NSLog(@"%@",filePath);
    _db = [FMDatabase databaseWithPath:filePath];
      /** playId chapterId date second */
    
    if (![_db open]) return;
    BOOL success = [_db executeUpdate:@"CREATE TABLE IF NOT EXISTS PLAY_RECORD (PLAYID TEXT,CHAPTERID TEXT,DATE TEXT,SECOND INTEGER);"];
    if (success) {
        NSLog(@"create  success!");
    }
    
}
-(void)openDBWithUserId:(NSString *)userId{
    // userId playId chapaterId  date  playTime
    
}
-(void)insertPlayInfo:(NSDictionary *)dict{
    if (dict  == nil) {
        return;
    }
    NSString *playId = dict[@"playId"];
    NSString *chapterId = dict[@"chapterId"];
    NSInteger second = [dict[@"second"] integerValue];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd:HH-mm-ss";
    NSString *dateStr = [formatter stringFromDate:[NSDate date]];
    [_db  executeUpdateWithFormat:@"INSERT INTO PLAY_RECORD(PLAYID,CHAPTERID,DATE,SECOND) VALUES(%@,%@,%@,%ld)",playId,chapterId,dateStr,second];
//    [_db executeUpdate:sql];
    
    
}

// ### update 的时候占位符必须加单引号
-(void)updatePlayRecord:(NSDictionary *)dict{
       if (dict == nil) return;
        NSString *playId = dict[@"playId"];
        NSString *chapterId = dict[@"chapterId"];
        NSInteger second = [dict[@"second"] integerValue];
       NSString *dateStr =[self getCurrentDate];
    [_db executeUpdate:[NSString stringWithFormat:@"UPDATE PLAY_RECORD SET DATE = '%@',SECOND = '%ld' WHERE PLAYID ='%@' AND CHAPTERID = '%@'",dateStr,second,playId,chapterId]];
    
}
-(NSString*)getplayProgesss:(NSDictionary *)dict{
    
     if (dict == nil) return nil;
        NSString *playId = dict[@"playId"];
       NSString *chapterId = dict[@"chapterId"];
      NSString * res = 0 ;
//        NSString *sqlStr = [NSString stringWithFormat:@"SELECT *FROM PLAY_RECORD WHERE PLAYID = %@ AND CHAPTERID = %@",playId,chapterId];
    FMResultSet *result = [_db executeQueryWithFormat:@"SELECT * FROM PLAY_RECORD WHERE PLAYID LIKE %@ AND CHAPTERID LIKE %@",playId,chapterId];
        while (result.next) {
            res = [result stringForColumn :@"second"];
        }
    return res;
    
}
-(BOOL)hasPlayRecord:(NSDictionary *)dict{
    
    NSString *playId = dict[@"playId"];
    NSString *chapterId = dict[@"chapterId"];
    NSString *quarySql = [NSString stringWithFormat:@"SELECT COUNT(*) AS COUNT FROM PLAY_RECORD WHERE PLAYID = '%@' AND CHAPTERID = '%@'",playId,chapterId];
   FMResultSet *result= [_db executeQuery:quarySql];
    int count  = 0;
    while (result.next) {
        count = [result intForColumn:@"COUNT"];
    }
     NSLog(@"count == %d",count);
    if (count > 0 ) {
        return YES;
    }
    return NO;
    
    
}
-(NSString*)getCurrentDate{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd:HH-mm-ss";
    NSString *dateStr = [formatter stringFromDate:[NSDate date]];
    return dateStr;
}

-(void)removeDataBase{
    
}






@end
