//
//  MoviePlayViewController.h
//  playerDemo
//
//  Created by gaozhihong on 2018/4/4.
//  Copyright © 2018年 gaozhihong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MoviePlayViewController : UIViewController
 /**接口*/
-(instancetype)initWithPlayerUrlStr:(NSString*)playUrlStr movieTitle:(NSString*)movieTitle argument:(NSDictionary*)argument;
-(instancetype)initWithPlayerUrlStr:(NSArray*)playUrlList titleName:(NSString*)titleName playIndex:(int) playIndex imgPath:(NSString*)imgPath argument:(NSDictionary*)argument;

@end

 /**
    MoviePlayTools 实现断点续播功能 提交播放记录 
  */
#import "FMDatabase.h"
@interface MoviePlayTool:NSObject

 /** 打开数据库 */
+(MoviePlayTool*)shareTool;
-(void)openDBWithUserId:(NSString*)userId;
  /** 获取播放进度 */
-(void)insertPlayInfo:(NSDictionary*)dict;
-(NSString*)getplayProgesss:(NSDictionary*)dict;
  /** 更新播放记录时间*/
-(void)updatePlayRecord:(NSDictionary*)dict;

-(BOOL)hasPlayRecord:(NSDictionary*)dict;
-(void)removeDataBase;
@end
