//
//  Typedefs.h
//
//  Created by Navi Singh on 11/26/12.
//
//


@class NTJSON;
typedef void (^JsonBlock) (NTJSON *json);

typedef void (^ImageBlock)(UIImage *image);
typedef void (^ErrorBlock)(NSError *error);
typedef void (^RequestBlock)(NSURLRequest *request);
typedef void (^DictionaryBlock)(NSDictionary *dictionary);
typedef void (^ArrayBlock)(NSArray *array);
typedef void (^DataBlock)(NSData *data);
typedef void (^ArrayIntBlock)(NSArray *array, NSInteger count);
typedef void (^VoidBlock)();
typedef void (^ViewControllerBlock)(UIViewController *);
typedef void (^StringBlock)(NSString *string);
typedef void (^UIntegerBlock)(NSUInteger uintValue);
typedef void (^IntegerBlock)(NSInteger intValue);
typedef void (^UnsignedLongLongBlock)(unsigned long long ullValue);
typedef void (^FloatBlock)(float floatValue);
typedef void (^NotificationBlock)(NSNotification * notification);
typedef void (^OperationBlock)(NSOperation *op);
typedef void (^UrlBlock)(NSURL *url);
typedef void (^BoolBlock)(BOOL boolValue);
typedef void (^PlacemarkBlock)(CLPlacemark *placemark);
typedef BOOL (^WhenBlock)(id);

void dispatch_operation_main(VoidBlock block);
void dispatch_sync_main(VoidBlock block);
void dispatch_async_main(VoidBlock block);
void dispatch_async_default(VoidBlock block);
void dispatch_async_high(VoidBlock block);
void dispatch_async_low(VoidBlock block);
void dispatch_after_main(NSInteger secs, VoidBlock block);

void debugOnly(VoidBlock block);
bool debugENV(char *env);
bool ENV(char *env);

#ifndef NAVI
#define NAVI ENV("NAVI")
#endif

NSString *stringFromCGRect(CGRect rect);