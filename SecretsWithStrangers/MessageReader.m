#import "MessageReader.h"

@implementation MessageReader

@synthesize data = _data;

- (id)initWithData:(NSData *)data {
    if ((self = [super init])) {
        _data = data;
        _offset = 0;
    }
    return self;
}

- (unsigned char)readByte {
    unsigned char retval = *((unsigned char *) (_data.bytes + _offset));
    _offset += sizeof(unsigned char);
    return retval;
}

- (int)readInt {
    int retval = *((unsigned int *) (_data.bytes + _offset));
    retval = ntohl(retval);
    _offset += sizeof(unsigned int);
    return retval;
}

- (NSString *)readString {
    int strLen = [self readInt];
    NSString *retval = [NSString stringWithCString:_data.bytes+_offset encoding:NSUTF8StringEncoding];
    _offset += strLen;
    return retval;
}

- (float) readFloat
{
    unsigned char b[4];
    
    b[0] = [self readByte];
    b[1] = [self readByte];
    b[2] = [self readByte];
    b[3] = [self readByte];
    
    float f = *((float*)(&b[0]));
    
    return f;
}

@end