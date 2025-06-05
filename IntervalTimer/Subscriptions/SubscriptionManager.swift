// SubscriptionManager.swift
// IntervalTimer
//
// A singleton that uses StoreKit 2 to fetch your subscription product,
// track current entitlements, and publish `isSubscribed` accordingly.
//
// NOTE: Make sure the App Store Connect product ID matches `Products.monthlyID`.

import Foundation
import StoreKit
import SwiftUI
import os

@MainActor
final class SubscriptionManager: ObservableObject {
    // ───────────────────────────────────────────────────────────────
    // Publicly Observable Properties
    // ───────────────────────────────────────────────────────────────
    @Published private(set) var isSubscribed: Bool = false
    @Published private(set) var subscriptionProduct: StoreKit.Product? = nil
    @Published private(set) var allProducts: [StoreKit.Product] = []
    
    // ───────────────────────────────────────────────────────────────
    // Internal
    // ───────────────────────────────────────────────────────────────
    private var updateListenerTask: Task<Void, Never>? = nil
    private let logger = Logger(subsystem: "org.ShapehavenInnovations.IntervalTimer", category: "SubscriptionManager")
    
    /// Singleton instance
    static let shared = SubscriptionManager()
    
    /// Private initializer to enforce singleton usage
    private init() {
        Task {
            await fetchProducts()
            await updateSubscriptionStatus()
            listenForTransactions()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    // MARK: — Product Identifiers
    
    private enum Products {
        // Replace this with your exact App Store Connect subscription product ID:
        static let monthlyID = "org.ShapehavenInnovations.IntervalTimer.subscription.monthly"
        
        // If you add a yearly tier later, you could add:
        // static let yearlyID = "org.ShapehavenInnovations.IntervalTimer.subscription.yearly"
    }
    
    // MARK: — Fetch Products
    
    /// Fetch your subscription product(s) from App Store Connect.
    func fetchProducts() async {
        do {
            let identifiers: Set<String> = [ Products.monthlyID ]
            let storeProducts = try await StoreKit.Product.products(for: identifiers)
            allProducts = storeProducts
            
            // Pick the product whose ID matches our constant
            subscriptionProduct = storeProducts.first(where: { $0.id == Products.monthlyID })
            
            if subscriptionProduct == nil {
                logger.error("No product found matching ID \(Products.monthlyID, privacy: .public)")
            }
        } catch {
            logger.error("fetchProducts failed: \(error.localizedDescription, privacy: .public)")
        }
    }
    
    // MARK: — Purchase
    
    /// Attempt to purchase the given subscription product.
    func purchase(_ product: StoreKit.Product) async throws {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verificationResult):
            // 1) Verify transaction
            let transaction = try checkVerified(verificationResult)
            // 2) Finish it so StoreKit marks it as handled
            await transaction.finish()
            // 3) Refresh subscription status
            await updateSubscriptionStatus()
            
        case .userCancelled:
            throw StoreError.userCancelled
            
        case .pending:
            // “Ask to Buy” or other deferred state: UI can show “Pending”
            logger.log("Purchase pending (Ask to Buy or deferred). Waiting for updates…")
            break
            
        @unknown default:
            logger.error("Unknown purchase result for product \(product.id, privacy: .public)")
            break
        }
    }
    
    // MARK: — Restore Purchases
    
    /// Restore any previously purchased subscription by checking current entitlements.
    func restorePurchases() async {
        let hadSubscription = await checkForActiveSubscription()
        isSubscribed = hadSubscription
        
        if !hadSubscription {
            logger.log("restorePurchases: no active subscription found.")
        }
    }
    
    // MARK: — Listen for Transaction Updates
    
    /// Continuously listen for transaction updates (renewals, revocations, etc.).
    private func listenForTransactions() {
        // Use a regular Task so we stay on @MainActor
        updateListenerTask = Task { [weak self] in
            guard let self = self else { return }
            
            for await verificationResult in StoreKit.Transaction.updates {
                do {
                    // ❌ Removed `await` here—checkVerified is synchronous
                    let transaction = try self.checkVerified(verificationResult)
                    
                    // ❌ Removed `await` here—isSubscription is synchronous
                    if self.isSubscription(transaction) {
                        // 1) Mark as finished
                        await transaction.finish()
                        // 2) Refresh subscription status
                        await self.updateSubscriptionStatus()
                        self.logger.log("Transaction update: subscription is active for \(transaction.productID, privacy: .public)")
                    }
                } catch {
                    self.logger.error("listenForTransactions: unverified transaction: \(error.localizedDescription, privacy: .public)")
                }
            }
        }
    }
    
    // MARK: — Update Subscription Status
    
    /// Re-query StoreKit for all current entitlements and update `isSubscribed`.
    func updateSubscriptionStatus() async {
        let active = await checkForActiveSubscription()
        isSubscribed = active
        
        if active {
            logger.log("updateSubscriptionStatus: subscription active.")
        } else {
            logger.log("updateSubscriptionStatus: no active subscription.")
        }
    }
    
    // MARK: — Helpers
    
    /// Returns true if there is an unexpired transaction whose productID matches our subscription ID.
    private func checkForActiveSubscription() async -> Bool {
        do {
            for await verificationResult in StoreKit.Transaction.currentEntitlements {
                // ❌ Removed `await` here—checkVerified is synchronous
                let transaction = try checkVerified(verificationResult)
                if isSubscription(transaction) {
                    return true
                }
            }
        } catch {
            logger.error("checkForActiveSubscription failed: \(error.localizedDescription, privacy: .public)")
        }
        return false
    }
    
    /// Returns true if the transaction’s `productID` matches our subscription ID.
    private func isSubscription(_ transaction: StoreKit.Transaction) -> Bool {
        return transaction.productID == Products.monthlyID
    }
    
    /// Verify a StoreKit 2 transaction. If unverified, throw its error.
    private func checkVerified<T>(
        _ result: StoreKit.VerificationResult<T>
    ) throws -> T {
        switch result {
        case .verified(let safe):
            return safe
        case .unverified(_, let error):
            throw error
        }
    }
    
    enum StoreError: Error {
        case userCancelled
    }
}

