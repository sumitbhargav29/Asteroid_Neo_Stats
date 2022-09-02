//
//  ViewController.swift
//  Sumit_RaniumPractical_iOS
//
//  Created by Sam on 31/08/22.
//

import UIKit
import Alamofire
import MBProgressHUD
import SwiftyJSON
import Charts

class ViewController: UIViewController,ChartViewDelegate {
    
    //MARK:- IBOutlets
    @IBOutlet weak var vwDateSelection: UIView!
    @IBOutlet weak var vwAsteroidData: UIView!
    @IBOutlet weak var dptStartDate: UIDatePicker!
    @IBOutlet weak var dptEndDate: UIDatePicker!
    @IBOutlet var chartView: BarChartView!
    
    @IBOutlet weak var lblFastestAsteroid: UILabel!
    @IBOutlet weak var lblClosestAsteroid: UILabel!
    @IBOutlet weak var lblAvgSizeAsteroid: UILabel!
    
    // MARK:- Global Variables
    var startDate : String = ""
    var endDate : String  = ""
    let customMarkerView = CustomMarkerView()
    var items = [AsteroidsItem]()
    
    private var arrAsteroidsData = [String]()
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dptStartDate.minimumDate = date
        dptEndDate.minimumDate = date
        startDate = dateFormatter.string(from: date)
        endDate = dateFormatter.string(from: date)
        
        chartView.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        vwDateSelection.layer.cornerRadius = 10
        vwDateSelection.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        vwDateSelection.layer.borderWidth = 0.5
    }
    
    //MARK:- IBActions
    @IBAction func btnSubmitOnClick(_ sender: UIButton) {
        // make date range condition only between 7 days bcoz API only allows max 7 days data
        if startDate  == "" || endDate == "" {
            setPresentAlert(withTitle: AppName, message: "Please select the both Dates")
            return
        }
        
        let dateStart = dateFormatter.date(from: startDate)
        let dateEnd = dateFormatter.date(from: endDate)
        let diffInDays = Calendar.current.dateComponents([.day], from: dateStart!, to: dateEnd!).day
        
        if diffInDays! > 7 {
            setPresentAlert(withTitle: AppName, message: "Please select the gap of days between both days less then 7 days to see NEO data")
        } else {
            chartView.clear()
            callNeoFeedAPI() // API calling
        }
        
    }
    
    @IBAction func dptStartDateOnClick(_ sender: UIDatePicker) {
        startDate = dateFormatter.string(from: sender.date)
        print("Date to see StartDate",startDate)
    }
    
    @IBAction func dptEndDateOnClick(_ sender: UIDatePicker) {
        endDate = dateFormatter.string(from: sender.date)
        print("Date to see EndDate",endDate)
    }
    
}

//MARK:- Chart Method
extension ViewController {
    
    //MARK: - init Methods
    func setupChart() {
        chartView.delegate = self
        chartView.highlightPerTapEnabled = true
        chartView.highlightFullBarEnabled = true
        chartView.highlightPerDragEnabled = false
        
        chartView.pinchZoomEnabled = false
        chartView.setScaleEnabled(false)
        chartView.doubleTapToZoomEnabled = false
        
        chartView.drawBarShadowEnabled = false
        chartView.drawBordersEnabled = false
        chartView.drawGridBackgroundEnabled = false
        chartView.animate(yAxisDuration: 1.5 , easingOption: .easeInOutSine) //Animation
        chartView.legend.enabled = false
        chartView.borderColor = .chartLineColour
        chartView.setExtraOffsets(left: 10, top: 0, right: 20, bottom: 50)
        
        // Setup X axis
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.drawAxisLineEnabled = true
        xAxis.drawGridLinesEnabled = false
        xAxis.granularityEnabled = false
        xAxis.labelRotationAngle = -25
        xAxis.setLabelCount(arrAsteroidsData.count, force: false)
        xAxis.valueFormatter = IndexAxisValueFormatter(values: items.map { $0.DateToShow })
        xAxis.axisMaximum = Double(arrAsteroidsData.count)
        xAxis.axisLineColor = .chartLineColour
        xAxis.labelTextColor = .chartLineColour
        
        // Setup left axis
        let leftAxis = chartView.leftAxis
        leftAxis.drawTopYLabelEntryEnabled = true
        leftAxis.drawAxisLineEnabled = true
        leftAxis.drawGridLinesEnabled = true
        leftAxis.granularityEnabled = false
        //        leftAxis.granularity = 1
        leftAxis.axisLineColor = .chartLineColour
        leftAxis.labelTextColor = .chartLineColour
        
        leftAxis.setLabelCount(10, force: false)
        leftAxis.axisMinimum = 0
        leftAxis.axisMaximum = 15
        
        // Remove right axis
        let rightAxis = chartView.rightAxis
        rightAxis.enabled = false
        
    }
    
    func setupData() {
        let dataEntries = items.map{ $0.transformToBarChartDataEntry() }
        
        let set1 = BarChartDataSet(entries: dataEntries)
        set1.setColor(.chartBarColour)
        set1.highlightColor = .chartHightlightColour
        set1.highlightAlpha = 1
        
        let data = BarChartData(dataSet: set1)
        data.setDrawValues(true)
        data.setValueTextColor(.chartLineColour)
        let barValueFormatter = BarValueFormatter()
        data.setValueFormatter(barValueFormatter)
        chartView.data = data
    }
    
    func setupMarker() {
        customMarkerView.chartView = chartView
        chartView.marker = customMarkerView
    }
    
    // MARK: - Logic Methods
    func getFormattedItemValue(_ rawValues: [String]) -> [AsteroidsItem] {
        var items = [AsteroidsItem]()
        var index = 0
        
        for i in rawValues {
            let valuePair = i.components(separatedBy: ", ")
            let DateToShow = valuePair[0]
            let TotalAsteroidStr = valuePair[1]
            
            let TotalAsteroids = Double(TotalAsteroidStr) ?? 0
            items.append(AsteroidsItem(index: index, DateToShow: DateToShow, TotalAsteroids: Int(TotalAsteroids)))
            index += 1
        }
        return items
    }
    
    // MARK: - Chart Methods
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        guard let dataSet = chartView.data?.dataSets[highlight.dataSetIndex] else { return }
        let entryIndex = dataSet.entryIndex(entry: entry)
        
        customMarkerView.lblTotalNEONum.text = "\(items[entryIndex].TotalAsteroids)"
    }
}

// MARK: - Type Definition
struct AsteroidsItem {
    let index: Int
    let DateToShow: String
    let TotalAsteroids: Int
    
    func transformToBarChartDataEntry() -> BarChartDataEntry {
        let entry = BarChartDataEntry(x: Double(index), y: Double(TotalAsteroids))
        return entry
    }
}

class BarValueFormatter: ValueFormatter {
    
    func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        return String(format: "%.f", value)
    }
}

//MARK:- API Calling
extension ViewController {
    
    func callNeoFeedAPI(){
        
        let todosEndpoint: String = "https://api.nasa.gov/neo/rest/v1/feed?start_date=" + "\(startDate)" + "&end_date=" + "\(endDate)" + "&api_key=DEMO_KEY"
        //        print(todosEndpoint)
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        AF.request(todosEndpoint).responseJSON { [self] (response) in
            
            switch response.result {
            case .success:
                
                items.removeAll()
                arrAsteroidsData.removeAll()
                
                if let arrMainData = response.value as? [String:Any] {
                    
                    if let arrNEOData = arrMainData["near_earth_objects"] as? [String:Any] {
                        //                        print("arrNEOData = ",arrNEOData.description)
                        
                        let myKeys: [String] = arrNEOData.map{String($0.key) }
                        
                        var arrFastestAsteroidValue = [String:Double]()
                        var arrClosestAsteroidsValue = [String:Double]()
                        var arrAverageAsteroidSizeValue = [[String:Any]]()
                        var arrSubData = NSArray()
                        
                        for i in 0..<myKeys.count {
                            arrSubData = arrNEOData[myKeys[i]] as! NSArray
                            let date = myKeys[i]
                            arrAsteroidsData.append(date + ", " + "\(arrSubData.count)")
                        }
                        
                        //MARK:- Finding fastest,Closest and avg size of asteroids from API response
                        for j in 0..<arrSubData.count {
                            
                            if let arrEachAsteroidData = arrSubData[j] as? [String:Any] {
                                let idOfAsteroid = arrEachAsteroidData["id"] as? String ?? ""
                                
                                if let arrCloseApproachData = arrEachAsteroidData["close_approach_data"] as? NSArray {
                                    let finalDict = arrCloseApproachData.firstObject as? [String:Any]
                                    
                                    if let arrRelativeVelocity = finalDict?["relative_velocity"] as? [String:Any] {
                                        let kmValue = Double(arrRelativeVelocity["kilometers_per_hour"] as? String ?? "")
                                        arrFastestAsteroidValue[idOfAsteroid] = kmValue
                                    }
                                    
                                    if let arrMissDistance = finalDict?["miss_distance"] as? [String:Any] {
                                        let kmRange = Double(arrMissDistance["kilometers"] as? String ?? "")
                                        arrClosestAsteroidsValue[idOfAsteroid] = kmRange
                                    }
                                }
                                
                                if let arrEstimated_diameter = arrEachAsteroidData["estimated_diameter"] as? [String:Any] {
                                    if let arrTotalKm = arrEstimated_diameter["kilometers"] as? [String:Any] {
                                        arrAverageAsteroidSizeValue.append(arrTotalKm)
                                    }
                                }
                                
                            } // end of arrEachAsteroidData condition
                        }
                        
                        let maxKm = arrFastestAsteroidValue.max { a, b in a.value < b.value }
                        let minKm = arrClosestAsteroidsValue.min { a, b in return a.value < b.value }
                        
                        lblFastestAsteroid.text = "Asteroid ID: \(maxKm?.key ?? "") with speed of " + "\(maxKm?.value ?? 0.0) km/h"
                        lblClosestAsteroid.text = "Asteroid ID: \(minKm?.key ?? "") with closest distance of " + "\(minKm?.value ?? 0.0) km"
                        
                        let totalDiaMin = arrAverageAsteroidSizeValue.compactMap { $0["estimated_diameter_min"] as? Double}.reduce(0, +)
                        let totalDiaMax = arrAverageAsteroidSizeValue.compactMap { $0["estimated_diameter_max"] as? Double}.reduce(0, +)
                        
                        lblAvgSizeAsteroid.text = "Average Size of the Asteroids in min diameter: \(totalDiaMin/Double(arrAverageAsteroidSizeValue.count)) and max diameter:" + "\(totalDiaMax/Double(arrAverageAsteroidSizeValue.count))"
                    }
                }
                
                DispatchQueue.main.async {
                    //make chart data init here after API reponse
                    items = getFormattedItemValue(arrAsteroidsData)
                    setupData()
                    setupChart()
                    setupMarker()
                    vwAsteroidData.isHidden = false
                    chartView.isHidden = false
                }
                MBProgressHUD.hide(for: self.view, animated: true)
                
            case let .failure(error):
                print(error)
                MBProgressHUD.hide(for: self.view, animated: true)
            }
        }
    }
}
