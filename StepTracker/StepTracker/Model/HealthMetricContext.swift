//
//  HealthMetricContext.swift
//  StepTracker
//
//  Created by Steven Prichard on 2024-08-03.
//
import SwiftUI
import Foundation

enum HealthMetricContext: CaseIterable, Identifiable {
    case steps, weight, workouts
    
    var id: Self { self }
    var title: String {
        switch self {
        case .steps:
            "Steps"
        case .weight:
            "Weight"
        case .workouts:
            "Workouts"
        }
    }
    var tint: Color {
        switch self {
        case .steps:
            .pink
        case .weight:
            .indigo
        case .workouts:
            .green
        }
    }
}
