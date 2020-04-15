//
//  GraphData.swift
//  CalorieApp
//
//  Created by Neil Saigal on 4/14/20.
//  Copyright © 2020 AppleInterview. All rights reserved.
//

import UIKit
import HealthKit
import CareKitUI

/**
This class is the controller for the Trends tab. Creating a GraphData object will fetch the relevant Consumed and Burned data from HealthKit & CoreData. Then it will create a OCKCartesianChartView to present the data.
 */
class GraphData {
    
    var consumedData: [CGFloat] = []
    var burnedData: [CGFloat] = []

    var fromDates: [Date] = []
    var toDates: [Date] = []
    
    var increment: Calendar.Component = .day
    var interval: Int = 7
    var graphTitle: String = ""
    var testData: Bool = false
    var healthKitAccess: Bool = false
        
    /**
    Init GraphData object
     - Parameter increment: Unit of time that the graph will compare
     - Parameter interval: Number of increment units to separate data by.
     - Parameter graphTitle: Title of chart
     - Parameter testData: If true, generate randomized test data to present in graph. If false, pull data from HealthKit/CoreData
     */
    init(increment: Calendar.Component, interval: Int, graphTitle: String, testData: Bool = false) {
        self.increment = increment
        self.interval = interval
        self.graphTitle = graphTitle
        self.testData = testData
        
        HealthKitAPI().requestAuthorization(completion: { (success) in
            self.healthKitAccess = success
        })
        
        self.loadGraphData()
    }
    
    /**
     Generates test data for graph
     */
    func useTestData() {
        var testConsumedData: [CGFloat] = []
        var testBurnedData: [CGFloat] = []
        
        for _ in self.fromDates {
            testBurnedData.append(CGFloat.random(in: 1000 ..< 2000))
            testConsumedData.append(CGFloat.random(in: 1000 ..< 2000))
        }
        
        self.consumedData = testConsumedData
        self.burnedData = testBurnedData
    }
    
    /**
     Queries HealthKit/CoreData at given increment and interval and populates data arrays
     */
    func loadGraphData() {
            
        var from: Date = Date().getStartOfDay()
        
        var to: Date = Calendar.current.date(byAdding: increment, value: +1, to: from)!
        
        var loop = interval
                    
        switch increment {
        case .month:
            from = from.getFirstOfMonth()
        case .weekOfMonth:
            from = from.getLastSunday()
        default:
            break
        }
        
        for i in 0..<loop {
            if !testData {
                consumedData.append(APICalls().getConsumedCaloriesForTimeframe(start: from, end: to))
                if healthKitAccess {
                    HealthKitAPI().getCaloriesBurned(from: from, to: to, completion: { (calories) in
                        self.burnedData.append(CGFloat(calories))
                    })
                }
            }
            
            self.fromDates.append(from)
            self.toDates.append(to)
            
            from = Calendar.current.date(byAdding: increment, value: -1, to: from)!
            to = Calendar.current.date(byAdding: increment, value: +1, to: from)!
        }
        
        fromDates = fromDates.reversed()
        toDates = toDates.reversed()
        
        if testData {
            self.useTestData()
        }
        else {
            consumedData = consumedData.reversed()
            burnedData = burnedData.reversed()
        }
    }

    /**
     Returns detail string/subheader for chart
     */
    func getDetailString() -> String {
        if fromDates.count > 1 {
            return fromDates[0].getMonthDay() + " - " + fromDates.last!.getMonthDay()
        }
        
        return ""
    }
    
    /**
     Returns X-Axis labels for chart
     */
    func getAxisLabels() -> [String] {
        var labels: [String] = []
        
        for from in self.fromDates {
            var label: String = ""
            
            switch increment {
            case .weekOfMonth:
                label = from.getMonthDay()
            case .month:
                label = from.getMonthName()
            default:
                label = from.getDayOfWeek()
            }
            
            labels.append(label)
        }
        
        return labels
    }
    
    /**
    Creates chart view from data arrays
     - Returns: OCKCartesianChartView with data
     */
    func createChartFromGraph() -> OCKCartesianChartView {
        
        let cv: OCKCartesianChartView = OCKCartesianChartView(type: .bar)
        cv.headerView.titleLabel.text = self.graphTitle
        cv.headerView.detailLabel.text = self.getDetailString()
        cv.graphView.horizontalAxisMarkers = self.getAxisLabels()
        
        if !testData {
            if self.increment == .month {
                self.consumedData = self.consumedData.map { $0/30}
                self.burnedData = self.burnedData.map { $0/30}
            }
            if self.increment == .weekOfMonth {
                self.consumedData = self.consumedData.map { $0/7}
                self.burnedData = self.burnedData.map { $0/7}
            }
        }
        
        cv.graphView.yMinimum = -20
        if burnedData.count > 0 && consumedData.count > 0 {
            let burnedMax: CGFloat = self.burnedData.max()!
            let consumedMax: CGFloat = self.consumedData.max()!
            cv.graphView.yMaximum = burnedMax > consumedMax ? burnedMax:consumedMax
        }
        else {
            cv.graphView.yMaximum = 2000
        }
        
        var data = OCKDataSeries(values: self.consumedData, title: "Consumed", color: UIColor(red: 1, green: 0.904, blue: 0.038, alpha: 1))
        data.size = 15

        var data2 = OCKDataSeries(values: self.burnedData, title: "Burned", color: UIColor(red: 0.363, green: 0.908, blue: 0.516, alpha: 1))
        data2.size = 15
        
        cv.graphView.dataSeries = [
            data,
            data2
        ]

        return cv
    }
}
