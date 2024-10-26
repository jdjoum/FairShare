//
//  ContentView.swift
//  Fair Share
//
//  Created by Julian-Justin Djoum on 10/23/24.
//

import SwiftUI
import UIKit

struct ActivityViewController: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        return UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No update needed
    }
}

struct ContentView: View {
    @State private var billAmount = ""
    @State private var tipPercentage = 15.0
    @State private var numberOfPeople = 2
    @State private var isShareSheetPresented = false
    let userDefaults = UserDefaults.standard
    
    func calculateTip(billAmount: Double, tipPercentage: Double, numberOfPeople: Int) -> (amountPerPerson: Double, grandTotal: Double, tipValue: Double) {
        let peopleCount = Double(numberOfPeople)
        let tipSelection = tipPercentage / 100
        // Calculate tip value and grand total
        let tipValue = billAmount * tipSelection
        let grandTotal = billAmount + tipValue
        // Calculate amount per person
        let amountPerPerson = grandTotal / peopleCount
        return (amountPerPerson, grandTotal, tipValue)
    }
    
    var totalPerPerson: Double {
        let result = calculateTip(billAmount: Double(billAmount) ?? 0, tipPercentage: tipPercentage, numberOfPeople: numberOfPeople)
        return result.amountPerPerson
    }
    
    var totalOrderAmount: Double {
        let result = calculateTip(billAmount: Double(billAmount) ?? 0, tipPercentage: tipPercentage, numberOfPeople: numberOfPeople)
        return result.grandTotal
    }
    
    var totalTipAmount: Double {
        let result = calculateTip(billAmount: Double(billAmount) ?? 0, tipPercentage: tipPercentage, numberOfPeople: numberOfPeople)
        return result.tipValue
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Enter Bill Amount")) {
                    TextField("Amount", text: $billAmount)
                        .keyboardType(.decimalPad)
                }
                
                Section(header: Text("Tip Percentage")) {
                    Slider(value: $tipPercentage, in: 0...30, step: 1)
                    Text("\(Int(tipPercentage))%")
                }
                
                Section(header: Text("Number of People")) {
                    Stepper(value: $numberOfPeople, in: 1...20) {
                        Text("\(numberOfPeople) people")
                    }
                }
                
                Section(header: Text("Tip Amount")) {
                    Text("$\(totalTipAmount, specifier: "%.2f")")
                }
                
                Section(header: Text("Total Amount")) {
                    Text("$\(totalOrderAmount, specifier: "%.2f")")
                }
                
                Section(header: Text("Amount per Person")) {
                    Text("$\(totalPerPerson, specifier: "%.2f")")
                }
                
                Button(action: {
                    billAmount = ""
                }, label: {
                    Text("Reset")
                }).disabled(billAmount.isEmpty)
                Button(action: {
                    // Save results to local storage
                    userDefaults.set(totalTipAmount, forKey: "totalTipAmount")
                    userDefaults.set(totalOrderAmount, forKey: "totalOrderAmount")
                    userDefaults.set(totalPerPerson, forKey: "totalPerPerson")
                    let tip = userDefaults.double(forKey: "totalTipAmount")
                    let totalAmount = userDefaults.double(forKey: "totalOrderAmount")
                    let perPerson = userDefaults.double(forKey: "totalPerPerson")
                    print("tipAmount: ", tip)
                    print("totalAmount: ", totalAmount)
                    print("perPerson: ", perPerson)
                }, label: {
                    Text("Save")
                }).disabled(billAmount.isEmpty)
                Button(action: {
                    isShareSheetPresented = true
                }, label: {
                    Text("Share")
                }).disabled(billAmount.isEmpty)
                    .sheet(isPresented: $isShareSheetPresented, content: {
                        let totalTipAmount: Double = totalTipAmount
                        let totalOrderAmount: Double = totalOrderAmount
                        let totalPerPerson: Double = totalPerPerson
                        ActivityViewController(activityItems: [
                            "Bill Amount: $" + billAmount + "/n",
                            "Tip Amount: $\(totalTipAmount)/n",
                            "Total Amount: $\(totalOrderAmount)/n",
                            "Total Per Person: $\(totalPerPerson)/n"
                        ])
                    })
            }
            .navigationBarTitle("Fair Share")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView() // Replace 'ContentView' with your view's name
    }
}

