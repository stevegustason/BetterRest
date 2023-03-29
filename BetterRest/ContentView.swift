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
    
    // Variable to track the amount of coffee the user inputs that they drink
    @State private var coffeeAmount = 1
    
    // Set a default wake time of 7 am of the current day
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    // Variable to track the user's desired wake up time, with a default of 7 am
    @State private var wakeUp = defaultWakeTime
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    // Calculate when the person should go to bed based on their inputs and the model
    var idealBedtime: String {
        // Variable to track our bedtime
        var bedtime = ""
        
        do {
            let config = MLModelConfiguration()
            // Create an instance of our model
            let model = try SleepCalculator(configuration: config)
            
            // Grab the hour and minute components from our wakeUp variable
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            // Unwrap the hour, then convert to seconds
            let hour = (components.hour ?? 0) * 60 * 60
            // Unwrap the minute, then convert to seconds
            let minute = (components.minute ?? 0) * 60
            
            // Feed our values into CoreML, adding hour and minute and converting that to a Double for our wake, using sleepAmount as is, then converting coffeeAmount to a Double, since our model is expecting all three values to be Doubles
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            // You can subtract a value in seconds from a date, so we can subtract our actual sleep prediction from our desired wake up time
            let sleepTime = wakeUp - prediction.actualSleep
            
            // Set our ideal bedtime
            bedtime = sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            // If something goes wrong, set a title and message for our error alert and show it
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bedtime."
            showingAlert = true
        }
        // Return our ideal bedtime
        return bedtime
    }
    
    var body: some View {
        NavigationView {
            Form {
                VStack(alignment: .leading, spacing: 0) {
                    // Header and date picker for a user to select when they want to wake up. We only display the hour and minute components of the date picker and hide the label.
                    Text("When do you want to wake up?")
                        .font(.headline)
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    // Header and stepper for a user to select their desired amount of sleep. The range they can select is 1 to 20 hours of sleep, in .5 hour increments.
                    Text("Desired amount of sleep")
                        .font(.headline)
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 1...20, step: 0.5)
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    // Header and picker for a user to select how much coffee they drink per day, from 0 to 10 cups.
                    Text("Daily coffee intake")
                        .font(.headline)
                    Picker("Amount:", selection: $coffeeAmount) {
                        ForEach(1..<11) {
                            $0 == 1 ? Text("\($0) cup") : Text("\($0) cups")
                        }
                    }
                }
                VStack {
                    Text("Your ideal bedtime is:")
                        .font(.title3.bold())
                        .padding()
                    Text("\(idealBedtime)")
                        .font(.largeTitle)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
            }
            .navigationTitle("BetterRest")
            // Show our alert title and message when showingAlert is true, with an OK button
            .alert(alertTitle, isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
