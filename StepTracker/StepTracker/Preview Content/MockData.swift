//
//  MockData.swift
//  StepTracker
//
//  Created by Steven Prichard on 2024-06-07.
//

import HealthKit
import Foundation

#if targetEnvironment(simulator)
struct MockData {
    static var steps: [HealthMetric] {
        var data: [HealthMetric] = []
        let calendar = Calendar.current
        
        for i in 0..<28 {
            let metric = HealthMetric(
                date: calendar.date(
                    byAdding: .day,
                    value: -i,
                    to: .now
                )!,
                value: .random(in: 4_000...15_000)
            )
            data.append(metric)
        }
        
        return data
    }
    
    static var weights: [HealthMetric] {
        var data: [HealthMetric] = []
        let calendar = Calendar.current
        
        for i in 0..<28 {
            let metric = HealthMetric(
                date: calendar.date(
                    byAdding: .day,
                    value: -i,
                    to: .now
                )!,
                value: .random(in: (160 + Double(i/3)...(165 + Double(i/3))))
            )
            data.append(metric)
        }
        
        return data
    }
}

extension HealthKitManager {
    func addSimulatorData() async {
        var mockSamples: [HKQuantitySample] = []
        
        for i in 0..<28 {
            let stepQuantity = HKQuantity(unit: .count(), doubleValue: .random(in: 4_000...20_000))
            let startDate = Calendar.current.date(byAdding: .day, value: -i, to: .now)!
            let stepSample = HKQuantitySample(
                type: .init(.stepCount),
                quantity: stepQuantity,
                start: startDate,
                end: startDate
            )
            mockSamples.append(stepSample)
            
            let weightQuantity = HKQuantity(unit: .pound(), doubleValue: .random(in: (160 + Double(i/3)...(165 + Double(i/3)))))
            let weightSample = HKQuantitySample(
                type: .init(.bodyMass),
                quantity: weightQuantity,
                start: startDate,
                end: startDate
            )
            mockSamples.append(weightSample)
        }
        
        do {
            try await store.save(mockSamples)
            print("ℹ️ Uploaded Health Store with mock data")
        } catch(let error) {
            fatalError("❌ Failed creating mock samples: \(error.localizedDescription)")
        }
        
    }
}
#endif
