import UIKit
import PassKit

class ViewControllerWallet: UIViewController {
    var cardholderName: String?
    var primaryAccountSuffix: String?
    var primaryAccountIdentifier: String?
    var paymentNetwork: PKPaymentNetwork?
    var networkRequest: NetworkRequest?
    var onComplete: ((Bool) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    public func initEnrollProcess() {
        let card = cardInformation()
        guard let configuration = PKAddPaymentPassRequestConfiguration(encryptionScheme: .ECC_V2) else {
            showPassKitUnavailable(message: "InApp enrollment configuration fails")
            return
        }
        configuration.cardholderName = card.holder
        configuration.primaryAccountSuffix = card.panTokenSuffix
        configuration.primaryAccountIdentifier = card.primaryAccountIdentifier

        
        guard let enrollViewController = PKAddPaymentPassViewController(requestConfiguration: configuration, delegate: self) else {
            showPassKitUnavailable(message: "InApp enrollment controller configuration fails")
            return
        }
        
        present(enrollViewController, animated: true, completion: nil)
    }
    
    private func isPassKitAvailable() -> Bool {
        return PKAddPaymentPassViewController.canAddPaymentPass()
    }
    
    private func showPassKitUnavailable(message: String) {
        let alert = UIAlertController(title: "InApp Error", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
      private func cardInformation() -> Card {
        return Card(panTokenSuffix: primaryAccountSuffix ?? "0000", holder: cardholderName ?? "Unknown", cardType: paymentNetwork ?? .masterCard, primaryAccountIdentifier: primaryAccountIdentifier ?? "")
    }

    public func configure(cardholderName: String, primaryAccountSuffix: String, primaryAccountIdentifier: String?, paymentNetwork: PKPaymentNetwork, networkRequest: NetworkRequest, onComplete: @escaping (Bool) -> Void) {
        self.cardholderName = cardholderName
        self.primaryAccountSuffix = primaryAccountSuffix
        self.primaryAccountIdentifier = primaryAccountIdentifier
        self.paymentNetwork = paymentNetwork
        self.networkRequest = networkRequest
        self.onComplete = onComplete    }
    
    private func alert(message: String) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alertController, animated: true, completion: nil)
        }
    }
}

private struct Card {
    let panTokenSuffix: String
    let holder: String
    let cardType: PKPaymentNetwork
    let primaryAccountIdentifier: String?
}

extension ViewControllerWallet: PKAddPaymentPassViewControllerDelegate {
    func addPaymentPassViewController(
        _ controller: PKAddPaymentPassViewController,
        generateRequestWithCertificateChain certificates: [Data],
        nonce: Data, nonceSignature: Data,
        completionHandler handler: @escaping (PKAddPaymentPassRequest) -> Void) {
        
        let request = IssuerRequest(certificates: certificates, nonce: nonce, nonceSignature: nonceSignature)
        let interactor = GetPassKitDataIssuerHostInteractor(networkRequest: networkRequest)
        
        interactor.execute(request: request) { result in
            switch result {
            case .success(let response):
                let request = PKAddPaymentPassRequest()
                request.activationData = response.activationData
                request.ephemeralPublicKey = response.ephemeralPublicKey
                request.encryptedPassData = response.encryptedPassData
                handler(request)
            case .failure(let error):
                self.showPassKitUnavailable(message: "Failed to get response from issuer host: \(error.localizedDescription)")
            }
        }
    }
    
    func addPaymentPassViewController(_ controller: PKAddPaymentPassViewController, didFinishAdding pass: PKPaymentPass?, error: Error?) {
        controller.dismiss(animated: true) {
            if let error = error {
                print("Error: \(error.localizedDescription)")
                 self.onComplete?(false)
            } else if let pass = pass {
                let cardIdentifier = pass.primaryAccountIdentifier
                let cardDeviceIdentifier = pass.deviceAccountIdentifier
                self.storeCardIdentifier(cardIdentifier)
                self.storeCardDeviceIdentifier(cardDeviceIdentifier)
                self.alert(message: "Card added successfully! Last digits of card number: \(pass.primaryAccountNumberSuffix)")
                self.onComplete?(true)
            } else {
                self.alert(message: "Card addition was cancelled.")
                self.onComplete?(false)
            }
            self.dismiss(animated: true, completion: nil)
        }
    }

       func storeCardIdentifier(_ identifier: String?) {
            UserDefaults.standard.set(identifier, forKey: "primaryAccountIdentifier")
        }

          func storeCardDeviceIdentifier(_ identifier: String?) {
            UserDefaults.standard.set(identifier, forKey: "deviceAccountIdentifier")
        }


    public func addPaymentPassViewControllerDidFinish(_ controller: PKAddPaymentPassViewController) {
        controller.dismiss(animated: true) {
            self.alert(message: "The card addition process has completed.")
        }
    }
}

struct IssuerRequest {
    let certificates: [Data]
    let nonce: Data
    let nonceSignature: Data
}

struct IssuerResponse {
    let activationData: Data
    let ephemeralPublicKey: Data
    let encryptedPassData: Data
}

private class GetPassKitDataIssuerHostInteractor {
    let networkRequest: NetworkRequest?
    
    init(networkRequest: NetworkRequest?) {
        self.networkRequest = networkRequest
    }
    
    func execute(request: IssuerRequest, onFinish: @escaping (Result<IssuerResponse, Error>) -> Void) {
        tokenizeData(request: request, onFinish: onFinish)
    }
    
    private func tokenizeData(request: IssuerRequest, onFinish: @escaping (Result<IssuerResponse, Error>) -> Void) {
        guard let networkRequest = networkRequest else {
            onFinish(.failure(NSError(domain: "com.example", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid network request"])))
            return
        }

        let queryParams = [
            "cert": request.certificates[0].hexEncodedStringTo(),
            "nonce": request.nonce.hexEncodedStringTo(),
            "nonceSignature": request.nonceSignature.hexEncodedStringTo()
        ]
        let urlWithQuery = networkRequest.url.appending(queryParams)

        var urlRequest = URLRequest(url: urlWithQuery)
        urlRequest.httpMethod = networkRequest.method
        urlRequest.httpBody = networkRequest.body
        
        for header in networkRequest.headers {
            let components = header.split(separator: ":")
            if components.count == 2 {
                urlRequest.setValue(components[1].trimmingCharacters(in: .whitespacesAndNewlines), forHTTPHeaderField: String(components[0]))
            }
        }


        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            guard let data = data, error == nil else {
                if let error = error {
                    print("Tokenization request failed: \(error.localizedDescription)")
                    onFinish(.failure(error))
                } else {
                    let error = NSError(domain: "com.example", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data"])
                    onFinish(.failure(error))
                }
                return
            }

            do {
                print("Raw response data: ", String(data: data, encoding: .utf8) ?? "No data")
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: String],
                   let activationDataString = jsonResponse["activationData"],
                   let encryptedPassDataString = jsonResponse["encryptedPassData"],
                   let ephemeralPublicKeyString = jsonResponse["ephemeralPublicKey"],
                   let activationData = Data(base64Encoded: activationDataString),
                   let encryptedPassData = Data(base64Encoded: encryptedPassDataString),
                   let ephemeralPublicKey = Data(base64Encoded: ephemeralPublicKeyString) {
                    
                    let response = IssuerResponse(activationData: activationData, ephemeralPublicKey: ephemeralPublicKey, encryptedPassData: encryptedPassData)
                    onFinish(.success(response))
                } else {
                    print("Invalid response from tokenization server")
                    let error = NSError(domain: "com.example", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response from tokenization server"])
                    onFinish(.failure(error))
                }
            } catch {
                print("JSON parsing error: \(error)")
                onFinish(.failure(error))
            }
        }
        task.resume()
    }
}

extension Data {
    func hexEncodedStringTo() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}

extension URL {
    func appending(_ queryParams: [String: String]) -> URL {
        var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: true)!
        var queryItems = urlComponents.queryItems ?? []
        for (key, value) in queryParams {
            queryItems.append(URLQueryItem(name: key, value: value))
        }
        urlComponents.queryItems = queryItems
        return urlComponents.url!
    }
}
