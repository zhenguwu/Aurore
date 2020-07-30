#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>

//static NSData *aes(NSData *data, NSData *key, CCOperation operation, CCOptions options) __attribute((optnone)) __attribute((__annotate__(("bcf")))) __attribute((__annotate__(("fla")))) __attribute((__annotate__(("indibr")))) __attribute((__annotate__(("strenc"))));
static NSData *aes(NSData *data, NSData *key, CCOperation operation, CCOptions options) {
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

//static NSData *AES128Encrypt(NSString *data) __attribute((optnone)) __attribute((__annotate__(("bcf")))) __attribute((__annotate__(("fla")))) __attribute((__annotate__(("indibr")))) __attribute((__annotate__(("strenc"))));
static NSData *AES128Encrypt(NSString *data) {
    return aes([data dataUsingEncoding:NSUTF8StringEncoding], [@"GUOU6SW1GI3ZI4HEFEPF8W50I6WTD9TX" dataUsingEncoding:NSUTF8StringEncoding], kCCEncrypt, kCCOptionPKCS7Padding);
}

//static NSString *AES128Decrypt(NSData *data) __attribute((optnone)) __attribute((__annotate__(("bcf")))) __attribute((__annotate__(("fla")))) __attribute((__annotate__(("indibr")))) __attribute((__annotate__(("strenc"))));
static NSString *AES128Decrypt(NSData *data) {
    return [[NSString alloc] initWithData:aes(data, [@"GUOU6SW1GI3ZI4HEFEPF8W50I6WTD9TX" dataUsingEncoding:NSUTF8StringEncoding], kCCDecrypt, kCCOptionPKCS7Padding) encoding:NSUTF8StringEncoding];
}