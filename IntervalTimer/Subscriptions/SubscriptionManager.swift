//
//  SubscriptionManager.swift
//  IntervalTimer
//
//  A singleton that uses StoreKit 2 to fetch your subscription product,
//  track current entitlements, and publish `isSubscribed` accordingly.
//
//  NOTE: Replace “com.yourcompany.intervaltimer.subscription.monthly” with
//  your actual subscription product identifier from App Store Connect.
//

import Foundation
import StoreKit
import SwiftUI

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

    /// Singleton instance
    static let shared = SubscriptionManager()

    /// Private initializer to enforce singleton usage
    private init() {
        // Kick off async tasks:
        Task {
            await fetchProducts()
            await updateSubscriptionStatus()
            listenForTransactions()
        }
    }

    deinit {
        updateListenerTask?.cancel()
    }

    // MARK: — Fetch Products

    /// Fetch your subscription product(s) from App Store Connect.
    func fetchProducts() async {
        do {
            let identifiers: Set<String> = [
                "org.ShapehavenInnovations.IntervalTimer.subscription.monthly"
                // Add additional IDs here if you have e.g. a yearly tier:
                // "com.yourcompany.intervaltimer.subscription.yearly"
            ]

            let storeProducts = try await StoreKit.Product.products(for: identifiers)
            allProducts = storeProducts
            subscriptionProduct = storeProducts.first
        } catch {
            print("❌ SubscriptionManager.fetchProducts failed: \(error.localizedDescription)")
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
            // “Ask to Buy” or other pending state; handle if necessary.
            break

        @unknown default:
            break
        }
    }

    // MARK: — Restore Purchases

    /// Restore any previously purchased subscription by checking current entitlements.
    func restorePurchases() async throws {
        var foundValid = false

        for await verificationResult in StoreKit.Transaction.currentEntitlements {
            let transaction = try checkVerified(verificationResult)
            if isSubscription(transaction) {
                foundValid = true
                break
            }
        }

        isSubscribed = foundValid
    }

    // MARK: — Listen for Transaction Updates

    /// Continuously listen for transaction updates (renewals, revocations, etc.).
    private func listenForTransactions() {
        updateListenerTask = Task.detached { [weak self] in
            guard let self = self else { return }

            for await verificationResult in StoreKit.Transaction.updates {
                do {
                    let transaction = try await self.checkVerified(verificationResult)
                    if await self.isSubscription(transaction) {
                        // 1) Mark as finished
                        await transaction.finish()
                        // 2) Refresh subscription status (on main actor)
                        await self.updateSubscriptionStatus()
                    }
                } catch {
                    print("⚠️ SubscriptionManager.listenForTransactions: unverified transaction: \(error)")
                }
            }
        }
    }

    // MARK: — Update Subscription Status

    /// Re-query StoreKit for all current entitlements and update `isSubscribed`.
    func updateSubscriptionStatus() async {
        do {
            var foundValid = false

            for await verificationResult in StoreKit.Transaction.currentEntitlements {
                let transaction = try checkVerified(verificationResult)
                if isSubscription(transaction) {
                    foundValid = true
                    break
                }
            }

            isSubscribed = foundValid
        } catch {
            print("❌ SubscriptionManager.updateSubscriptionStatus failed: \(error.localizedDescription)")
            isSubscribed = false
        }
    }

    // MARK: — Helpers

    /// Returns true if the transaction’s `productID` matches your subscription ID.
    private func isSubscription(_ transaction: StoreKit.Transaction) -> Bool {
        return transaction.productID == "com.yourcompany.intervaltimer.subscription.monthly"
        // If you have multiple subscription IDs, you can do:
        // return ["com.yourcompany.intervaltimer.subscription.monthly",
        //         "com.yourcompany.intervaltimer.subscription.yearly"]
        //         .contains(transaction.productID)
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

