import Foundation
import PassKit

@objc(BonumApplePay)
class BonumApplePay: NSObject {

  let passLibrary = PKPassLibrary()
    

    @objc(getAllPaymentPasses:rejecter:)
    func getAllPaymentPasses(_ resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        var passesInfo = [[String: Any]]()
        let passes = passLibrary.passes()   

        for pass in passes where pass is PKPaymentPass {
            if let paymentPass = pass as? PKPaymentPass {
                 let activationState: String
                    switch paymentPass.passActivationState {
                        case .activated:
                            activationState = "Activated"
                        case .suspended:
                            activationState = "Suspended"
                        case .deactivated:
                            activationState = "Deactivated"
                        case .requiresActivation:
                            activationState = "RequiresActivation"
                        case .activating:
                            activationState = "Activating"
                        @unknown default:
                            activationState = "Unknown State"
                        }
                let passDetails: [String: Any] = [
                   "primaryAccountIdentifier": paymentPass.primaryAccountIdentifier,
                    "primaryAccountNumberSuffix": paymentPass.primaryAccountNumberSuffix,
                    "deviceAccountIdentifier": paymentPass.deviceAccountIdentifier,
                    "deviceAccountNumberSuffix": paymentPass.deviceAccountNumberSuffix,
                    "cardActivity": activationState
                ]
                passesInfo.append(passDetails)
            }
        }

        resolve(passesInfo)

    }

     @objc(getAllWatchesPass:rejecter:)
    func getAllWatchesPass(_ resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        var passesInfo = [[String: Any]]()
        let passes = passLibrary.remoteSecureElementPasses

        for pass in passes where pass is PKPaymentPass {
            if let paymentPass = pass as? PKPaymentPass {
                 let activationState: String
                    switch paymentPass.passActivationState {
                        case .activated:
                            activationState = "Activated"
                        case .suspended:
                            activationState = "Suspended"
                        case .deactivated:
                            activationState = "Deactivated"
                        case .requiresActivation:
                            activationState = "RequiresActivation"
                        case .activating:
                            activationState = "Activating"
                        @unknown default:
                            activationState = "Unknown State"
                        }
                let passDetails: [String: Any] = [
                   "primaryAccountIdentifier": paymentPass.primaryAccountIdentifier,
                    "primaryAccountNumberSuffix": paymentPass.primaryAccountNumberSuffix,
                    "deviceAccountIdentifier": paymentPass.deviceAccountIdentifier,
                    "deviceAccountNumberSuffix": paymentPass.deviceAccountNumberSuffix,
                    "cardActivity": activationState
                ]
                passesInfo.append(passDetails)
            }
        }
            resolve(passesInfo)
    }

    @objc
    func retrieveWalletInformation(_ resolver: @escaping RCTPromiseResolveBlock, rejecter: @escaping RCTPromiseRejectBlock) {
        let message = retrieveAllInformation()
        resolver(message)
    }

    private func retrieveAllInformation() -> String {
        var message = "Wallet Cards Information:\n\n"
        message += listPaymentPasses()
        message += "\n"
        message += displayAllPasses()
        message += "\n"
        message += displayAllSecureElementPassesFromWatch()
        message += "\n"
        message += checkCanAddSecureElementPass()
        return message
    }

    private func displayAllPasses() -> String {
        let allPasses = passLibrary.passes()
        var message = "Passes on this device:\n"
        
        if allPasses.isEmpty {
            message += "No passes available on this device.\n"
        } else {
            for pass in allPasses {
                message += "- passTypeIdentifier \(pass.passTypeIdentifier)"
                                message += "- passType \(pass.passType)"
                                message += "- userInfo \(String(describing: pass.userInfo))"
                                message += "- deviceName \(pass.deviceName)"
                                message += "- localizedDescription \(pass.localizedDescription)"
                                message += "- description \(pass.description)"
            }
        }
        return message
    }

    private func displayAllSecureElementPassesFromWatch() -> String {
        let secureElementPasses = passLibrary.remoteSecureElementPasses
        var message = "Secure Element Passes on paired Apple Watch:\n"
        
        if secureElementPasses.isEmpty {
            message += "No secure element\n"
        } else {
            for pass in secureElementPasses {
                message += "- Pass with primary account identifier: \(pass.primaryAccountIdentifier)\n"
            }
        }
        return message
    }

      private func listPaymentPasses() -> String {
          let passes = passLibrary.passes()
          var message = "Passes on this device:\n"
          for pass in passes where pass is PKPaymentPass {
              if let paymentPass = pass as? PKPaymentPass {
                  message += "- Pass Type Identifier: \(paymentPass.primaryAccountNumberSuffix) - Primary Account Identifier: \(paymentPass.primaryAccountIdentifier)\n"
              }
          }
          return message
      }

    private func checkCanAddSecureElementPass() -> String {
        guard let identifier = UserDefaults.standard.string(forKey: "primaryAccountIdentifier") else {
            return "No primary account identifier found in UserDefaults.\n"
        }

         guard let deviceIdentifier = UserDefaults.standard.string(forKey: "deviceAccountIdentifier") else {
            return "No device account identifier found in UserDefaults.\n"
        }

        if passLibrary.canAddSecureElementPass(primaryAccountIdentifier: identifier) {
            return "You can add the secure element pass with identifier: \(identifier) Type is: \(passLibrary.canAddSecureElementPass(primaryAccountIdentifier: deviceIdentifier))"
        } else {
            return "You cannot add the secure element Type is: \(passLibrary.canAddSecureElementPass(primaryAccountIdentifier: identifier))\n"
        }
    }

   @objc 
    func canAddSecureElementPassFunction(_ promise: RCTPromiseResolveBlock, rejector reject: RCTPromiseRejectBlock) {
        guard let identifier = UserDefaults.standard.string(forKey: "primaryAccountIdentifier") else {
                    reject("NO_IDENTIFIER", "No primary account identifier found in UserDefaults", nil)
                    return
                }
        let check = passLibrary.canAddSecureElementPass(primaryAccountIdentifier: identifier)
        promise(check)
  }

  @objc(secureElementPassExists:resolver:rejecter:)
    func secureElementPassExists(primaryAccountIdentifier: String, resolver: @escaping RCTPromiseResolveBlock, rejecter: @escaping RCTPromiseRejectBlock) {
         let check = passLibrary.canAddSecureElementPass(primaryAccountIdentifier: primaryAccountIdentifier)
        resolver(check)
    }

  @objc
  func presentAddPaymentPassViewController(_ cardDetails: NSDictionary, networkDetails: NSDictionary, resolver: @escaping RCTPromiseResolveBlock, rejecter: @escaping RCTPromiseRejectBlock) {
    guard let cardholderName = cardDetails["cardholderName"] as? String,
          let primaryAccountSuffix = cardDetails["primaryAccountSuffix"] as? String,
          let primaryAccountIdentifier = cardDetails["primaryAccountIdentifier"] as? String,

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
    print("NetworkRequest URL: \(networkRequest.url)")
    print("NetworkRequest Method: \(networkRequest.method)")
    print("NetworkRequest Headers: \(networkRequest.headers)")

    DispatchQueue.main.async {
      let viewController = ViewControllerWallet()
    //   viewController.configure(cardholderName: cardholderName, primaryAccountSuffix: primaryAccountSuffix, paymentNetwork: paymentNetwork, networkRequest: networkRequest)
     viewController.configure(cardholderName: cardholderName, primaryAccountSuffix: primaryAccountSuffix,primaryAccountIdentifier: primaryAccountIdentifier, paymentNetwork: paymentNetwork,  networkRequest: networkRequest) { success in
                if success {
                    resolver(true)
                } else {
                    resolver(false)
                }
            }
      if let rootVC = UIApplication.shared.windows.first?.rootViewController {
        rootVC.present(viewController, animated: false, completion: {
          viewController.initEnrollProcess()
        })
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
