//
//  SubscriptionManager.swift
//  IntervalTimer
//
//  Creates and maintains StoreKit 2 subscription entitlement state.
//  On init, it:
//   1) Fetches the `Product` for your subscription identifier(s).
//   2) Checks the current transaction history/entitlements to set `isSubscribed`.
//   3) Listens for any transaction updates to keep `isSubscribed` in sync.
//
//  NOTE: Replace `"com.yourcompany.intervaltimer.subscription.monthly"`
//        with the actual product identifier you configured in App Store Connect.

import Foundation
import StoreKit
import SwiftUI

@MainActor
final class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()
    
    // MARK: – Publicly Observed Properties
    
    /// True if the user currently has an active subscription (per StoreKit 2).
    @Published private(set) var isSubscribed: Bool = false
    
    /// The fetched `Product` for your subscription—assuming one in App Store Connect.
    @Published private(set) var subscriptionProduct: Product? = nil
    
    // (Optional) If you have multiple subscription tiers, you can store them in an array:
    @Published private(set) var allProducts: [Product] = []
    
    // MARK: – Internal
    
    private var updateListenerTask: Task<Void, Error>? = nil
    
    private init() {
        // Kick off fetching products and transaction‑listener as soon as this singleton is created
        Task {
            await fetchProducts()
            await updateSubscriptionStatus()
            listenForTransactions()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    // MARK: – Fetch Available Subscription Product(s)
    
    /// Call this on app launch to load your App Store Connect products.
    func fetchProducts() async {
        do {
            // Replace these identifiers with the ones you set in App Store Connect
            let identifiers: Set<String> = [
                "com.yourcompany.intervaltimer.subscription.monthly",
                // if you also have a yearly subscription, add it here:
                // "com.yourcompany.intervaltimer.subscription.yearly"
            ]
            
            let storeProducts = try await Product.products(for: identifiers)
            DispatchQueue.main.async {
                self.allProducts = storeProducts
                // Example: pick the first one as “the” subscription
                self.subscriptionProduct = storeProducts.first
            }
        } catch {
            print("❌ SubscriptionManager.fetchProducts failed: \(error.localizedDescription)")
        }
    }
    
    // MARK: – Purchase / Restore
    
    /// Attempt to purchase the given `Product` (e.g. monthly subscription).
    func purchase(_ product: Product) async throws {
        guard let purchaseResult = try? await product.purchase() else {
            throw StoreError.purchaseFailed
        }
        
        switch purchaseResult {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await transaction.finish()
            await updateSubscriptionStatus()
        case .userCancelled:
            throw StoreError.userCancelled
        case .pending:
            // The purchase is pending (e.g. Ask to Buy). Handle as needed.
            break
        @unknown default:
            break
        }
    }
    
    /// Restore any previously purchased subscription.
    func restorePurchases() async throws {
        let result = try await AppTransaction.currentEntitlements
        // If any entitlement is valid, update state:
        let isValid = result.contains { transaction in
            return isSubscription(transaction)
        }
        DispatchQueue.main.async {
            self.isSubscribed = isValid
        }
    }
    
    // MARK: – Transaction Listener
    
    /// Listen continuously for any transaction updates (purchases, renewals, cancellations).
    private func listenForTransactions() {
        updateListenerTask = Task.detached { [weak self] in
            for await result in Transaction.updates {
                guard let self = self else { return }
                do {
                    let transaction = try self.checkVerified(result)
                    // If this transaction corresponds to our subscription product:
                    if self.isSubscription(transaction) {
                        await transaction.finish()
                        await self.updateSubscriptionStatus()
                    }
                } catch {
                    print("⚠️ SubscriptionManager.listenForTransactions: unverified transaction: \(error)")
                }
            }
        }
    }
    
    // MARK: – Check Current Entitlement/Subscription Status
    
    /// On launch (or whenever you need), call this to re‑evaluate if there's an active subscription.
    func updateSubscriptionStatus() async {
        do {
            let statuses = try await AppTransaction.currentEntitlements
            let valid = statuses.contains { transaction in
                // Only honor “verified” transactions for our known subscription ID(s)
                return isSubscription(transaction)
            }
            DispatchQueue.main.async {
                self.isSubscribed = valid
            }
        } catch {
            print("❌ SubscriptionManager.updateSubscriptionStatus failed: \(error)")
            DispatchQueue.main.async {
                self.isSubscribed = false
            }
        }
    }
    
    // MARK: – Helpers
    
    /// Only treat transactions that match your subscription product ID(s) as valid
    private func isSubscription(_ transaction: Transaction) -> Bool {
        guard
            let productID = transaction.productID
        else { return false }
        
        // Compare to your IDs in App Store Connect:
        return productID == "com.yourcompany.intervaltimer.subscription.monthly"
        // or if you had multiple:  return ["com.yourcompany.intervaltimer.subscription.monthly",
        //                                "com.yourcompany.intervaltimer.subscription.yearly"].contains(productID)
    }
    
    /// Verify the transaction, throw if unverified
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let safe):    return safe
        case .unverified(_, let error):
            throw error
        }
    }
    
    enum StoreError: Error {
        case failedVerification
        case purchaseFailed
        case userCancelled
    }
}
