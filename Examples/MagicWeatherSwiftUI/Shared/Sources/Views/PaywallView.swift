//
//  PaywallView.swift
//  Magic Weather SwiftUI
//
//  Created by Cody Kerns on 1/19/21.
//

import SwiftUI
import RevenueCat

/*
 An example paywall that uses the current offering.
 */

struct PaywallView: View {
    
    /// - This binding is passed from ContentView: `paywallPresented`
    @Binding var isPresented: Bool
    
    /// - State for displaying an overlay view
    @State var isPurchasing: Bool = false
    
    /// - The current offering saved from PurchasesDelegateHandler
    var offering: Purchases.Offering? = UserViewModel.shared.offerings?.current
    
    #warning("Modify this value to reflect your app's Privacy Policy and Terms & Conditions agreements. Required to make it through App Review.")
    var footerText = "Don't forget to add your subscription terms and conditions. Read more about this here: https://www.revenuecat.com/blog/schedule-2-section-3-8-b"
    
    var body: some View {
        NavigationView {
            ZStack {
                /// - The paywall view list displaying each package
                List {
                    Section(header: Text("\nMagic Weather Premium"), footer: Text(footerText)) {
                        ForEach(offering?.availablePackages ?? []) { package in
                            PackageCellView(package: package) { (package) in
                                
                                /// - Set 'isPurchasing' state to `true`
                                isPurchasing = true
                                
                                /// - Purchase a package
                                Purchases.shared.purchasePackage(package) { (transaction, info, error, userCancelled) in
                                    
                                    /// - Set 'isPurchasing' state to `false`
                                    isPurchasing = false
                                    
                                    /// - If the user didn't cancel and there wasn't an error with the purchase, close the paywall
                                    if !userCancelled, error == nil {
                                        isPresented = false
                                    }
                                }
                            }
                        }
                    }
                    
                }.listStyle(InsetGroupedListStyle())
                .navigationBarTitle("✨ Magic Weather Premium")
                .navigationBarTitleDisplayMode(.inline)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.bottom)
                
                /// - Display an overlay during a purchase
                Rectangle()
                    .foregroundColor(Color.black)
                    .opacity(isPurchasing ? 0.5: 0.0)
                    .edgesIgnoringSafeArea(.all)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .colorScheme(.dark)
    }
}

/* The cell view for each package */
struct PackageCellView: View {
    let package: Purchases.Package
    let onSelection: (Purchases.Package) -> Void
    
    var body: some View {
        HStack {
            VStack {
                HStack {
                    Text(package.product.localizedTitle)
                        .font(.title3)
                        .bold()
                    
                    Spacer()
                }
                HStack {
                    Text(package.terms(for: package))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
            .padding([.top, .bottom], 8.0)
            
            Spacer()
            
            Text(package.localizedPriceString)
                .font(.title3)
                .bold()
        }.onTapGesture {
            onSelection(package)
        }
    }
}
