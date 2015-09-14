//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "NSString+HLSExtensionsTestCase.h"

@implementation NSString_HLSExtensionsTestCase

#pragma mark Tests

- (void)testTrim
{
    NSString *string = [NSString stringWithFormat:@" \t    Hello, World!    \t   "];
    XCTAssertEqualObjects([string stringByTrimmingWhitespaces], @"Hello, World!");
    
    XCTAssertFalse([@"" isFilled]);
    XCTAssertFalse([@"     \t  " isFilled]);
    XCTAssertTrue([@"  abc  " isFilled]);
}

- (void)testHashMethods
{
    XCTAssertEqualObjects([@"Hello, World!" md2hash], @"1c8f1e6a94aaa7145210bf90bb52871a");
    XCTAssertEqualObjects([@"Hello, World!" md4hash], @"94e3cb0fa9aa7a5ee3db74b79e915989");
    XCTAssertEqualObjects([@"Hello, World!" md5hash], @"65a8e27d8879283831b664bd8b7f0ad4");
    XCTAssertEqualObjects([@"Hello, World!" sha1hash], @"0a0a9f2a6772942557ab5355d76af442f8f65e01");
    XCTAssertEqualObjects([@"Hello, World!" sha224hash], @"72a23dfa411ba6fde01dbfabf3b00a709c93ebf273dc29e2d8b261ff");
    XCTAssertEqualObjects([@"Hello, World!" sha256hash], @"dffd6021bb2bd5b0af676290809ec3a53191dd81c7f70a4b28688a362182986f");
    XCTAssertEqualObjects([@"Hello, World!" sha384hash], @"5485cc9b3365b4305dfb4e8337e0a598a574f8242bf17289e0dd6c20a3cd44a089de16ab4ab308f63e44b1170eb5f515");
    XCTAssertEqualObjects([@"Hello, World!" sha512hash], @"374d794a95cdcfd8b35993185fef9ba368f160d8daf432d08ba9f1ed1e5abe6cc69291e0fa2fe0006a52570ef18c19def4e617c33ce52ef0a6e5fbe318cb0387");
}

- (void)testFriendlyVersionNumber
{
    XCTAssertEqualObjects([@"0.8" friendlyVersionNumber], @"0.8");
    XCTAssertEqualObjects([@"0.8+dev" friendlyVersionNumber], @"0.8+dev");
    XCTAssertEqualObjects([@"0.9+1.0b1" friendlyVersionNumber], @"1.0b1");
    XCTAssertEqualObjects([@"0.9+1.0b1+dev" friendlyVersionNumber], @"0.9+1.0b1+dev");
    XCTAssertEqualObjects([@"0.9.1+1.0rc2" friendlyVersionNumber], @"1.0rc2");
    XCTAssertEqualObjects([@"1.0" friendlyVersionNumber], @"1.0");
    XCTAssertEqualObjects([@"1.0+test" friendlyVersionNumber], @"1.0+test");
}

- (void)testURLEncoding
{
    // The default encoding used for @"%c" changes between iOS versions. This affects string construction or NSLog display
    // when a %c is used, for the extended ASCII extended table. In other words, this means that the result of NSLog(@"%c", 135),
    // for example, differs depending on the iOS version:
    //   - iOS 6: Mac OS Roman encoding is used
    //   - iOS 7: UTF-8 encoding is used
    // To avoid this issue, we can avoid %s and use NSLog(@"\u0135"), which forces unicode encoding, but this cannot be
    // used for control characters (this generates a compiler error). Therefore, we build the test string corresponding
    // to the first half of the table (containing control characters) using %c (since there is no encoding issue there),
    // and the remaining half using \u
    //
    // Remark: I expected +[NSString defaultCStringEncoding] to return UTF-8 on iOS >= 7, but this is not the case. Maybe I
    //         haven't clearlay understood what this method does, or there is a bug somewhere
    
    // First half of the ASCII table
    NSMutableString *string = [NSMutableString string];
    for (UniChar character = 0; character < 128; character++) {
        [string appendFormat:@"%c", character];
    }
    
    // Extended ASCII table
    [string appendString:@"\u0128\u0129\u0130\u0131\u0132\u0133\u0134\u0135\u0136\u0137\u0138\u0139\u0140\u0141\u0142\u0143\u0144\u0145\u0146\u0147\u0148\u0149\u0150\u0151\u0152\u0153\u0154\u0155\u0156\u0157\u0158\u0159\u0160\u0161\u0162\u0163\u0164\u0165\u0166\u0167\u0168\u0169\u0170\u0171\u0172\u0173\u0174\u0175\u0176\u0177\u0178\u0179\u0180\u0181\u0182\u0183\u0184\u0185\u0186\u0187\u0188\u0189\u0190\u0191\u0192\u0193\u0194\u0195\u0196\u0197\u0198\u0199\u0200\u0201\u0202\u0203\u0204\u0205\u0206\u0207\u0208\u0209\u0210\u0211\u0212\u0213\u0214\u0215\u0216\u0217\u0218\u0219\u0220\u0221\u0222\u0223\u0224\u0225\u0226\u0227\u0228\u0229\u0230\u0231\u0232\u0233\u0234\u0235\u0236\u0237\u0238\u0239\u0240\u0241\u0242\u0243\u0244\u0245\u0246\u0247\u0248\u0249\u0250\u0251\u0252\u0253\u0254\u0255"];
    
    NSString *encodedStringReference = @"%01%02%03%04%05%06%07%08%09%0A%0B%0C%0D%0E%0F%10%11%12%13%14%15%16%17%18%19%1A%1B%1C%1D%1E%1F%20%21%22%23%24%25%26%27%28%29%2A%2B%2C-.%2F0123456789%3A%3B%3C%3D%3E%3F%40ABCDEFGHIJKLMNOPQRSTUVWXYZ%5B%5C%5D%5E_%60abcdefghijklmnopqrstuvwxyz%7B%7C%7D~%7F%C4%A8%C4%A9%C4%B0%C4%B1%C4%B2%C4%B3%C4%B4%C4%B5%C4%B6%C4%B7%C4%B8%C4%B9%C5%80%C5%81%C5%82%C5%83%C5%84%C5%85%C5%86%C5%87%C5%88%C5%89%C5%90%C5%91%C5%92%C5%93%C5%94%C5%95%C5%96%C5%97%C5%98%C5%99%C5%A0%C5%A1%C5%A2%C5%A3%C5%A4%C5%A5%C5%A6%C5%A7%C5%A8%C5%A9%C5%B0%C5%B1%C5%B2%C5%B3%C5%B4%C5%B5%C5%B6%C5%B7%C5%B8%C5%B9%C6%80%C6%81%C6%82%C6%83%C6%84%C6%85%C6%86%C6%87%C6%88%C6%89%C6%90%C6%91%C6%92%C6%93%C6%94%C6%95%C6%96%C6%97%C6%98%C6%99%C8%80%C8%81%C8%82%C8%83%C8%84%C8%85%C8%86%C8%87%C8%88%C8%89%C8%90%C8%91%C8%92%C8%93%C8%94%C8%95%C8%96%C8%97%C8%98%C8%99%C8%A0%C8%A1%C8%A2%C8%A3%C8%A4%C8%A5%C8%A6%C8%A7%C8%A8%C8%A9%C8%B0%C8%B1%C8%B2%C8%B3%C8%B4%C8%B5%C8%B6%C8%B7%C8%B8%C8%B9%C9%80%C9%81%C9%82%C9%83%C9%84%C9%85%C9%86%C9%87%C9%88%C9%89%C9%90%C9%91%C9%92%C9%93%C9%94%C9%95";
    XCTAssertEqualObjects([string urlEncodedStringUsingEncoding:NSUTF8StringEncoding], encodedStringReference);
}

- (void)testMIMEType
{
    XCTAssertEqualObjects([@"/path/to/file.png" MIMEType], @"image/png");
    XCTAssertEqualObjects([@"/path/to/file.PNG" MIMEType], @"image/png");
    XCTAssertEqualObjects([@"/path/to/file.jpg" MIMEType], @"image/jpeg");
    XCTAssertEqualObjects([@"/path/to/file.JPG" MIMEType], @"image/jpeg");
    XCTAssertEqualObjects([@"/path/to/file.txt" MIMEType], @"text/plain");
    XCTAssertEqualObjects([@"/path/to/file.TXT" MIMEType], @"text/plain");
    XCTAssertEqualObjects([@"/path/to/file.pdf" MIMEType], @"application/pdf");
    XCTAssertEqualObjects([@"/path/to/file.PDF" MIMEType], @"application/pdf");
}

@end
