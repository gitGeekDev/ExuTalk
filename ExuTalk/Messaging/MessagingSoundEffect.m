//
//  MessagingSoundEffect.m
//  ChitChat
//
//  Created by Manish Kumar on 05/07/14.
//  Copyright (c) 2014 Manish Kumar. All rights reserved.
//

#import "MessagingSoundEffect.h"

@interface MessagingSoundEffect ()

+ (void)playSoundWithName:(NSString *)name type:(NSString *)type;

@end



@implementation MessagingSoundEffect

+ (void)playSoundWithName:(NSString *)name type:(NSString *)type
{
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:type];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        SystemSoundID sound;
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &sound);
        AudioServicesPlaySystemSound(sound);
    }
    else {
        NSLog(@"Error: audio file not found at path: %@", path);
    }
}

+ (void)playMessageReceivedSound
{
    [MessagingSoundEffect playSoundWithName:@"messageReceived" type:@"aiff"];
}

+ (void)playMessageSentSound
{
    [MessagingSoundEffect playSoundWithName:@"messageSent" type:@"aiff"];
}
@end
