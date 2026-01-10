import Foundation
import StoreKit
import Combine

@MainActor
class StoreManager: ObservableObject {
    @Published var products: [Product] = []
    @Published var purchasedProductIDs: Set<String> = []
    
    // Example Product IDs - in a real app, these would be in App Store Connect
    private let productDict: [String: String] = [
        "com.solarRise.sundrops.100": "100 Sun Drops",
        "com.solarRise.sundrops.500": "500 Sun Drops",
        "com.solarRise.sundrops.1000": "1000 Sun Drops"
    ]
    
    var updateListenerTask: Task<Void, Error>? = nil

    init() {
        // Start listening for transaction updates
        updateListenerTask = listenForTransactions()
    }

    deinit {
        updateListenerTask?.cancel()
    }

    func requestProducts() async {
        do {
            // Using the keys from the dictionary
            let storeProducts = try await Product.products(for: productDict.keys)
            self.products = storeProducts
        } catch {
            print("Failed to load products: \(error)")
        }
    }

    func purchase(_ product: Product) async throws {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            // Check whether the transaction is verified. If it isn't,
            // this function rethrows the verification error.
            let transaction = try checkVerified(verification)
            
            // The transaction is verified. Deliver content to the user.
            await updateCustomerProductStatus()
            
            // Always finish a transaction.
            await transaction.finish()
            
        case .userCancelled, .pending:
            break
        default:
            break
        }
    }
    
    // Listen for transactions outside of the purchase flow (e.g. renewals, deferred)
    func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    
                    // Deliver content to the user.
                    await self.updateCustomerProductStatus()
                    
                    // Always finish a transaction.
                    await transaction.finish()
                } catch {
                    print("Transaction failed verification")
                }
            }
        }
    }

    nonisolated func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        // Check whether the JWS passes StoreKit verification.
        switch result {
        case .unverified:
            // StoreKit parses the JWS, but it fails verification.
            throw StoreError.failedVerification
        case .verified(let safe):
            // The result is verified. Return the unwrapped value.
            return safe
        }
    }

    @MainActor
    func updateCustomerProductStatus() async {
        // iterate over current entitlements
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                // Here we would add the logic to increment the Sun Drops balance
                // For MVP, we'll just track IDs.
                // In a real app, Consumables aren't usually in 'currentEntitlements' unless persisted locally or valid.
                // StoreKit 2 Consumables are tricky; usually you handle them right at 'purchase' or 'updates'.
                // For this template, we assume we handled it in purchase/updates.
                print("Restored/Found transaction: \(transaction.productID)")
            } catch {
                print("Failed verification")
            }
        }
    }
}

enum StoreError: Error {
    case failedVerification
}
