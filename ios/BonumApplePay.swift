import Foundation
import PassKit

@objc(BonumApplePay)
class BonumApplePay: NSObject {

  @objc
  func presentAddPaymentPassViewController(_ cardDetails: NSDictionary, networkDetails: NSDictionary, resolver: @escaping RCTPromiseResolveBlock, rejecter: @escaping RCTPromiseRejectBlock) {
    guard let cardholderName = cardDetails["cardholderName"] as? String,
          let primaryAccountSuffix = cardDetails["primaryAccountSuffix"] as? String,
          let paymentNetworkString = cardDetails["paymentNetwork"] as? String else {
      rejecter("INVALID_PARAMETERS", "Invalid card details", nil)
      return
    }

    let paymentNetwork: PKPaymentNetwork
    switch paymentNetworkString {
    case "visa":
        paymentNetwork = .visa
    case "masterCard":
        paymentNetwork = .masterCard
    case "amex":
        paymentNetwork = .amex
    default:
        rejecter("INVALID_PAYMENT_NETWORK", "Invalid payment network", nil)
        return
    }

    guard let urlString = networkDetails["url"] as? String,
          let url = URL(string: urlString),
          let method = networkDetails["method"] as? String,
          let headers = networkDetails["header"] as? [String],
          let bodyString = networkDetails["body"] as? String else {
      rejecter("INVALID_NETWORK_DETAILS", "Invalid network details", nil)
      return
    }

    guard let bodyData = bodyString.data(using: .utf8) else {
      rejecter("INVALID_BODY", "Invalid body data", nil)
      return
    }

    let networkRequest = NetworkRequest(url: url, method: method, headers: headers, body: bodyData)

    DispatchQueue.main.async {
      let viewController = ViewControllerWallet()
      viewController.configure(cardholderName: cardholderName, primaryAccountSuffix: primaryAccountSuffix, paymentNetwork: paymentNetwork, networkRequest: networkRequest)
      
      if let rootVC = UIApplication.shared.windows.first?.rootViewController {
        rootVC.present(viewController, animated: false, completion: {
          viewController.initEnrollProcess()
        })
        resolver("SUCCESS")
      } else {
        rejecter("NO_VIEW_CONTROLLER", "Could not find a root view controller", nil)
      }
    }
  }
}

struct NetworkRequest {
    let url: URL
    let method: String
    let headers: [String]
    let body: Data
}
