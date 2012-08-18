#import "MessageWriter.h"

@implementation MessageWriter
@synthesize data = _data;

- (id)init {
    if ((self = [super init])) {
        _data = [[NSMutableData alloc] init];
    }
    return self;
}

- (void)writeBytes:(void *)bytes length:(int)length {
    [_data appendBytes:bytes length:length];
}

- (void)writeByte:(unsigned char)value {
    [self writeBytes:&value length:sizeof(value)];
}

- (void)writeInt:(int)intValue {
    int value = htonl(intValue);
    [self writeBytes:&value length:sizeof(value)];
}

- (void) writeFloat:(float) floatVal
{
    char *a;
    float f = floatVal;  // number to start with
    
    a = (char *)&f;   // point a to f's location

    char b[4];
    b[0] = a[3];
    b[1] = a[2];
    b[2] = a[1];
    b[3] = a[0];
    
    float ff = *((float*)(&a[0]));
    
    [self writeBytes:a length:sizeof(float)];
}

- (void)writeString:(NSString *)value {
    const char * utf8Value = [value UTF8String];
    int length = strlen(utf8Value) + 1; // for null terminator
    [self writeInt:length];
    [self writeBytes:(void *)utf8Value length:length];
}

- (void) writeLength
{
    int len = self.data.length;
    NSMutableData *tdata = _data;
    _data = [[NSMutableData alloc] init];
    [self writeInt:len];
    [_data appendData:tdata];
}

@end