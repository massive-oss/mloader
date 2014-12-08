//
//  MassiveUtil.h
//
//  Created by Johann Martinache on 03/09/2014.
//  Copyright (c) 2014 Massive Interactive. All rights reserved.
//
#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>

#ifndef MASSIVE_UTIL_H
#define MASSIVE_UTIL_H

#define IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#ifdef DEBUG
	#define DEBUGMODE YES
#else
	#define DEBUGMODE NO
#endif

#if __has_feature(objc_arc)
  #define MassiveLog(format, ...) CFShow((__bridge CFStringRef)[NSString stringWithFormat:format, ## __VA_ARGS__]);
#else
  #define MassiveLog(format, ...) CFShow([NSString stringWithFormat:format, ## __VA_ARGS__]);
#endif

#ifdef DEBUG
#   define DLog(fmt, ...) MassiveLog((@"\n%s [Line %d] : \n\t" fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define DLog(...)
#endif

#define ALog(fmt, ...) MassiveLog((@"\n%s [Line %d] : \n\t" fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);

#ifdef DEBUG
#   define ULog(fmt, ...)  { UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%s\n [Line %d]", __PRETTY_FUNCTION__, __LINE__] message:[NSString stringWithFormat:fmt, ##__VA_ARGS__]  delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil]; [alert show]; }
#else
#   define ULog(...)
#endif

#endif
