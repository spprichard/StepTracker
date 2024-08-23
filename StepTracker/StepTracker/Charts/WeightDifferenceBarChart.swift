//
//  WeightDifferenceChart.swift
//  StepTracker
//
//  Created by Steven Prichard on 2024-08-03.
//

import Charts
import SwiftUI

struct WeightDifferenceBarChart: View {
    @State
    private var rawSelectedDate: Date?
    
    var chartData: [WeekDayChartData]
        
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                Label("Average Weight Change", systemImage: "figure")
                    .font(.title3.bold())
                    .foregroundStyle(.purple)
                
                Text("Per Weekday (Last 28 Days)")
                    .font(.caption)
            }
            .foregroundStyle(.secondary)
            .padding(.bottom, 12)
            
            Chart {
                if let selectedData {
                    RuleMark(x: .value("Selected Data", selectedData.date, unit: .day))
                        .foregroundStyle(Color.secondary.opacity(0.3))
                        .offset(y: -10)
                        .annotation(
                            position: .top,
                            overflowResolution: .init(
                                x: .fit,
                                y: .disabled
                            ),
                            content: {
                                AnnotationView()
                            }
                        )
                }
                
                ForEach(chartData) { weightDiffs in
                    BarMark(
                        x: .value("Date", weightDiffs.date, unit: .day),
                        y: .value("Weight", weightDiffs.value)
                    )
                    .foregroundStyle(barColor(for: weightDiffs.value).gradient)
                }
            }
        }
        .frame(height: 150)
        .chartXSelection(value: $rawSelectedDate.animation(.easeInOut))
        .chartXAxis {
            AxisMarks(values: .stride(by: .day)) {
                AxisValueLabel(format: .dateTime.weekday(.abbreviated), centered: true)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }
    
    private var selectedData: WeekDayChartData? {
        guard let rawSelectedDate else { return nil }
        return chartData.first {
            Calendar.current.isDate(rawSelectedDate, inSameDayAs: $0.date)
        }
    }
    
    private func barColor(for value: Double) -> Color {
        if value >= 0 {
            return Color.purple
        } else {
            return Color.mint
        }
    }
}

extension WeightDifferenceBarChart {
    @ViewBuilder
    func AnnotationView() -> some View {
        VStack {
            Text(selectedData?.date ?? .now, format:
                .dateTime
                .weekday(.abbreviated)
                .day(.defaultDigits)
                .month(.abbreviated)
            )
                .font(.footnote.bold())
                .foregroundStyle(.secondary)
            Text(selectedData?.value ?? 0, format: .number.precision(.fractionLength(1)))
                .fontWeight(.heavy)
                .foregroundStyle(barColor(for: selectedData?.value ?? 0))
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(.secondarySystemBackground))
                .shadow(
                    color: .secondary.opacity(0.45),
                    radius: 2,
                    x: 2,
                    y: 2
                )
        )
    }
}

#Preview {
    WeightDifferenceBarChart(
        chartData: ChartMath.averageDailyWeightsDiffs(
            for: MockData.weights
        )
    )
}
