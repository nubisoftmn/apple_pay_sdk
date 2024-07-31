#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(BonumApplePay, NSObject)

RCT_EXTERN_METHOD(presentAddPaymentPassViewController:(NSDictionary *)cardDetails networkDetails:(NSDictionary *)networkDetails resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)

@end
