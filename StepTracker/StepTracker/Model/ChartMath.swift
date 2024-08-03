//
//  ChartMath.swift
//  StepTracker
//
//  Created by Steven Prichard on 2024-05-19.
//

import Foundation
import Algorithms

struct ChartMath {
    static func averageWeekDayCount(for metric: [HealthMetric]) -> [WeekDayChartData] {
        return metric
            .sorted { $0.date.weekDayInt < $1.date.weekDayInt }
            .chunked { $0.date.weekDayInt == $1.date.weekDayInt }
            .compactMap {
                guard let firstValue = $0.first else { return nil }
                let sum = $0.reduce(0) { $0 + $1.value }
                let mean = sum / Double($0.count)
                return WeekDayChartData(date: firstValue.date, value: mean)
            }
    }
    
    static func averageDailyWeightsDiffs(for weights: [HealthMetric]) -> [WeekDayChartData] {
        var diffs: [(date: Date, value: Double)] = []
        
        for i in 1..<weights.count {
            let date = weights[i].date
            let diff = weights[i].value - weights[i - 1].value
            diffs.append((date: date, value: diff))
        }
        
        let sortedByWeekDay = diffs.sorted { $0.date.weekDayInt < $1.date.weekDayInt }
        let weekDayArray = sortedByWeekDay.chunked { $0.date.weekDayInt == $1.date.weekDayInt }
        var weekDayChartData: [WeekDayChartData] = []
        
        for array in weekDayArray {
            guard let firstValue = array.first else { continue }
            let total = array.reduce(0) { $0 + $1.value }
            let avgWeightDiff = total / Double(array.count)
            weekDayChartData.append(WeekDayChartData(date: firstValue.date, value: avgWeightDiff))
        }
                
        return weekDayChartData
    }
}
