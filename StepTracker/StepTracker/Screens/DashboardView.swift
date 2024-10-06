//
//  DashboardView.swift
//  StepTracker
//
//  Created by Steven Prichard on 2024-05-05.
//

import Charts
import SwiftUI

struct DashboardView: View {
    @Environment(HealthKitManager.self)
    private var hkManager
    
    @State
    private var isShowingPermissionSheet = false
    
    @State
    private var selectedStat: HealthMetricContext = .steps
    
    @State
    private var rawSelectedDate: Date?
    
    private var selectedHealthMetric: HealthMetric? {
        guard let rawSelectedDate else { return nil }
        return hkManager.stepData.first {
            Calendar.current.isDate(rawSelectedDate, inSameDayAs: $0.date)
        }
    }
    
    var averageStepCount: Double {
        guard !hkManager.stepData.isEmpty else {
            return 0
        }
        let stepSum = hkManager.stepData.reduce(0) { $0 + $1.value }
        return stepSum / Double(hkManager.stepData.count)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Picker("Selected State", selection: $selectedStat) {
                        ForEach(HealthMetricContext.allCases) { metric in
                            Text(metric.title)
                        }
                    }.pickerStyle(.segmented)
                    
                    switch selectedStat {
                    case .steps:
                        StepBarChart(
                            selectedStat: .steps,
                            chartData: hkManager.stepData
                        )
                        
                        StepPieChart(
                            chartData:
                                ChartMath.averageWeekDayCount(
                                    for: hkManager.stepData
                                )
                        )
                    case .weight:
                        WeightLineChart(
                            selectedStat: .weight,
                            chartData: hkManager.weightData
                        )
                        
                        WeightDifferenceBarChart(
                            chartData: ChartMath.averageDailyWeightsDiffs(
                                for: hkManager.weightDiffData
                            )
                        )
                    case .workouts:
                        ContentUnavailableView(
                            "Feature Not Ready",
                            systemImage: "scalemass.fill"
                        )
                    }
                }
            }
            .padding()
            .task {
                do {
                    try await hkManager.fetchStepCount()
                    try await hkManager.fetchWeight()
                    try await hkManager.fetchWeightDiffs()
                }
                catch STError.healthKitAccessNotDetermined {
                    isShowingPermissionSheet = true
                }
                catch STError.noData {
                    print("❌ No Data")
                }
                catch {
                    
                }
                
            }
            .navigationTitle("Dasboard")
            .navigationDestination(for: HealthMetricContext.self) { metric in
                HealthDataListView(metric: selectedStat, isShowingPermissionPriming: $isShowingPermissionSheet)
            }
            .sheet(isPresented: $isShowingPermissionSheet,
                   onDismiss: {
                // TODO: Fetch Health Data
            },
               content: {
                HealthKitPermissionView()
            }
            )
        }
        .tint(selectedStat.tint)
    }
    
    @ViewBuilder
    func AnnotationView() -> some View {
        VStack {
            Text(selectedHealthMetric?.date ?? .now, format: .dateTime.weekday(.abbreviated).month(.abbreviated))
                .font(.footnote.bold())
                .foregroundStyle(.secondary)
            Text(selectedHealthMetric?.value ?? 0, format: .number.precision(.fractionLength(0)))
                .fontWeight(.heavy)
                .foregroundStyle(.pink)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: .secondary.opacity(0.45), radius: 2, x: 2, y: 2)
        )
    }
}

#Preview {
    DashboardView()
        .environment(HealthKitManager())
}
