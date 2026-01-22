//
//  InterstitialAdManager.swift
//  Bitcoiner
//
//  Created by leejay100 on 1/22/26.
//

import SwiftUI
import Combine
import GoogleMobileAds

@MainActor
final class InterstitialAdManager: NSObject, ObservableObject {
    static let shared = InterstitialAdManager()
    
    @Published var isAdLoaded = false
    @Published var isLoading = false
    @Published var showThankYou = false
    
    private var interstitialAd: GADInterstitialAd?
    
    // Production Ad Unit ID
    private let adUnitID = "ca-app-pub-4880066235815559/2599320470"
    
    // Test Ad Unit ID (for development)
    #if DEBUG
    private let testAdUnitID = "ca-app-pub-3940256099942544/4411468910"
    #endif
    
    private override init() {
        super.init()
        loadAd()
    }
    
    /// Load an interstitial ad
    func loadAd() {
        guard !isLoading else { return }
        isLoading = true
        
        #if DEBUG
        let unitID = testAdUnitID
        #else
        let unitID = adUnitID
        #endif
        
        let request = GADRequest()
        
        GADInterstitialAd.load(withAdUnitID: unitID, request: request) { [weak self] ad, error in
            Task { @MainActor in
                self?.isLoading = false
                
                if let error = error {
                    print("Failed to load interstitial ad: \(error.localizedDescription)")
                    self?.isAdLoaded = false
                    return
                }
                
                self?.interstitialAd = ad
                self?.interstitialAd?.fullScreenContentDelegate = self
                self?.isAdLoaded = true
                print("Interstitial ad loaded successfully")
            }
        }
    }
    
    /// Show the interstitial ad
    func showAd() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            print("Unable to get root view controller")
            return
        }
        
        // Find the topmost presented view controller
        var topController = rootViewController
        while let presentedViewController = topController.presentedViewController {
            topController = presentedViewController
        }
        
        if let ad = interstitialAd {
            ad.present(fromRootViewController: topController)
        } else {
            print("Ad wasn't ready. Loading a new one.")
            loadAd()
        }
    }
    
    /// Check if ad is ready to show
    var isReady: Bool {
        return interstitialAd != nil
    }
}

// MARK: - GADFullScreenContentDelegate
extension InterstitialAdManager: GADFullScreenContentDelegate {
    nonisolated func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        Task { @MainActor in
            print("Interstitial ad dismissed")
            showThankYou = true
            interstitialAd = nil
            isAdLoaded = false
            
            // Reload ad for next time
            loadAd()
            
            // Hide thank you message after 3 seconds
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            showThankYou = false
        }
    }
    
    nonisolated func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        Task { @MainActor in
            print("Interstitial ad failed to present: \(error.localizedDescription)")
            interstitialAd = nil
            isAdLoaded = false
            loadAd()
        }
    }
    
    nonisolated func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Interstitial ad will present")
    }
}
