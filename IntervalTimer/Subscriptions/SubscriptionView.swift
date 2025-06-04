//
//  SubscriptionView.swift
//  IntervalTimer
//
//  A simple “paywall” screen that the user sees whenever isSubscribed == false.
//  It lists available subscription products (e.g. monthly), lets the user purchase or restore,
//  and automatically dismisses itself once `SubscriptionManager.shared.isSubscribed` flips to true.

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
                
                if let product = subManager.subscriptionProduct {
                    VStack(spacing: 16) {
                        // Show price and name
                        Text(product.displayName)
                            .font(.title2).bold()
                        
                        Text(product.displayPrice)
                            .font(.title3)
                            .foregroundColor(.secondary)
                        
                        Button(action: startPurchase) {
                            HStack {
                                if isPurchasing {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle())
                                        .scaleEffect(0.75)
                                        .padding(.trailing, 8)
                                }
                                Text(isPurchasing ? "Purchasing …" : "Subscribe Now")
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
                    ProgressView("Loading …")
                        .padding()
                }
                
                Button("Restore Purchases") {
                    Task { await doRestore() }
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
                // If user tries to dismiss without subscribing, re‑present paywall:
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        // Make sure `isSubscribed` is still false; if it is, don’t dismiss.
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
            // As soon as subscription is confirmed, dismiss the paywall.
            if subscribed {
                dismiss()
            }
        }
    }
    
    // MARK: – Actions
    
    private func startPurchase() {
        guard let product = subManager.subscriptionProduct else { return }
        isPurchasing = true
        purchaseErrorMessage = nil
        
        Task {
            do {
                try await subManager.purchase(product)
                // If the purchase succeeded, `isSubscribed` will flip automatically.
            } catch SubscriptionManager.StoreError.userCancelled {
                // User tapped “Cancel” in App Store popup. No need to show an error.
            } catch {
                purchaseErrorMessage = "Purchase failed: \(error.localizedDescription)"
            }
            isPurchasing = false
        }
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
