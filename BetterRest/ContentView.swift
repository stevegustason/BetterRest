//
//  ContentView.swift
//  BetterRest
//
//  Created by Steven Gustason on 3/26/23.
//

// Import our CoreML functionality
import CoreML
import SwiftUI

struct ContentView: View {
    // Variable to track the amount of sleep the user inputs that they would like to get
    @State private var sleepAmount = 8.0
    // Variable to track the user's desired wake up time
    @State private var wakeUp = Date.now
    // Variable to track the amount of coffee the user inputs that they drink
    @State private var coffeeAmount = 1
    
    //
    func calculateBedtime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
        } catch {
            
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Header and date picker for a user to select when they want to wake up. We only display the hour and minute components of the date picker and hide the label.
                Text("When do you want to wake up?")
                    .font(.headline)
                DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                
                // Header and stepper for a user to select their desired amount of sleep. The range they can select is 1 to 20 hours of sleep, in .5 hour increments.
                Text("Desired amount of sleep")
                    .font(.headline)
                Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 1...20, step: 0.5)
                
                // Header and stepper for a user to select how much coffee they drink per day, from 0 to 20 cups.
                Text("Daily coffee intake")
                    .font(.headline)
                Stepper(coffeeAmount == 1 ? "1 cup" : "\(coffeeAmount) cups", value: $coffeeAmount, in: 0...20)
            }
            .navigationTitle("BetterRest")
            // Adds a button to the top of our app to use the calculateBedtime function to calculate the output based on the user's inputs.
            .toolbar {
                Button("Calculate", action: calculateBedtime)
            }
            .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
