//
//  ViewController.m
//  playerDemo
//
//  Created by gaozhihong on 2018/4/4.
//  Copyright © 2018年 gaozhihong. All rights reserved.
//

#import "ViewController.h"
#import "MoviePlayViewController.h"
#import <MediaPlayer/MediaPlayer.h>
@interface ViewController ()

@end

@implementation ViewController{
//    MPVolumeView *_volumeView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    MPVolumeView *volumeView = [MPVolumeView new];
    volumeView.backgroundColor =[UIColor cyanColor];
    volumeView.showsRouteButton = YES;
    
    volumeView.showsVolumeSlider = YES;
    
    [self.view addSubview:volumeView];
    
    
    
    // __weak __typeof(self)weakSelf = self;
   __block id  volumeViewSlider;
    [[volumeView subviews] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        if ([obj isKindOfClass:[UISlider class]]) {
            
            //__strong __typeof(weakSelf)strongSelf = weakSelf;
            
            volumeViewSlider = obj;//UISlider* volumeViewSlider;
            
            *stop = YES;
            
        }
        
    }];
    
    [volumeViewSlider setValue:2.0 animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
      /**
       http://admin.ljabc.com.cn/upload/video/file_0000005719.mp4?sessionId=3332FFFD4EB69F14800EDF491E8A6CA8
        http://video.ljabc.com.cn/upload/cdn_video/file_0000009053.mp4?sessionId=3332FFFD4EB69F14800EDF491E8A6CA8&source=0
         http://video.ljabc.com.cn/upload/cdn_video/file_0000008886.mp4?sessionId=3332FFFD4EB69F14800EDF491E8A6CA8&source=0
        http://video.ljabc.com.cn/upload/cdn_video/file_0000009043.mp4?sessionId=3332FFFD4EB69F14800EDF491E8A6CA8&source=0
       */
    NSString  *playUrl  = @"http://video.ljabc.com.cn/upload/cdn_video/file_0000008886.mp4?sessionId=3332FFFD4EB69F14800EDF491E8A6CA8&source=0";
    NSMutableDictionary *argument =[NSMutableDictionary dictionary];
    [argument setObject:@"20000" forKey:@"playId"];
     [argument setObject:@"20001" forKey:@"chapterId"];
    MoviePlayViewController *moviePlayVC = [[MoviePlayViewController alloc] initWithPlayerUrlStr:playUrl movieTitle:nil argument:argument];
    [self presentViewController:moviePlayVC animated:YES completion:^{
        
    }];
    
}



@end
