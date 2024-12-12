//
//  PaymentPlanView.swift
//  CartoonImages
//
//  Created by roger on 2024/12/11.
//

import SwiftUI

struct PaymentPlan: Identifiable {
    var id: String
    var type: String
    var price: String
    var pricePerDay: String
}

struct PaymentPlanView: View {
    @EnvironmentObject private var themeManager: ThemeManager

    let plans: [PaymentPlan] = [
        .init(id: "1", type: "周订阅", price: "6元", pricePerDay: "1元/天"),
        .init(id: "2", type: "月订阅", price: "14元", pricePerDay: "0.8元/天"),
        .init(id: "3", type: "年订阅", price: "222元", pricePerDay: "0.6元/天")
    ]

    @State var selectedPlan: PaymentPlan = .init(id: "1", type: "周订阅", price: "6元", pricePerDay: "1元/天")

    var body: some View {
        GeometryReader { geometry in
            let buttonWidth = (geometry.size.width - 60) / CGFloat(plans.count) // 40 for padding

            HStack(spacing: 10) {
                ForEach(self.plans, id: \.id) { plan in
                    paymentButton(for: plan)
                        .frame(width: buttonWidth, height: 105)
                        .background(selectedPlan.id == plan.id ?
                                    Color.init(hex: 0xF8FFEC) :
                                .white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(selectedPlan.id == plan.id ?
                                        Color.init(hex: 0x6CEACF) :
                                            themeManager.secondaryText, lineWidth: selectedPlan.id == plan.id ? 2 : 1)
                        )
                }
            }
            .padding(.horizontal, 20) // Add padding on both sides
        }
    }

    private func paymentButton(for plan: PaymentPlan) -> some View {
        Button(action: {
            selectedPlan = plan
        }) {
            VStack(spacing: 10) {
                Text(plan.type)
                    .font(.caption)
                    .foregroundColor(selectedPlan.id == plan.id ?
                        themeManager.text :
                        themeManager.text)
                    .padding(.top, 10)
                Text(plan.price)
                    .font(.headline)
                    .foregroundColor(selectedPlan.id == plan.id ?
                        themeManager.text :
                        themeManager.text)
                Text(plan.pricePerDay)
                    .font(.callout)
                    .foregroundColor(selectedPlan.id == plan.id ?
                        themeManager.text :
                        themeManager.text)
                    .padding(.bottom, 10)
            }
            .padding(.horizontal, 10)
        }
    }
}

#Preview {
    PaymentPlanView()
}
