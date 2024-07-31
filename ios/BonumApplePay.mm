#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(BonumApplePay, NSObject)

RCT_EXTERN_METHOD(retrieveWalletInformation:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(presentAddPaymentPassViewController:(NSDictionary *)cardDetails networkDetails:(NSDictionary *)networkDetails resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject )
RCT_EXTERN_METHOD(canAddSecureElementPassFunction:(RCTPromiseResolveBlock)promise rejector: (RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(getAllPaymentPasses:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(getAllWatchesPass:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(secureElementPassExists:(NSString *)primaryAccountIdentifier resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)

@end
