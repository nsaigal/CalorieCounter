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
    var useHealthKit: Bool = false
    
    var chartView: OCKCartesianChartView!
            
    /**
    Init GraphData object
     - Parameter increment: Unit of time that the graph will compare
     - Parameter interval: Number of increment units to separate data by.
     - Parameter graphTitle: Title of chart
     - Parameter testData: If true, generate randomized test data to present in graph. If false, pull data from HealthKit/CoreData
     */
    init(increment: Calendar.Component, interval: Int, graphTitle: String, testData: Bool = false, useHealthKit: Bool = false) {
        self.increment = increment
        self.interval = interval
        self.graphTitle = graphTitle
        self.testData = testData
        self.useHealthKit = useHealthKit
        
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
                    
        switch increment {
        case .month:
            from = from.getFirstOfMonth()
        case .weekOfMonth:
            from = from.getLastSunday()
        default:
            break
        }
        
        for _ in 0..<interval {
            
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
            if useHealthKit {
                self.ingestData()
            }
            else {
                self.consumedData.append(APICalls().getConsumedCaloriesForTimeframe(start: from, end: to))
            }
        }
    }
    
    func ingestData() {
        guard let _: Bool = self.fromDates.count > 0 && self.toDates.count > 0 else {
            return
        }
        
        let group = DispatchGroup()
        for index in 0..<interval {
            group.enter()
            HealthKitAPI().getCaloriesBurned(from: self.fromDates[index], to: self.toDates[index], completion: { (caloriesBurned) in
                self.burnedData.append(CGFloat(caloriesBurned))
                group.leave()
            })
            
            group.enter()
            HealthKitAPI().getConsumedCalories(from: self.fromDates[index], to: self.toDates[index], completion: { (caloriesEaten) in
                self.consumedData.append(CGFloat(caloriesEaten))
                group.leave()
            })

            group.wait()
        }
        
        group.notify(queue: DispatchQueue.main) {
            print("health kit data ingested")
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
                let firstOfMonth: Date = Date().getFirstOfMonth()
                let dateComp = Calendar.current.dateComponents([.day, .hour], from: firstOfMonth, to: Date())
                var noOfDays = dateComp.day ?? 29
                if dateComp.hour ?? 0 > 12 {
                    noOfDays += 1
                }
                
                for index in 0..<self.consumedData.count {
                    if index == self.consumedData.count-1 {
                        self.consumedData[index] /= CGFloat(noOfDays)
                        break
                    }
                    self.consumedData[index] /= 30
                }
                for index in 0..<self.burnedData.count {
                    if index == self.burnedData.count-1 {
                        self.burnedData[index] /= CGFloat(noOfDays)
                        break
                    }
                    self.burnedData[index] /= 30
                }
            }
            if self.increment == .weekOfMonth {
                let firstOfWeek: Date = Date().getLastSunday()
                let dateComp = Calendar.current.dateComponents([.day, .hour], from: firstOfWeek, to: Date())
                var noOfDays = dateComp.day ?? 6
                if dateComp.hour ?? 0 > 12 {
                    noOfDays += 1
                }
                
                for index in 0..<self.consumedData.count {
                    if index == self.consumedData.count-1 {
                        self.consumedData[index] /= CGFloat(noOfDays)
                        break
                    }
                    self.consumedData[index] /= 7
                }
                for index in 0..<self.burnedData.count {
                    if index == self.burnedData.count-1 {
                        self.burnedData[index] /= CGFloat(noOfDays)
                    }
                    self.burnedData[index] /= 7
                }
            }
        }
        
        cv.graphView.yMinimum = 0
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
            
        self.chartView = cv
        
        return cv
    }
    
    /**
    Reloads chart view
     - Returns: N/A
     */
    func reloadChart() {
        self.fromDates = []
        self.toDates = []
        self.burnedData = []
        self.consumedData = []
        
        loadGraphData()
        createChartFromGraph()
    }
}
