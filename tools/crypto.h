#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>

NSData *aes(NSData *data, NSData *key, CCOperation operation, CCOptions options) {
    uint32_t const data_length  = (uint32_t) [data length];
    uint32_t const out_capacity = (int)(data_length / kCCBlockSizeAES128 + 1) * kCCBlockSizeAES128;

    NSMutableData * output = [NSMutableData dataWithLength:out_capacity];

    size_t bytes_written;

    CCCryptorStatus ccStatus = CCCrypt(
        operation, kCCAlgorithmAES128, options,
        (char const *)  [key bytes], [key length],
        [key bytes], // Initialization Vector (IV)
        (void const *)  [data bytes], data_length,
        (void *)        [output mutableBytes],
        out_capacity,
        &bytes_written
    );

    if (bytes_written < out_capacity) {
        [output setLength:bytes_written];
    }

    return ccStatus == kCCSuccess ? output : nil;
}

NSData *AES128Encrypt(NSString *data) {
    return aes([data dataUsingEncoding:NSUTF8StringEncoding], [@"42BC57252AW5F093BB5C09E8AB25BC69" dataUsingEncoding:NSUTF8StringEncoding], kCCEncrypt, kCCOptionPKCS7Padding);
}

NSString *AES128Decrypt(NSData *data) {
    return [[NSString alloc] initWithData:aes(data, [@"42BC57252AW5F093BB5C09E8AB25BC69" dataUsingEncoding:NSUTF8StringEncoding], kCCDecrypt, kCCOptionPKCS7Padding) encoding:NSUTF8StringEncoding];
}