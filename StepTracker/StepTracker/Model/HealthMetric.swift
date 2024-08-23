//
//  HealthMetric.swift
//  StepTracker
//
//  Created by Steven Prichard on 2024-05-11.
//

import Foundation

struct HealthMetric: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}
