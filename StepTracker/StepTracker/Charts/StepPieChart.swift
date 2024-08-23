//
//  StepPieChart.swift
//  StepTracker
//
//  Created by Steven Prichard on 2024-05-19.
//

import Charts
import SwiftUI

struct StepPieChart: View {
    var chartData: [WeekDayChartData]
    
    private var selectedWeekDay: WeekDayChartData? {
        guard let rawSelectedChartValue else { return nil }
        var total = 0.0
        
        return chartData.first {
            total += $0.value
            return total >= rawSelectedChartValue
        }
    }
    
    @State
    private var rawSelectedChartValue: Double? = 0
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                Label("Averages", systemImage: "calendar")
                    .font(.title3.bold())
                    .foregroundStyle(.pink)
                
                Text("Last 28 Days")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom, 12)
            
            Chart {
                ForEach(chartData) { weekDay in
                    SectorMark(
                        angle: .value("Average Steps", weekDay.value),
                        innerRadius: .ratio(0.618),
                        outerRadius: selectedWeekDay?.date.weekDayInt == weekDay.date.weekDayInt ? 140 : 110,
                        angularInset: 1
                    )
                    .foregroundStyle(.pink.gradient)
                    .cornerRadius(4)
                    .opacity(selectedWeekDay?.date.weekDayInt == weekDay.date.weekDayInt ? 1.0 : 0.3)
                }
            }
            .frame(height: 240)
            .chartBackground { proxy in
                GeometryReader { geo in
                    if let plotFrame = proxy.plotFrame {
                        let frame = geo[plotFrame]
                        if let selectedWeekDay {
                            VStack {
                                Text(selectedWeekDay.date.weekDayWideTitle)
                                    .font(.title3.bold())
                                    .contentTransition(.identity)
                                Text(selectedWeekDay.value, format: .number.precision(.fractionLength(0)))
                                    .fontWeight(.medium)
                                    .foregroundStyle(.secondary)
                                    .contentTransition(.numericText())
                            }.position(x: frame.midX, y: frame.midY)
                        }
                    }
                }
            }
            .chartAngleSelection(value: $rawSelectedChartValue.animation(.easeInOut))
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
    }
}

#Preview {
    StepPieChart(chartData: ChartMath.averageWeekDayCount(for: MockData.steps))
}
