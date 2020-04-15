//
//  Trends.swift
//  CalorieApp
//
//  Created by Neil Saigal on 4/14/20.
//  Copyright © 2020 AppleInterview. All rights reserved.
//

import UIKit
import CareKitUI
import HealthKit

class Trends: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var charts: [GraphData] = []
    @IBOutlet var chartTableView: UITableView!
    @IBOutlet var testButton: UIButton!
    var testData: Bool = false

    override func viewDidLoad() {
        let dayGraph = GraphData(increment: .day, interval: 7, graphTitle: "Over the last 7 days")
        let weekGraph = GraphData(increment: .weekOfMonth, interval: 4, graphTitle: "Over the last month")
        let monthGraph = GraphData(increment: .month, interval: 6, graphTitle: "Over the last 6 months")
        
        charts = [dayGraph, weekGraph, monthGraph]
        
        self.chartTableView.reloadData()
    }
    
    @IBAction func useTestData() {
        testData = !testData
        if testData {
            self.testButton.setTitle("Use Real Data", for: .normal)
            let dayGraph = GraphData(increment: .day, interval: 7, graphTitle: "Over the last 7 days", testData: true)
            let weekGraph = GraphData(increment: .weekOfMonth, interval: 4, graphTitle: "Over the last month", testData: true)
            let monthGraph = GraphData(increment: .month, interval: 6, graphTitle: "Over the last 6 months", testData: true)
            
            charts = [dayGraph, weekGraph, monthGraph]
            
            self.chartTableView.reloadData()
        }
        else {
            self.testButton.setTitle("Use Test Data", for: .normal)

            let dayGraph = GraphData(increment: .day, interval: 7, graphTitle: "Over the last 7 days")
            let weekGraph = GraphData(increment: .weekOfMonth, interval: 4, graphTitle: "Over the last month")
            let monthGraph = GraphData(increment: .month, interval: 6, graphTitle: "Over the last 6 months")
            
            charts = [dayGraph, weekGraph, monthGraph]
            
            self.chartTableView.reloadData()
        }
    }

    // UITABLEVIEW PROTOCOL METHODS

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "chartCell")!
        
        cell = UITableViewCell(style: .default, reuseIdentifier: "chartCell")
        weak var chart: OCKCartesianChartView? = charts[indexPath.section].createChartFromGraph()

        chart?.frame = CGRect(x: 5, y: 5, width: cell.contentView.frame.width-10, height: cell.contentView.frame.height-10)
        
        if let c = chart {
            cell.contentView.addSubview(c)
        }
        chart?.translatesAutoresizingMaskIntoConstraints = false

        chart?.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant:5).isActive = true
        chart?.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 5).isActive = true
        chart?.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: 5).isActive = true
        chart?.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: 5).isActive = true
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return charts.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 220
    }
}
