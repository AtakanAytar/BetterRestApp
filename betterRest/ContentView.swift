//
//  ContentView.swift
//  betterRest
//
//  Created by Atakan Aytar on 30.08.2023.
//

import SwiftUI
import CoreML

struct ContentView: View {
    
    @State private var wakeUp = defaulWakeTime
    @State private var sleepAmount = 6.0
    @State private var coffeeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alerMessage = ""
    @State private var alertShowing = false
    
    static var defaulWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    var body: some View {
        NavigationView{
            VStack{
                
                Form{
                    VStack(alignment: .leading){
                        Text("When do you want to wake up? ").font(.headline)
                        DatePicker("Please Enter a time",selection: $wakeUp,displayedComponents: .hourAndMinute).labelsHidden()
                    }
                    VStack(alignment: .leading){
                        Text("Desired amount of sleep").font(.headline)
                        Stepper("\(sleepAmount.formatted()) hours",value: $sleepAmount,in: 1...12 ,step: 0.25)
                    }
                    
                    VStack(alignment: .leading){
                        Text("Daily coffee intake").font(.headline)
                        
                        Stepper(coffeeAmount==1 ? "1 cup" : "\(coffeeAmount) cups",value: $coffeeAmount,in: 1...25)

                    }
                    
                 
                }
               
            }
            .navigationTitle("Better Rest")
            .toolbar {
                Button("Calculate", action: calcBedTime)
            }
            .alert(alertTitle,isPresented: $alertShowing){
                Button("Ok"){
                    
                }
            }message: {
                Text(alerMessage)
            }
        }
    }
    
    func calcBedTime(){
        do{
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour,.minute], from: wakeUp)
            
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: Double(sleepAmount), coffee:Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            alertTitle = "Your ideal bed time is"
            alerMessage = sleepTime.formatted(date: .omitted, time: .shortened)
        }
        catch{
            alertTitle = "Error"
            alerMessage = "Sorry there was a problem"
        }
        
        alertShowing = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
