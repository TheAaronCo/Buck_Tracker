//
//  BarChartViewController.swift
//  iBudget_Swift
//
//  Created by Alex Ling on 2/10/2015.
//  Copyright © 2015 Alex Ling. All rights reserved.
//

import UIKit
import Charts

class BarChartViewController: UIViewController{
	
	let screenSize : CGSize = UIScreen.mainScreen().bounds.size
	var barChartView : BarChartView!
	
	var dayStrings : [String] = []
	var moneySpend : [Double] = []
	var moneySpendPosiveVer : [Double] = []
	
	let defaults = NSUserDefaults.standardUserDefaults()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.barChartView = BarChartView(frame : CGRectMake(0, 60, self.screenSize.width, self.screenSize.height - 49 - 44 - 20)) //tabBarHeight = 49, navigationBarHeight = 44
		barChartView.legend.enabled = false
		barChartView.pinchZoomEnabled = true
		barChartView.doubleTapToZoomEnabled = false
	}
	
	override func viewWillAppear(animated: Bool) {
		self.reload()
	}
	
	func reload(){
		self.barChartView.removeFromSuperview()
		self.dayStrings = []
		self.moneySpend = []
		
		let wholeWeekDate : [NSDate] = NSDate().getWholeWeek()
		for i in wholeWeekDate {
			self.dayStrings.append(i.weekDay())
			
			let str = i.toStringFromNonLocalDate()
			var netMoney : Double = 0
			if let data = defaults.objectForKey(str) as! NSData? {
				if let stored = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! [Record]? {
					for s in stored {
						let moneyString : NSString = s.money as NSString
						netMoney += moneyString.doubleValue
					}
				}
			}
			
			self.moneySpend.append(netMoney)
		}
		
		self.moneySpendPosiveVer = self.moneySpend
		for var i : Int = 0; i < self.moneySpendPosiveVer.count; i += 1 {
			if self.moneySpendPosiveVer[i] < 0 {
				self.moneySpendPosiveVer[i] = self.moneySpendPosiveVer[i] * -1
			}
		}
		
		setChart(dayStrings, values: moneySpendPosiveVer)
		
		self.view.addSubview(self.barChartView)
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	func setChart(dataPoints: [String], values: [Double]) {
		barChartView.descriptionText = ""
		barChartView.noDataText = ""
		
		barChartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0, easingOption: .EaseInOutQuad)
		
		var dataEntries: [BarChartDataEntry] = []
		
		for i in 0..<dataPoints.count {
			let dataEntry = BarChartDataEntry(value: values[i], xIndex: i)
			dataEntries.append(dataEntry)
		}
		
		let chartDataSet = BarChartDataSet(yVals: dataEntries, label: "")
		
		for i in 0..<self.moneySpend.count {
			if i < chartDataSet.colors.count {
				if self.moneySpend[i] < 0 {
					chartDataSet.colors[i] = UIColor(red: 225/255, green: 14/255, blue: 70/255, alpha: 1)
				}
				else{
					chartDataSet.colors[i] = UIColor(red: 48/255, green: 188/255, blue: 123/255, alpha: 1)
				}
			}
			else{
				if self.moneySpend[i] < 0 {
					chartDataSet.colors.append(UIColor(red: 225/255, green: 14/255, blue: 70/255, alpha: 1))
				}
				else{
					chartDataSet.colors.append(UIColor(red: 48/255, green: 188/255, blue: 123/255, alpha: 1))
				}
			}
		}
		
		let chartData = BarChartData(xVals: dayStrings, dataSet: chartDataSet)
		barChartView.data = chartData
	}
}
