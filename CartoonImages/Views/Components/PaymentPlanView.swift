//
//  PaymentPlanView.swift
//  CartoonImages
//
//  Created by roger on 2024/12/11.
//

import SwiftUI
import StoreKit

struct PaymentPlan: Identifiable {
    var id: String
    var type: String
    var price: String
    var pricePerDay: String
    
    var paymentType: PaymentPlanType {
        if id == PaymentPlanType.weekly.rawValue {
            return .weekly
        } else if id == PaymentPlanType.yearly.rawValue {
            return .yearly
        } else {
            return .monthly
        }
    }
}

struct PaymentPlanView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @State var plans: [PaymentPlan]?
    @State var selectedPlan: PaymentPlan = .init(id: "", type: "", price: "", pricePerDay: "")
    
    var body: some View {
        GeometryReader { geometry in
            if let plans = self.plans {
                let buttonWidth = (geometry.size.width - 60) / CGFloat(plans.count)
                
                HStack(spacing: 10) {
                    ForEach(plans, id: \.id) { plan in
                        paymentButton(for: plan)
                            .frame(height: 105)
                            .background(selectedPlan.id == plan.id ?
                                        themeManager.selectedPlanBackground :
                                        themeManager.planBackground)
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(selectedPlan.id == plan.id ?
                                            themeManager.selectedPlanBorder :
                                            themeManager.planBorder,
                                            lineWidth: selectedPlan.id == plan.id ? 2 : 1)
                            )
                            .cornerRadius(5)
                            .shadow(color: selectedPlan.id == plan.id ?
                                    themeManager.selectedPlanShadow :
                                    .clear,
                                    radius: 3, x: 0, y: 2)
                    }
                }
//                .padding(.horizontal, 20)
            } else {
                ProgressView()
                    .frame(width: geometry.size.width, height: 105)
            }
        }
        .frame(height: 120)
        .task {
            await loadPaymentPlans()
        }
    }
    
    private func paymentButton(for plan: PaymentPlan) -> some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedPlan = plan
                mainStore.dispatch(AppAction.payment(.selectPlan(plan.paymentType)))
            }
        }) {
            VStack(spacing: 10) {
                Text(plan.type)
                    .font(.caption)
                    .foregroundColor(selectedPlan.id == plan.id ?
                                    themeManager.selectedPlanText :
                                    themeManager.planText)
                    .padding(.top, 10)
                
                Text(plan.price)
                    .font(.headline)
                    .foregroundColor(selectedPlan.id == plan.id ?
                                    themeManager.selectedPlanText :
                                    themeManager.planText)
                
                Text(plan.pricePerDay)
                    .font(.callout)
                    .foregroundColor(selectedPlan.id == plan.id ?
                                    themeManager.selectedPlanSecondaryText :
                                    themeManager.planSecondaryText)
                    .padding(.bottom, 10)
            }
            .padding(.horizontal, 10)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func loadPaymentPlans() async {
        do {
            try await PaymentService.shared.loadProducts()
            let products = PaymentService.shared.products
            mainStore.dispatch(AppAction.payment(.updateProducts(products)))
            
            plans = products.map {
                let type = PaymentPlanType(rawValue: $0.productIdentifier)!
                return PaymentPlan(
                    id: $0.productIdentifier,
                    type: type.type,
                    price: PaymentService.shared.localizedPrice(for: $0) ?? "",
                    pricePerDay: type.per
                )
            }.sorted { lhs, rhs in
                let lhsType = PaymentPlanType(rawValue: lhs.id)!
                let rhsType = PaymentPlanType(rawValue: rhs.id)!
                return lhsType.sortOrder < rhsType.sortOrder
            }
            
            if let plans = plans, plans.count > 1 {
                withAnimation {
                    selectedPlan = plans[1]
                    mainStore.dispatch(AppAction.payment(.selectPlan(plans[1].paymentType)))
                }
            }
        } catch {
            print("Failed to load products: \(error)")
        }
    }
}
