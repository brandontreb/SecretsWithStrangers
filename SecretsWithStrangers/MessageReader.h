#import <Foundation/Foundation.h>

@interface MessageReader : NSObject {
    NSData * _data;
    int _offset;
}

@property (retain, readonly) NSData *data;

- (id)initWithData:(NSData *)data;

- (unsigned char)readByte;
- (int)readInt;
- (NSString *)readString;
- (float) readFloat;

@end
