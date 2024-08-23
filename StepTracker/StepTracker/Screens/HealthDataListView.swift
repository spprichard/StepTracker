//
//  HealthDataListView.swift
//  StepTracker
//
//  Created by Steven Prichard on 2024-05-05.
//

import SwiftUI

struct HealthDataListView: View {
    let metric: HealthMetricContext
    
    @Environment(HealthKitManager.self)
    private var hkManager
    
    @State
    private var isShowingSheet = false
    
    @State
    private var dateToAdd = Date()
    
    @State
    private var valueToAdd = ""
    
    var data: [HealthMetric] {
        switch metric {
        case .steps:
            return hkManager.stepData
        case .weight:
            return hkManager.weightData
        case .workouts:
            return []
        }
    }
    
    var body: some View {
        List(data.reversed()) { healthMetric in
            HStack {
                Text(healthMetric.date, format: .dateTime.month().day().year())
                Spacer()
                Text(healthMetric.value,format:
                        .number
                        .precision(
                        .fractionLength(metricPercision())
                    )
                )
            }
        }
        .navigationTitle(metric.title)
        .sheet(isPresented: $isShowingSheet) {
            AddDataView()
                .presentationDetents([.fraction(0.25)])
        }
        .toolbar {
            Button("Add", systemImage: "plus") {
                isShowingSheet.toggle()
            }
        }
        
    }
    
    private func AddDataView() -> some View {
        NavigationStack {
            Form {
                DatePicker("Date", selection: $dateToAdd)
                HStack {
                    Text(metric.title)
                    Spacer()
                    TextField("Value", text: $valueToAdd)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 140)
                        .keyboardType(metricKeyboardType())
                }
            }
            .navigationTitle(metric.title)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Dismiss") {
                        isShowingSheet = false
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add Data") {
                        Task {
                            switch metric {
                            case .steps:
                                await hkManager.addStepData(
                                    for: dateToAdd,
                                    value: Double(valueToAdd)!
                                )
                                await hkManager.fetchStepCount()
                                isShowingSheet = false
                            case .weight:
                                await hkManager.addWeightData(
                                    for: dateToAdd,
                                    value: Double(valueToAdd)!
                                )
                                await hkManager.fetchWeight()
                                await hkManager.fetchWeightDiffs()
                                isShowingSheet = false
                            case .workouts:
                                // TODO: Implement
                                return
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func metricKeyboardType() -> UIKeyboardType {
        switch metric {
        case .steps, .workouts:
            .numberPad
        case .weight:
            .decimalPad
        }
    }
    
    private func metricPercision() -> Int {
        switch metric {
        case .steps, .workouts:
            0
        case .weight:
            1
        }
    }
}

#Preview("Steps") {
    NavigationStack {
        HealthDataListView(metric: .steps)
            .environment(HealthKitManager())
    }
}

#Preview("Weight") {
    NavigationStack {
        HealthDataListView(metric: .weight)
            .environment(HealthKitManager())
    }
}
