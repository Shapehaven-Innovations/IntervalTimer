//
//  SubscriptionView.swift
//  IntervalTimer
//
//  A simple “paywall” screen. When `isSubscribed == false`, this view
//  is shown. It displays your subscription product, lets the user purchase
//  or restore, and auto‐dismisses once `SubscriptionManager.shared.isSubscribed` flips to true.
//

import SwiftUI
import StoreKit

struct SubscriptionView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var subManager = SubscriptionManager.shared

    @State private var purchaseErrorMessage: String?
    @State private var isPurchasing: Bool = false

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("Unlock Full Access")
                    .font(.largeTitle).bold()
                    .padding(.top, 40)

                Text("Purchase a subscription to continue using IntervalTimer.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                // If products have already been fetched, show them; otherwise show a spinner.
                if let product = subManager.subscriptionProduct {
                    VStack(spacing: 16) {
                        // 1) Show product name (e.g. “Monthly Subscription”)
                        Text(product.displayName)
                            .font(.title2).bold()

                        // 2) Show localized price (e.g. “$4.99 / month”)
                        Text(product.displayPrice)
                            .font(.title3)
                            .foregroundColor(.secondary)

                        // 3) “Subscribe Now” button
                        Button {
                            Task {
                                await startPurchase(product)
                            }
                        } label: {
                            HStack {
                                if isPurchasing {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle())
                                        .scaleEffect(0.75)
                                        .padding(.trailing, 8)
                                }
                                Text(isPurchasing ? "Purchasing …" : "Subscribe Now")
                                    .font(.headline)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                            }
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .disabled(isPurchasing)
                    }
                    .padding()
                } else {
                    ProgressView("Loading …")
                        .padding()
                }

                Button("Restore Purchases") {
                    Task {
                        await doRestore()
                    }
                }
                .padding(.top, 8)

                if let errorMsg = purchaseErrorMessage {
                    Text(errorMsg)
                        .font(.footnote)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Subscribe")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        // Only allow dismiss if the user is already subscribed
                        if subManager.isSubscribed {
                            dismiss()
                        }
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
        .onReceive(subManager.$isSubscribed) { subscribed in
            // As soon as subscription becomes valid, automatically dismiss this view
            if subscribed {
                dismiss()
            }
        }
    }

    // MARK: — Actions

    private func startPurchase(_ product: StoreKit.Product) async {
        isPurchasing = true
        purchaseErrorMessage = nil

        do {
            try await subManager.purchase(product)
            // If successful, `subManager.isSubscribed` becomes true automatically.
        } catch SubscriptionManager.StoreError.userCancelled {
            // The user tapped “Cancel” in the App Store sheet — no error needed.
        } catch {
            purchaseErrorMessage = "Purchase failed: \(error.localizedDescription)"
        }

        isPurchasing = false
    }

    private func doRestore() async {
        do {
            try await subManager.restorePurchases()
        } catch {
            purchaseErrorMessage = "Restore failed: \(error.localizedDescription)"
        }
    }
}

struct SubscriptionView_Previews: PreviewProvider {
    static var previews: some View {
        SubscriptionView()
            .preferredColorScheme(.light)
    }
}

