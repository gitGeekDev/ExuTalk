//
//  NSString+Extras.m
//
//  Created by Navi Singh on 3/29/14.
//
//

#import "NSString+Extras.h"

@implementation NSString (Extras)

+ (NSString *)stringFromCGRect:(CGRect)rect
{
    NSString *desc = [NSString stringWithFormat:@"x:%4.0f y:%4.0f w:%4.0f h:%4.0f"
                      , rect.origin.x
                      , rect.origin.y
                      , rect.size.width
                      , rect.size.height
                      ];
    return desc;
}

- (NSString *)trim {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString *)firstPathComponent
{
    NSRange range = [self rangeOfString:@"/"];
    if(range.location == NSNotFound)
        return self;
    NSString *firstComponent = [self substringToIndex:range.location];
    return firstComponent;
}

- (NSString *)stringByAppendingTrailingSlash
{
    if ([self hasTrailingSlash] == NO) {
        return [self stringByAppendingString:@"/"];
    }
    return self;
}

- (NSString *)urlEncode
{
    NSString *str = [self stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return str;
}

- (NSString *)urlDecode
{
    NSString *str = [self stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return str;
}

- (NSString *)escapeAmpersands {
	return [self stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
}

- (NSString *)keyFromPath
{
    return [[self lastPathComponent] stringByRemovingTrailingSlash];
}

- (BOOL)hasTrailingSlash
{
    return [self hasSuffix:@"/"];
}

- (NSString *)stringByRemovingTrailingSlash
{
    if ([self hasTrailingSlash] != NO) {
        return [self substringToIndex:self.length - 1];
    }
    return self;
}

- (NSInteger)longValue
{
    NSNumber *number = [NSNumber numberWithLong:[self integerValue]];
    return [number longValue];
}

- (NSUInteger)unsignedIntegerValue
{
    NSNumber *number = [NSNumber numberWithLongLong:[self longLongValue]];
    return [number unsignedIntegerValue];
}

- (NSNumber *)numberWithUnsignedIntValue
{
    NSUInteger unum = [self unsignedIntegerValue];
    return [NSNumber numberWithUnsignedInteger:unum];
}

- (unsigned long long)unsignedLongLongValue
{
    NSNumber *number = [NSNumber numberWithLongLong:[self longLongValue]];
    return [number unsignedLongLongValue];
    
}
- (NSNumber *)numberWithUnsignedLongLongValue
{
    unsigned long long unum = [self unsignedLongLongValue];
    return [NSNumber numberWithUnsignedLongLong:unum];
}

- (NSString *)trimPrefix:(NSString *)prefix
{
    if ([self hasPrefix:prefix]) {
        NSString *str = [self substringFromIndex:prefix.length];
        return str;
    }
    return self;
}

- (NSString *)stripCommentsFromJSON
{
    BOOL in_string = NO;
    BOOL in_multiline_comment = NO;
    BOOL in_singleline_comment = NO;
    NSString *tmp;
    NSString *tmp2;
    NSMutableArray *new_str = [@[] mutableCopy];
    int from = 0;
    NSString *lc;
    NSString *rc;
    int lastIndex = 0;
    
    NSRegularExpression *tokenizer = [NSRegularExpression regularExpressionWithPattern:@"\"|(\\/\\*)|(\\*\\/)|(\\/\\/)|\n|\r"
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:nil];
    NSRegularExpression *magic = [NSRegularExpression regularExpressionWithPattern:@"(\\\\)*$"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:nil];
    
    NSArray *matches = [tokenizer matchesInString:self
                                          options:0
                                            range:NSMakeRange(0, self.length)];
    if ([matches count] == 0) {
        return self;
    }
    
    for (NSTextCheckingResult *match in matches) {
        NSRange range = [match range];
        tmp = [self substringWithRange:range];
        lastIndex = (int)range.location + (int)range.length;
        lc = [self substringWithRange:NSMakeRange(0, lastIndex - (int)range.length)];
        rc = [self substringWithRange:NSMakeRange(lastIndex, self.length - lastIndex)];
        
        if ( !in_multiline_comment && !in_singleline_comment ) {
            tmp2 = [lc substringWithRange:NSMakeRange(from, lc.length - from)];
            if ( !in_string ) {
                NSArray* words = [tmp2 componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                tmp2 = [words componentsJoinedByString:@""];
            }
            [new_str addObject:tmp2];
        }
        from = lastIndex;
        
        if ( [tmp hasPrefix:@"\""] && !in_multiline_comment && !in_singleline_comment) {
            NSArray *_matches = [magic matchesInString:lc
                                               options:0
                                                 range:NSMakeRange(0, lc.length)];
            
            if (_matches.count > 0 ) {
                NSTextCheckingResult *_match = _matches[0];
                NSRange _range = [_match range];
                
                if ( !in_string || _range.length%2 == 0 ) {
                    in_string = !in_string;
                }
            }
            from--;
            rc = [self substringWithRange:NSMakeRange(from, self.length - from)];
        }
        else if ( [tmp hasPrefix:@"/*"] && !in_string && !in_multiline_comment && !in_singleline_comment ) {
            in_multiline_comment = YES;
        }
        else if ( [tmp hasPrefix:@"*/"] && !in_string && in_multiline_comment && !in_singleline_comment ) {
            in_multiline_comment = NO;
        }
        else if ( [tmp hasPrefix:@"//"] && !in_string && !in_multiline_comment && !in_singleline_comment) {
            in_singleline_comment = YES;
        }
        else if ( ([tmp hasPrefix:@"\n"] || [tmp hasPrefix:@"\r"]) && !in_string && !in_multiline_comment && in_singleline_comment) {
            in_singleline_comment = NO;
        }
        else if (!in_multiline_comment && !in_singleline_comment ) {
            NSArray* words = [tmp componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
            tmp = [words componentsJoinedByString:@""];
            if (tmp && tmp.length) {
                [new_str addObject:tmp];
            }
        }
        
    }
    [new_str addObject:rc];
    
    return [new_str componentsJoinedByString:@""];
}

- (NSString *)prettifyJSON
{
    NSData *uglyData = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *uglyJSON = [NSJSONSerialization JSONObjectWithData:uglyData
                                                             options:kNilOptions
                                                               error:&error];
    if (error == nil && uglyJSON) {
        NSData *prettyData = [NSJSONSerialization dataWithJSONObject:uglyJSON
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
        if (error == nil) {
            NSString *prettyString = [[NSString alloc] initWithData:prettyData encoding:NSUTF8StringEncoding];
            return prettyString;
        }
    }
    DDLogError(@"%4d%s malformed json: %@ %@", __LINE__, __PRETTY_FUNCTION__, self, error.description);
    return self;
}

- (NSString *)minifyJSON
{
    NSData *uglyData = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *uglyJSON = [NSJSONSerialization JSONObjectWithData:uglyData
                                                             options:kNilOptions
                                                               error:&error];
    if (error == nil && uglyJSON) {
        NSData *prettyData = [NSJSONSerialization dataWithJSONObject:uglyJSON
                                                             options:0
                                                               error:&error];
        if (error == nil) {
            NSString *prettyString = [[NSString alloc] initWithData:prettyData encoding:NSUTF8StringEncoding];
            return prettyString;
        }
    }
    DDLogError(@"%4d%s malformed json: %@ %@", __LINE__, __PRETTY_FUNCTION__, self, error.description);
    return self;
}

@end


