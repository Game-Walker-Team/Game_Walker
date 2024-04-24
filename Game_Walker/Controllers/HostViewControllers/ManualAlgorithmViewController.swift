//
//  ManualAlgorithmViewController.swift
//  Game_Walker
//
//  Created by Jin Kim on 4/2/23.


import UIKit

class ManualAlgorithmViewController: UIViewController {
    
    private var scrollView: UIScrollView!
    private var collectionView: UICollectionView!
    
    private var rectWidth = 0.98 * UIScreen.main.bounds.width
    private var modalRect : CGRect = CGRect()
    
    @IBOutlet weak var matchingLabel: UILabel!
    @IBOutlet weak var createGameButton: UIButton!
    @IBOutlet weak var stationsLabelImageView: UIImageView!
    @IBOutlet weak var roundsLabelImageView: UIImageView!
    
    private var gamecode = UserData.readGamecode("gamecode")!
    
    private var collectionViewWidth = UIScreen.main.bounds.width * 0.75
    private var collectionViewCellSize : CGSize?
    private var collectionViewCellWidth : CGFloat?
    private var collectionViewCellSpacing: CGFloat = 6.0
    
    // variables for data
    private var cellDataGrid : [[CellData]] = [[CellData]]()
    
    private var totalrow : Int =  0
    private var totalcolumn : Int = 0

    private var needHorizontalEmptyCells = false
    private var needVerticalEmptyCells = false
    private var horizontalEmptyCells = 0
    private var verticalEmptyCells = 0
    //options: "none", "teams", "stations"
    private var excessOf = "none"
    private var excessCells = 0
    private var omittedTeamCells = 0
    
    var stationList: [Station]? = nil
    var host : Host?
    
    var pvpGameCount : Int = 0
    var pveGameCount : Int = 0
    var num_rounds : Int = 0
    var num_teams : Int = 0
    var num_stations : Int = 0
    
    var cellDataA : CellData?
    var cellDataB : CellData?
    
    private var duplicatedOpponentsButton: UIButton!
    private var duplicatedStationsButton: UIButton!
    private var sameRoundDuplicatedButton: UIButton!
    
    private var blueOn : Bool = true
    private var yellowOn : Bool = true
    private var purpleOn : Bool = true
    
    
    override func viewWillDisappear(_ animated: Bool) {
            self.navigationController?.setNavigationBarHidden(true, animated: animated)
        }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpCollectionViewScrollView()
        Task {
            do{
                host = try await fetchHostForAlgorithm()
                createGrid()
                
                DispatchQueue.main.async {
                    self.collectionView.dataSource = self
                    self.collectionView.delegate = self
                    self.reloadAll()
                    self.collectionView?.reloadData()
                }
            } catch {
                print("Couldnt catch host and make grid")
            }
        }
        collectionView.isHidden = true
        scrollView.isHidden = true
        stationsLabelImageView.isHidden = true
        roundsLabelImageView.isHidden = true
        configureSimpleNavBarWithInfo()
        addTapGesture()
        configureButtonVisuals()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        calculateSizesAndContentSize()
        setUpLabels()
        setUpButtons()
        collectionView.isHidden = false
        scrollView.isHidden = false
        stationsLabelImageView.isHidden = false
        roundsLabelImageView.isHidden = false

    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if collectionViewCellWidth! > 0  {
            createBorderLines()
        }
    }

    private func configureButtonVisuals() {
        createGameButton.layer.cornerRadius = 10.0
        if let originalFont = createGameButton.titleLabel?.font {
            createGameButton.titleLabel?.font = getFontForLanguage(font: originalFont.fontName, size: originalFont.pointSize)
        }
    }

    func fetchHostForAlgorithm() async throws -> Host {
        do {
            self.host = try await H.getHost(gamecode)
            num_teams = host!.teams
            num_rounds = host!.rounds

        } catch(let e) {
            print(e)
        }
        return host ?? Host()
    }
    
    func fetchDataSimple(gamecode: String) async {
        do {
            stationList = try await S.getStationList(gamecode)
            num_stations = stationList!.count
            var pvpCount = 0
            if let unwrappedStationList = self.stationList {
                for station in unwrappedStationList {
                    if station.pvp {
                        pvpCount += 1
                    }
                }
            }
            pvpGameCount = pvpCount
            pveGameCount = num_stations - pvpGameCount
        } catch (let e) {
            print(e)
            return
        }
        
        do {
            self.host = try await H.getHost(gamecode)
            num_teams = host!.teams
            // TODO: be aware that this might be needing during testing
//            num_teams = 6
            num_rounds = host!.rounds
//            num_rounds = 6
        } catch(let e) {
            print(e)
            return
        }
        
    }
    
    func fetchDataAndInitialize() {
        Task { [weak self] in
            do {
                self?.stationList = try await S.getStationList(self?.gamecode ?? "")
                self?.num_stations = self?.stationList?.count ?? 0
                var pvpCount = 0
                if let unwrappedStationList = self?.stationList {
                    for station in unwrappedStationList {
                        if station.pvp {
                            pvpCount += 1
                        }
                    }
                }
                
                self?.pvpGameCount = pvpCount
                self?.pveGameCount = self?.num_stations ?? 0 - pvpCount
                
                self?.host = try await H.getHost(self?.gamecode ?? "")
                self?.num_teams = self?.host?.teams ?? 0
                self?.num_rounds = self?.host?.rounds ?? 0
                
                self?.createGrid()
                
                // Reload the collection view once data is ready (on the main thread)
                DispatchQueue.main.async { [weak self] in
                    
                    self!.collectionView.dataSource = self
                    self!.collectionView.delegate = self
                    self?.reloadAll()
                    self?.collectionView?.reloadData()
                }
            } catch {
                print("Error in fetchDataAndInitialize: \(error)")
            }
        }
    }
    
    private func createGrid() {
        print("somehow inside create grid")
        num_stations = pvpGameCount * 2 + pveGameCount
        omittedTeamCells = hasOmittedTeamCells()
        if (num_stations < 8) {
            needHorizontalEmptyCells = true
            horizontalEmptyCells = 8 - num_stations
        }
        
        if (num_rounds < 8) {
            needVerticalEmptyCells = true
            verticalEmptyCells = 8 - num_rounds
        }
        if (num_stations < num_teams) {
            excessOf = "teams"
            excessCells = num_teams - num_stations
        }
        if (num_teams < num_stations) {
            excessOf = "stations"
            excessCells = num_stations - num_teams
        }
        
        totalcolumn = max(num_stations, num_teams)
        totalrow = num_rounds
        
        var tempCellGrid: [[CellData]]? = nil
        if pvpGameCount > 0 && pveGameCount == 0 {
            tempCellGrid = checkAndGetPvpDefaultAlgorithm(num_rounds, pvpGameCount, num_teams)
        }

        // Proceed if tempCellGrid is nil, break out if not nil
        if let tempGrid = tempCellGrid {
            cellDataGrid = tempGrid
            return
        }

        for r in 0..<totalrow {
            var currRow: [Int] = []
            
            // adding grid with celldata
            var currCellDataRow: [CellData] = []
            
            for t in 0..<totalcolumn {
                var number = (t + (r + 1)) % totalcolumn
                if number == 0 {
                    number = totalcolumn
                }
                
                
                var visible = true
                if excessOf == "stations" || excessOf == "teams" {
                    if t >= totalcolumn - excessCells {
                        if excessOf == "stations" {
                            number = 0
                        } else if excessOf == "teams" {
                            number = -1
                            visible = false
                        }
                    }
                }
                let celldata = CellData(number: number, visible: visible, index: IntPair(first: r, second: t))
                currRow.append(number)
                currCellDataRow.append(celldata)
            }
            
            while currRow.count < 8 {
                currRow.append(-1)
                let celldata = CellData(number: -1, visible: false, index: IntPair(first:r, second:currRow.count))
                currCellDataRow.append(celldata)
            }
            cellDataGrid.append(currCellDataRow)
        }
        
        
        for rowIndex in stride(from: 1, through: cellDataGrid.count - 1, by: 2) {
            for column in 0..<(pvpGameCount * 2) {
                let cellData = cellDataGrid[rowIndex][column]
                if cellData.number != -1 {
                    changeCellGridData(cellDataInstance: cellData, to: "empty")
                }
            }
        }
        
        for rowIndex in 0..<cellDataGrid.count {
            var filteredRow: [CellData] = []
            
            //getting rid of unnecessary data that is disabled not visible, and greater than 8.
            for columnIndex in 0..<cellDataGrid[rowIndex].count {
                let cellData = cellDataGrid[rowIndex][columnIndex]
                
                if cellData.cellIndex!.second > 8 && cellData.number == -1 {
                    continue
                }
                
                filteredRow.append(cellData)
            }
            cellDataGrid[rowIndex] = filteredRow
        }
        
        var count = 0
        for row in cellDataGrid {
            count += 1
            var rownums = [Int]()
            for celldata in row {
                rownums.append(celldata.number!)
            }
                        print("celldatagrid at row ", count, " is ", rownums)
        }
    }
    
    
    
    @IBAction func createButtonPressed(_ sender: UIButton) {
        let startGameViewController = StartGameViewController(announcement: NSLocalizedString("Once the game is created, you won't be able to change the game settings.", comment: ""), source: "", gamecode: gamecode)
        startGameViewController.delegate = self
        present(startGameViewController, animated: true)
    }
    
    @objc func duplicatedOpponentsButtonPressed() {
        duplicatedOpponentsButton.isSelected = !duplicatedOpponentsButton.isSelected
        blueOn = duplicatedOpponentsButton.isSelected
        resetAll()
        reloadAll()
    }
    
    @objc func duplicatedStationsButtonPressed() {
        duplicatedStationsButton.isSelected = !duplicatedStationsButton.isSelected
        yellowOn = duplicatedStationsButton.isSelected
        resetAll()
        reloadAll()
    }
    
    @objc func sameRoundDuplicatedButtonPressed() {
        sameRoundDuplicatedButton.isSelected = !sameRoundDuplicatedButton.isSelected
        purpleOn = sameRoundDuplicatedButton.isSelected
        resetAll()
        reloadAll()
    }
    
    //MARK: - Helper Functions
    
    
    private func numberIsValid(_ number: Int?) -> Bool {
        if number != nil && number != 0 && number != -1 {
            return true
        } else {
            return false
        }
    }
    
    private func hasOmittedTeamCells() -> Int {
        let stationCells = pvpGameCount * 2 + pveGameCount
        let teamCells = num_teams
        
        if teamCells > stationCells {
            print("Be cautious there are omitted Team Cells.")
            alert(title: NSLocalizedString("Excessed Teams", comment: ""), message: NSLocalizedString("Be careful! There are more teams than available stations.", comment: ""))

            return teamCells - stationCells
        }
        return 0
    }
    
    private func changeCellGridData(cellDataInstance: CellData, to state: String) {
        let section = cellDataInstance.cellIndex?.first
        let column = cellDataInstance.cellIndex?.second
        cellDataGrid[section!][column!].changeState(to: state)
    }
    
    private func addCellSetsToCellGridData(cellDataInstance: CellData, to color: String, set: Set<CellData>) {
        let section = cellDataInstance.cellIndex?.first
        let column = cellDataInstance.cellIndex?.second
        if color == "blue" {
            cellDataGrid[section!][column!].addBluePvpIndexToCellData(set)
        } else if color == "yellowPvp" {
            cellDataGrid[section!][column!].addYellowPvpIndexToCellData(set)
        } else if color == "yellow" {
            cellDataGrid[section!][column!].addYellowIndexToCellData(set)
        } else if color == "purple" {
            cellDataGrid[section!][column!].addPurpleIndexToCellData(set)
        } else {
            print("NO CELL DATA SET HAS BEEN ADDED.")
        }
    }
    
    private func calculateSizesAndContentSize() {
        var numberOfItemsInARow = 8
        let cellSpacing = collectionViewCellSpacing
        
        if collectionView.numberOfItems(inSection: 0) > 8 {
            numberOfItemsInARow = collectionView.numberOfItems(inSection: 0)
        }
        var extraspace = 0
        if horizontalEmptyCells > 0 {
            extraspace = Int((collectionViewCellSize!.width + cellSpacing)) * horizontalEmptyCells
        }
        var contentWidth = CGFloat(numberOfItemsInARow) * (collectionViewCellSize!.width + cellSpacing) + (cellSpacing * 2) - CGFloat(extraspace)

        let minimumContentWidth = 8 * (collectionViewCellSize!.width + cellSpacing) + cellSpacing
        print("contentWidth : \(contentWidth) and minimum content width is : \(minimumContentWidth)")
        
        if contentWidth < minimumContentWidth {
            contentWidth = minimumContentWidth
        } else if omittedTeamCells > 0 {
            print("omittedd condition!!")
            // have to think about this part because when i simply erase the space, i get a contentsize too small because invisible disabled cells still count in the width!
            //            contentWidth  = contentWidth - (CGFloat(omittedTeamCells) * (collectionViewCellSize!.width + cellSpacing) )
        }
        
        scrollView.contentSize = CGSize(width: contentWidth, height: collectionView.contentSize.height)
        collectionView.contentSize = scrollView.contentSize
        
        let collectionViewWidthConstraint = collectionView.widthAnchor.constraint(equalToConstant:  scrollView.contentSize.width)
        collectionViewWidthConstraint.isActive = true
        
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.itemSize = collectionViewCellSize!
            flowLayout.minimumInteritemSpacing = collectionViewCellSpacing
            flowLayout.minimumLineSpacing = collectionViewCellSpacing
        }
        
    }
    
    private  func getCellCurrPlayingWith(_ cellData: CellData) -> CellData {
        if cellData.cellIndex!.second % 2 == 0 {
            return cellDataGrid[cellData.cellIndex!.first][cellData.cellIndex!.second + 1]
        } else {
            return cellDataGrid[cellData.cellIndex!.first][cellData.cellIndex!.second - 1]
        }
    }
    
    
    func reloadAll() {
        collectionView.isUserInteractionEnabled = false
        if pvpGameCount > 0 {
            if yellowOn {
                processPvpYellowCells()
            }
            if blueOn {
                processPvpBlueCells()
            }
        }
        if purpleOn {
            processPurpleSameRoundCells()
        }
        if yellowOn {
            processYellowSameStationCells()
        }
        collectionView.reloadData()
        DispatchQueue.main.async {
            self.collectionView.isUserInteractionEnabled = true
        }
    }
    
    func resetAll() {
        if let indexPaths = collectionView.indexPathsForSelectedItems, !indexPaths.isEmpty {
            for indexPath in indexPaths {
                self.collectionView.deselectItem(at: indexPath,  animated: true)
            }
        }
        for section in 0..<cellDataGrid.count {
            for column in 0..<cellDataGrid[0].count {
                if cellDataGrid[section][column].visible {
                    cellDataGrid[section][column].resetCellToDefault()
                    if let cell = collectionView.cellForItem(at: IndexPath(item: column, section: section)) as? AlgCollectionViewCell {
                        cell.makeCellOriginal()
                        print("IS IT enabled? :" , cell.isUserInteractionEnabled, " for item at : column->", column," and section-> ", section)
                    }
                }
            }
        }
    }
    
    
    private func createIntegerGrid() -> [[Int]]{
        var integerGrid: [[Int]] = []

        for row in cellDataGrid {
            var rowOfIntegers: [Int] = []
            
            for cellData in row {
                if let number = cellData.number {
                    rowOfIntegers.append(number)
                } else {
                    print("error: number is not valid when saving as integer grid.")
                }
            }
            
            integerGrid.append(rowOfIntegers)
        }
        return integerGrid
    }
    //helperfunctions end
    
    
    
    //    processing functions
    
    private func processPvpBlueCells() {
        var numbersSeenByNumber = [Int: Set<Int>]()
        var duplicatedPairs = Set<IntPair>()
        for pairIndex in 0...(pvpGameCount - 1) {
            let startColumn = pairIndex * 2
            let endColumn = startColumn + 1
            for section in 0..<cellDataGrid.count {
                let cellData1 = cellDataGrid[section][startColumn]
                let cellData2 = cellDataGrid[section][endColumn]
                let numberKey1 = cellData1.number
                let numberKey2 = cellData2.number
                
                if numberIsValid(numberKey1) {
                    if var seenNumbers = numbersSeenByNumber[numberKey1!] {
                        if numberIsValid(numberKey2) {
                            if seenNumbers.contains(numberKey2!) {
                                duplicatedPairs.insert(IntPair(first: numberKey1!, second: numberKey2!))
                            } else {
                                seenNumbers.insert(numberKey2!)
                                numbersSeenByNumber[numberKey1!] = seenNumbers
                                if var seenNumbersPair = numbersSeenByNumber[numberKey2!]{
                                    if numberIsValid(numberKey1) {
                                        if !seenNumbersPair.contains(numberKey1!) {
                                            seenNumbersPair.insert(numberKey1!)
                                            numbersSeenByNumber[numberKey2!] = seenNumbersPair
                                        }
                                    }
                                } else {
                                    var newNumberSet = Set<Int>()
                                    newNumberSet.insert(numberKey1!)
                                    numbersSeenByNumber[numberKey2!] = newNumberSet
                                }
                            }
                        }
                    } else {
                        if numberIsValid(numberKey2) {
                            var newNumberSet1 = Set<Int>()
                            var newNumberSet2 = Set<Int>()
                            newNumberSet1.insert(numberKey2!)
                            numbersSeenByNumber[numberKey1!] = newNumberSet1
                            newNumberSet2.insert(numberKey1!)
                            numbersSeenByNumber[numberKey2!] = newNumberSet2
                        }
                    }
                }
            }
        }
        makeAllDuplicatePairsBlue(duplicatedPairs)
    }
    
    private func makeAllDuplicatePairsBlue(_ duplicatedPairs : Set<IntPair>) {
        var allCellsWithDuplicatedMatchesByPairs = [IntPair: Set<CellData>]()
        
        for pairIndex in 0...(pvpGameCount-1) {
            let evenColumn = pairIndex * 2
            for section in 0..<cellDataGrid.count {
                
                let cellData1 = cellDataGrid[section][evenColumn]
                let cellData2 = getCellCurrPlayingWith(cellData1)
                let number1 = cellData1.number
                let number2 = cellData2.number
                
                // indexPathsByPairs with have the same IntPair value for either switched or not switched pairs.
                // example: IntPair(1,2) and IntPair(2,1) will have the Key of IntPair(1,2)
                let currPair = IntPair(first: number1!, second: number2!)
                let currPairSwitched = currPair.switchPair(currPair)
                let currPairKey = currPair.cleanOrderPair(currPair)
                
                if duplicatedPairs.contains(currPair) || duplicatedPairs.contains(currPairSwitched) {
                    if var cellDataSet = allCellsWithDuplicatedMatchesByPairs[currPairKey] {
                        cellDataSet.insert(cellData1)
                        cellDataSet.insert(cellData2)
                        allCellsWithDuplicatedMatchesByPairs[currPairKey] = cellDataSet
                    } else {
                        var newCellDataSet = Set<CellData>()
                        newCellDataSet.insert(cellData1)
                        newCellDataSet.insert(cellData2)
                        allCellsWithDuplicatedMatchesByPairs[currPairKey] = newCellDataSet
                    }
                }
            }
        }
        
        for (_, cellDataSet) in allCellsWithDuplicatedMatchesByPairs {
            for cellData in cellDataSet {
                addCellSetsToCellGridData(cellDataInstance: cellData, to: "blue", set: cellDataSet)
                
                //Case where cells that need blue warnings already has yellow pvp warnings
                if cellData.hasPvpYellowWarning {
                    changeCellGridData(cellDataInstance: cellData, to: "red")
                    for yellowCellData in cellData.cellsWithSameYellowPvpWarning {
                        changeCellGridData(cellDataInstance: yellowCellData, to: "red")
                    }
                    for currCellData in cellData.cellsWithSameBluePvpWarning {
                        changeCellGridData(cellDataInstance: currCellData, to: "red")
                    }
                } else if cellData.hasPurpleWarning {
                    for purpleCellData in cellData.cellsWithSamePurpleWarning {
                        changeCellGridData(cellDataInstance: purpleCellData, to: "red")
                    }
                    for currCellData in cellData.cellsWithSameBluePvpWarning {
                        changeCellGridData(cellDataInstance: currCellData, to: "red")
                    }
                } else if cellData.hasYellowWarning{
                    for yellowCellData in cellData.cellsWithSameYellowWarning {
                        changeCellGridData(cellDataInstance: yellowCellData, to: "red")
                    }
                    for currCellData in cellData.cellsWithSameBluePvpWarning {
                        changeCellGridData(cellDataInstance: currCellData, to: "red")
                    }
                } else if cellData.hasRedWarning {
                    for currCellData in cellData.cellsWithSameBluePvpWarning {
                        changeCellGridData(cellDataInstance: currCellData, to: "red")
                    }
                }else {
                    changeCellGridData(cellDataInstance: cellData, to: "blue")
                    //                    print("changing a pvp blue cell to blue. no other error encountered")
                }
            }
        }
    }
    
    private func processPvpYellowCells () {
        for pairIndex in 0..<pvpGameCount {
            let startColumn = pairIndex * 2
            let endColumn = startColumn + 1
            
            var matchedCellsByNumber = [Int: Set<CellData>]()
            
            for section in 0..<cellDataGrid.count {
                for column in startColumn...endColumn {
                    let cellData = cellDataGrid[section][column]
                    let numberKey = cellData.number
                    
                    if numberIsValid(numberKey) {
                        //Checking if IntPairsByNumbers already has the numberkey
                        if var cellDataSet = matchedCellsByNumber[numberKey!] {
                            cellDataSet.insert(cellData)
                            matchedCellsByNumber[numberKey!] = cellDataSet
                        } else {
                            var newCellDataSet = Set<CellData>()
                            newCellDataSet.insert(cellData)
                            matchedCellsByNumber[numberKey!] = newCellDataSet
                        }
                    }
                }
            }
            // Check number keys with multiple cells.
            // This will tell if there are duplicates in the two pvp column pairs.
            for (_, cellDataset) in matchedCellsByNumber {
                if cellDataset.count >= 2 {
                    for cellData in cellDataset {
                        changeCellGridData(cellDataInstance: cellData, to: "yellowPvp")
                        addCellSetsToCellGridData(cellDataInstance: cellData, to: "yellowPvp", set: cellDataset)
                    }
                }
            }
        }
    }
    
    private func processPurpleSameRoundCells() {
        for row in cellDataGrid {
            var rowNumbers = [Int: Set<CellData>]()
            for cellData in row {
                let number = cellData.number
                
                if numberIsValid(number) {
                    if var cellDataSet = rowNumbers[number!] {
                        cellDataSet.insert(cellData)
                        rowNumbers[number!] = cellDataSet
                    } else {
                        var newCellDataSet = Set<CellData>()
                        newCellDataSet.insert(cellData)
                        rowNumbers[number!] = newCellDataSet
                    }
                }
            }
            //Now mark each cell with more than two counts in sets in each row
            for (_, cellDataSet) in rowNumbers {
                if cellDataSet.count >= 2 {
                    for cellDataDuplicates in cellDataSet {
                        addCellSetsToCellGridData(cellDataInstance: cellDataDuplicates, to: "purple", set: cellDataSet)
                        
                        if cellDataDuplicates.hasRedWarning {
                            changeCellGridData(cellDataInstance: cellDataDuplicates, to: "red")
                        } else if cellDataDuplicates.hasPvpBlueWarning {
                            changeCellGridData(cellDataInstance: cellDataDuplicates, to: "red")
                            for pvpBlueCellData in cellDataDuplicates.cellsWithSameBluePvpWarning {
                                changeCellGridData(cellDataInstance: pvpBlueCellData, to: "red")
                            }
                            for currCellData in cellDataDuplicates.cellsWithSamePurpleWarning   {
                                changeCellGridData(cellDataInstance: currCellData, to: "red")
                            }
                        } else if cellDataDuplicates.hasPvpYellowWarning {
                            changeCellGridData(cellDataInstance: cellDataDuplicates, to: "red")
                            for pvpYellowCellData in cellDataDuplicates.cellsWithSameYellowPvpWarning {
                                changeCellGridData(cellDataInstance: pvpYellowCellData, to: "red")
                            }
                            for currCellData in cellDataDuplicates.cellsWithSamePurpleWarning   {
                                changeCellGridData(cellDataInstance: currCellData, to: "red")
                            }
                        } else {
                            changeCellGridData(cellDataInstance: cellDataDuplicates, to: "purple")
                        }
                    }
                }
            }
        }
    }
    
    func processYellowSameStationCells() {
        for col in 0..<cellDataGrid[0].count {
            var columnNumbers = [Int: Set<CellData>]()
            for sect in 0..<cellDataGrid.count {
                let cellData = cellDataGrid[sect][col]
                let number = cellData.number
                
                if numberIsValid(number) {
                    if var cellDataSet = columnNumbers[number!] {
                        cellDataSet.insert(cellData)
                        columnNumbers[number!] = cellDataSet
                    } else {
                        var newCellDataSet = Set<CellData>()
                        newCellDataSet.insert(cellData)
                        columnNumbers[number!] = newCellDataSet
                    }
                }
            }
            for (_, cellDataSet) in columnNumbers {
                if cellDataSet.count >= 2 {
                    for cellDataWithWarning in cellDataSet {
                        addCellSetsToCellGridData(cellDataInstance: cellDataWithWarning, to: "yellow", set: cellDataSet)
                        if cellDataWithWarning.hasPurpleWarning {
                            changeCellGridData(cellDataInstance: cellDataWithWarning, to: "red")
                            for purpleCellData in cellDataWithWarning.cellsWithSamePurpleWarning {
                                changeCellGridData(cellDataInstance: purpleCellData, to: "red")
                            }
                            for currCellData in cellDataWithWarning.cellsWithSameYellowWarning   {
                                changeCellGridData(cellDataInstance: currCellData, to: "red")
                            }
                        } else if cellDataWithWarning.hasRedWarning {
                            changeCellGridData(cellDataInstance: cellDataWithWarning, to: "red")
                            
                        } else if cellDataWithWarning.hasPvpBlueWarning {
                            changeCellGridData(cellDataInstance: cellDataWithWarning, to: "red")
                            for pvpBlueCellData in cellDataWithWarning.cellsWithSameBluePvpWarning {
                                changeCellGridData(cellDataInstance: pvpBlueCellData, to: "red")
                            }
                            for currCellData in cellDataWithWarning.cellsWithSameYellowWarning   {
                                changeCellGridData(cellDataInstance: currCellData, to: "red")
                            }
                        } else if cellDataWithWarning.hasPvpYellowWarning {
                            //                            changeCellGridData(cellDataInstance: cellDataWithWarning, to: "red")
                            //                            for pvpYellowCellData in cellDataWithWarning.cellsWithSameYellowPvpWarning {
                            //                                changeCellGridData(cellDataInstance: pvpYellowCellData, to: "red")
                            //                            }
                        } else {
                            changeCellGridData(cellDataInstance: cellDataWithWarning, to: "yellow")
                        }
                    }
                }
            }
        }
    }
    

    //setting collectionview and scrollview and labels and buttons and lines apart from data
    
    func setUpCollectionViewScrollView() {
        
        let totalSpacing = collectionViewCellSpacing * 9
        let availableWidth = floor(collectionViewWidth - totalSpacing)
        let toTheRight = collectionViewWidth * 0.05
        collectionViewCellWidth = availableWidth / 8
        collectionViewCellSize = CGSize(width: collectionViewCellWidth!, height: collectionViewCellWidth!)
        
        collectionViewCellSize = CGSize(width: collectionViewCellWidth!,
                                        height: collectionViewCellWidth!)
        
        //create
        
        scrollView = UIScrollView()
        scrollView.isScrollEnabled = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        
        
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout:  UICollectionViewFlowLayout())
        collectionView.delaysContentTouches = true
        collectionView.isScrollEnabled = true
        
        collectionView.isHidden = true
        scrollView.isHidden = true
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(collectionView)
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false

        collectionView.register(UINib(nibName: "AlgCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "AlgCollectionViewCell")
        
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false

        
        let centerYMultiplier: CGFloat = 0.93
        NSLayoutConstraint.activate([
            scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: toTheRight) ,
            scrollView.topAnchor.constraint(equalTo: matchingLabel.bottomAnchor, constant: 55),
            scrollView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.75),
            scrollView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.75), // Make it square
            collectionView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            collectionView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            collectionView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])
        
        
    }
    
    private func setUpLabels() {
        stationsLabelImageView.translatesAutoresizingMaskIntoConstraints = false
        roundsLabelImageView.translatesAutoresizingMaskIntoConstraints = false
        
        stationsLabelImageView.isHidden = true
        roundsLabelImageView.isHidden = true
        
        let stationsLabelWidthMultiplier: CGFloat = 116.0 / 281.0
        let roundsLabelHeightMultiplier: CGFloat = 104.0 / 291.0
        
        
        NSLayoutConstraint.activate([
            // Constraints for stationsLabelImageView
            stationsLabelImageView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: stationsLabelWidthMultiplier),
            stationsLabelImageView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            stationsLabelImageView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: -8 - stationsLabelImageView.frame.height),

            // Constraints for roundsLabelImageView
            roundsLabelImageView.heightAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: roundsLabelHeightMultiplier),
            roundsLabelImageView.trailingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: -8), // 5 points to the left of collectionView
            roundsLabelImageView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor)
        ])
    }
    
    private func setUpButtons() {
        duplicatedOpponentsButton = createButton(withTitle: NSLocalizedString("Duplicated Opponent", comment: ""))
        duplicatedStationsButton = createButton(withTitle: NSLocalizedString("Duplicated Station", comment: ""))
        sameRoundDuplicatedButton = createButton(withTitle: NSLocalizedString("Duplicated Appearance", comment: ""))
        view.addSubview(duplicatedOpponentsButton)
        view.addSubview(duplicatedStationsButton)
        view.addSubview(sameRoundDuplicatedButton)
        
        duplicatedOpponentsButton.addTarget(self, action: #selector(duplicatedOpponentsButtonPressed), for: .touchUpInside)
        duplicatedStationsButton.addTarget(self, action: #selector(duplicatedStationsButtonPressed), for: .touchUpInside)
        sameRoundDuplicatedButton.addTarget(self, action: #selector(sameRoundDuplicatedButtonPressed), for: .touchUpInside)
        setButtonConstraints()
    }
    
    private func createButton(withTitle title: String) -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(title, for: .selected)
        button.setTitle(title, for: .normal)
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.titleLabel?.font = getFontForLanguage(font: "GemunuLibre-Medium", size: 20)
        
        var selectedBackgroundImage: UIImage?
        var normalBackgroundImage: UIImage?

        if title == NSLocalizedString("Duplicated Opponent", comment: "") {
            selectedBackgroundImage = UIImage(named: "selected-image-opponents")
            normalBackgroundImage = UIImage(named: "transparent-image-opponents")
        } else if title == NSLocalizedString("Duplicated Station", comment: "") {
            selectedBackgroundImage = UIImage(named: "selected-image-station")
            normalBackgroundImage = UIImage(named: "transparent-image-station")
        } else if title == NSLocalizedString("Duplicated Appearance", comment: "") {
            selectedBackgroundImage = UIImage(named: "selected-image-appearance")
            normalBackgroundImage = UIImage(named: "transparent-image-appearance")
        }

        button.setBackgroundImage(selectedBackgroundImage, for: .selected)
        button.setBackgroundImage(normalBackgroundImage, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.isSelected = true
        return button
    }

    private func setButtonConstraints() {
        duplicatedOpponentsButton.translatesAutoresizingMaskIntoConstraints = false
        duplicatedStationsButton.translatesAutoresizingMaskIntoConstraints = false
        sameRoundDuplicatedButton.translatesAutoresizingMaskIntoConstraints = false
        
        
        let verticalSpacing: CGFloat = 10.0
        // Constraint to keep buttons from interfering with createGameButton

        NSLayoutConstraint.activate([
            duplicatedOpponentsButton.topAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 20.0),
            duplicatedStationsButton.topAnchor.constraint(equalTo:  duplicatedOpponentsButton.bottomAnchor, constant: verticalSpacing),
            sameRoundDuplicatedButton.topAnchor.constraint(equalTo: duplicatedStationsButton.bottomAnchor, constant: verticalSpacing),
            duplicatedOpponentsButton.heightAnchor.constraint(equalToConstant: 35),
            duplicatedStationsButton.heightAnchor.constraint(equalToConstant: 35),
            sameRoundDuplicatedButton.heightAnchor.constraint(equalToConstant: 35),
            duplicatedOpponentsButton.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 0.84),
            duplicatedStationsButton.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 0.84),
            sameRoundDuplicatedButton.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 0.84),
            duplicatedOpponentsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            duplicatedStationsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            sameRoundDuplicatedButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
        let fontSize = duplicatedOpponentsButton.titleLabel?.font.pointSize ?? 20.0
        sameRoundDuplicatedButton.titleLabel?.font = getFontForLanguage(font: "GemunuLibre-Medium", size: fontSize)
        duplicatedOpponentsButton.titleLabel?.font = getFontForLanguage(font: "GemunuLibre-Medium", size: fontSize)
        
    }
    
    
    private func createBorderLines() {
        for i in 0..<pvpGameCount {
            let firstColumn = i * 2 + 1
            let secondColumn = firstColumn + 1
            
            let indexPathFirst = IndexPath(item: firstColumn, section: 0)
            let indexPathSecond = IndexPath(item: secondColumn, section: 0)
            
            if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout,
               let attributesFirst = layout.layoutAttributesForItem(at: indexPathFirst),
               let attributesSecond = layout.layoutAttributesForItem(at: indexPathSecond) {
                
                let midpointX = (attributesFirst.frame.midX + attributesSecond.frame.midX) / 2.0
                
                let borderView = VerticalBorderView(frame: CGRect(x: midpointX - 1, y: 0, width: 2, height: collectionView.contentSize.height))
                borderView.backgroundColor = UIColor(red: 0.18, green: 0.18, blue: 0.21, alpha: 1.00)
                
                collectionView.addSubview(borderView)
            }
        }
        
    }
    
    @objc override func infoAction() {
        let screenWidth = UIScreen.main.bounds.width
        let rectX = (screenWidth - rectWidth) / 2
        let rectY = (UIScreen.main.bounds.height - rectWidth) / 2
        modalRect = CGRect(x: rectX, y: rectY, width: rectWidth, height: rectWidth)

        let firstModalView = FirstAlgGuideView(frame: modalRect)
        view.addSubview(firstModalView)

        firstModalView.onNextButtonTapped = { [weak self] in
            self?.transitionToSecondModalView()
        }
        firstModalView.onCloseButtonTapped = { [weak firstModalView] in
            firstModalView?.removeFromSuperview()
        }
    }
    
    //MARK: - Modal related functions for Guide

    private func transitionToFirstModalView() {
        if let secondModalView = view.subviews.first(where: { $0 is DuplicatedStationGuideView }) {
            secondModalView.removeFromSuperview()
        }
        let firstModalView = FirstAlgGuideView(frame: modalRect)
        view.addSubview(firstModalView)

        firstModalView.onNextButtonTapped = { [weak self] in
            self?.transitionToSecondModalView()
        }
        firstModalView.onCloseButtonTapped = { [weak firstModalView] in
            firstModalView?.removeFromSuperview()
        }
    }
    
    private func transitionToSecondModalView() {
        if let firstModalView = view.subviews.first(where: { $0 is FirstAlgGuideView }) {
            firstModalView.removeFromSuperview()
        }
        if let thirdModalView = view.subviews.first(where: { $0 is SameRoundGuideView }) {
            thirdModalView.removeFromSuperview()
        }

        let secondModalView = DuplicatedStationGuideView(frame: modalRect)
        view.addSubview(secondModalView)
        
        secondModalView.onCloseButtonTapped = { [weak secondModalView] in
            secondModalView?.removeFromSuperview()
        }
        secondModalView.onNextButtonTapped = { [weak self] in
            self?.transitionToThirdModalView()
        }
        secondModalView.onPreviousButtonTapped = { [weak self] in
            self?.transitionToFirstModalView()
        }
    }
    
    private func transitionToThirdModalView() {
        if let secondModalView = view.subviews.first(where: { $0 is DuplicatedStationGuideView }) {
            secondModalView.removeFromSuperview()
        }
        if let fourthModalView = view.subviews.first(where: { $0 is DuplicatedOppGuideView }) {
            fourthModalView.removeFromSuperview()
        }
        
        let thirdModalView = SameRoundGuideView(frame: modalRect)
        view.addSubview(thirdModalView)
        
        thirdModalView.onCloseButtonTapped = { [weak thirdModalView] in
            thirdModalView?.removeFromSuperview()
        }
        thirdModalView.onNextButtonTapped = { [weak self] in
            self?.transitionToFourthModalView()
        }
        thirdModalView.onPreviousButtonTapped = { [weak self] in
            self?.transitionToSecondModalView()
        }
    }
    
    private func transitionToFourthModalView() {
        if let thirdModalView = view.subviews.first(where: { $0 is SameRoundGuideView }) {
            thirdModalView.removeFromSuperview()
        }
        if let fifthModalView = view.subviews.first(where: { $0 is MultiErrorGuideView }) {
            fifthModalView.removeFromSuperview()
        }
        
        let fourthModalView = DuplicatedOppGuideView(frame: modalRect)
        view.addSubview(fourthModalView)
        
        fourthModalView.onCloseButtonTapped = { [weak fourthModalView] in
            fourthModalView?.removeFromSuperview()
        }
        fourthModalView.onNextButtonTapped = { [weak self] in
            self?.transitionToFifthModalView()
        }
        fourthModalView.onPreviousButtonTapped = { [weak self] in
            self?.transitionToThirdModalView()
        }
    }
    
    private func transitionToFifthModalView() {
        if let fourthModalView = view.subviews.first(where: { $0 is DuplicatedOppGuideView }) {
            fourthModalView.removeFromSuperview()
        }
        let fifthModalView = MultiErrorGuideView(frame: modalRect)
        view.addSubview(fifthModalView)
        
        fifthModalView.onCloseButtonTapped = { [weak fifthModalView] in
            fifthModalView?.removeFromSuperview()
        }
        fifthModalView.onPreviousButtonTapped = { [weak self] in
            self?.transitionToFourthModalView()
        }

    }
    
    
}




extension ManualAlgorithmViewController : UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if !self.stationList!.isEmpty && self.host != nil{
            if num_stations < 8 {
                return 8
            } else {
                return cellDataGrid[section].count
            }
        } else {
            return 0
        }

    }
    func numberOfSections(in collectionView: UICollectionView) -> Int{
        if !(self.stationList?.isEmpty ?? true) && self.host != nil {
            return cellDataGrid.count
        } else {
            return 0
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Selected cell at IndexPath: \(indexPath)")
        
        if let testcell = collectionView.cellForItem(at:IndexPath(item: 0, section: 1 )) as? AlgCollectionViewCell {
            print( "???? ???? ",testcell.isUserInteractionEnabled)
        }
        if cellDataA == nil {
            cellDataA = cellDataGrid[indexPath.section][indexPath.item]
            changeCellGridData(cellDataInstance: cellDataA!, to: "selected")
            let indexPathA = IndexPath(item: indexPath.item, section: indexPath.section )
            if let selectedCellA = collectionView.cellForItem(at: indexPathA) as? AlgCollectionViewCell {
                selectedCellA.makeCellSelected()
            }

        } else if cellDataB == nil {
            // Second selection
            cellDataB = cellDataGrid[indexPath.section][indexPath.item]
            changeCellGridData(cellDataInstance: cellDataB!, to: "selected")
            let indexPathB = IndexPath(item: indexPath.item, section: indexPath.section )
            if let selectedCellB = collectionView.cellForItem(at: indexPathB) as? AlgCollectionViewCell {
                selectedCellB.makeCellSelected()
            }
        }
        if let cellDataAIndex = cellDataA?.cellIndex, let cellDataBIndex = cellDataB?.cellIndex {
            let indexPathA = IndexPath(item: cellDataAIndex.second, section: cellDataAIndex.first)
            let indexPathB = IndexPath(item: cellDataBIndex.second, section: cellDataBIndex.first)
    
            collectionView.performBatchUpdates({
                collectionView.moveItem(at: indexPathA, to: indexPathB)
                collectionView.moveItem(at: indexPathB, to: indexPathA)
    
                }, completion: { _ in

                    self.cellDataGrid[cellDataAIndex.first][cellDataAIndex.second] = self.cellDataB!
                    self.cellDataGrid[cellDataBIndex.first][cellDataBIndex.second] = self.cellDataA!
                    self.cellDataGrid[cellDataAIndex.first][cellDataAIndex.second].cellIndex = cellDataAIndex
                    self.cellDataGrid[cellDataBIndex.first][cellDataBIndex.second].cellIndex = cellDataBIndex
    
                    self.changeCellGridData(cellDataInstance: self.cellDataA!, to: "deselected")
                    self.changeCellGridData(cellDataInstance: self.cellDataB!, to: "deselected")
    

                    let selectedCellA = collectionView.cellForItem(at: indexPathA) as? AlgCollectionViewCell
                    let selectedCellB = collectionView.cellForItem(at: indexPathB) as? AlgCollectionViewCell
                    selectedCellA?.makeCellOriginal()
                    selectedCellB?.makeCellOriginal()
                    print("swap completed")
    
                    self.cellDataA = nil
                    self.cellDataB = nil
    
                    self.resetAll()
                    self.reloadAll()
                    self.collectionView.reloadData()
            })
        }
    }
    
    
    
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AlgCollectionViewCell.identifier, for: indexPath) as? AlgCollectionViewCell else {
                return UICollectionViewCell()
            }


            let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
            cell.addGestureRecognizer(longPressGestureRecognizer)


            let cellData = cellDataGrid[indexPath.section][indexPath.item]
            let teamNumberLabel = cellData.number

            if teamNumberLabel == -1 {
                cell.makeCellInvisible()
            } else if teamNumberLabel == 0 {
                cell.makeCellEmpty()
            }  else {
                    cell.configureAlgorithmNormalCell(cellteamnum : teamNumberLabel!)

                    if cellData.hasPvpBlueWarning && !cellData.hasRedWarning {
                        cell.makeBlueWarning()
                    } else if (cellData.hasPvpYellowWarning || cellData.hasYellowWarning) && !cellData.hasRedWarning {
                        cell.makeYellowWarning()
                    } else if cellData.hasPurpleWarning && !cellData.hasRedWarning {
                        cell.makePurpleWarning()
                    } else if cellData.hasRedWarning {
                        cell.makeRedWarning()
                    }
            }
            return cell
        }
    
        func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
            let cellNumber = cellDataGrid[indexPath.section][indexPath.item].number
    
            if shouldDisableInteraction(for: cellNumber!) {
                return false
            }
    
            return true
        }
    
        func shouldDisableInteraction(for cellNumber: Int) -> Bool {
            return cellNumber == -1
        }
    
    
        @objc func handleLongPress(_ sender: UILongPressGestureRecognizer) {
            guard let cell = sender.view as? AlgCollectionViewCell else { return }
    
            if sender.state == .began {
                    let alertController = UIAlertController(title: "Enter the team number", message: nil, preferredStyle: .alert)
                    alertController.addTextField { textField in
                    textField.keyboardType = .numberPad
                }
                alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { action in
                    cell.isSelected = false
                    alertController.dismiss(animated: true, completion: nil)
                }))
    
                alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { action in
                    if let numberString = alertController.textFields?.first?.text,
                    let number = Int(numberString) {
                        if number > self.num_teams {
                            self.alert(title: NSLocalizedString("Invalid Team Number", comment: ""), message: NSLocalizedString("The team number is too big. Check again!", comment: ""))
                            return
                        }
                        cell.numberLabel.text = "\(number)"
                        if number == 0 {
                            cell.makeCellEmpty()
                        }
                        if let indexPath = self.collectionView.indexPath(for: cell) {
                            let section = indexPath.section
                            let item = indexPath.item
                            self.cellDataGrid[section][item].changeCellData(number: number, visible: true)
                            cell.number = number
                        }
                        self.resetAll()
                        self.reloadAll()
    
                        cell.isSelected = false
                    }
    
                    alertController.dismiss(animated: true, completion: nil)
                }))
                present(alertController, animated: true, completion: nil)
            }
        }
}


extension ManualAlgorithmViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == collectionView.numberOfSections - 1 {
            return UIEdgeInsets(top: 0, left:collectionViewCellSpacing, bottom: 0, right: collectionViewCellSpacing)
        } else if section == 0{
            return UIEdgeInsets(top: 0, left:collectionViewCellSpacing, bottom: collectionViewCellSpacing, right: collectionViewCellSpacing)
        }else {
            return UIEdgeInsets(top: 0, left:collectionViewCellSpacing, bottom: collectionViewCellSpacing, right: collectionViewCellSpacing)
        }
    }
}

extension ManualAlgorithmViewController : ModalViewControllerDelegate {
    func modalViewControllerDidRequestPush() {
        Task { @MainActor in
            do {
                let grid =  createIntegerGrid()
                let temp = convert2DArrayTo1D(grid)
                try await H.setAlgorithm(gamecode, temp)
            }

        }
        pushTabBarController()
    }

    private func pushTabBarController() {
        let storyboard = UIStoryboard(name: "Host", bundle: nil)
        if let tabBarController = storyboard.instantiateViewController(withIdentifier: "HostTabBarController") as? UITabBarController {
            tabBarController.selectedIndex = 0
            UserData.confirmHost(true)
            print("confirm host")
            navigationController?.pushViewController(tabBarController, animated: true)
        }
    }
}
// MARK: - showStationListView PopUp
extension ManualAlgorithmViewController {
    private func showStationListPopUp(stations: [Station]) {
        let popUpViewController = StationListViewController(stations: stations)
        present(popUpViewController, animated: false, completion: nil)
    }
    
    private func addTapGesture(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(stationLabelTapped(_:)))
        stationsLabelImageView.isUserInteractionEnabled = true
        stationsLabelImageView.addGestureRecognizer(tapGesture)
    }
    
    @objc func stationLabelTapped(_ sender: UITapGestureRecognizer) {
        Task { @MainActor in
            do {
                let stationList = try await S.getStationList(gamecode)
                print(stationList)
                showStationListPopUp(stations: stationList)
            } catch GameWalkerError.serverError(let e) {
                print(e)
                serverAlert(e)
                return
            }
        }
    }
}

extension ManualAlgorithmViewController {
    private func checkAndGetPvpDefaultAlgorithm(_ rounds: Int, _ stations: Int, _ teams: Int) -> [[CellData]]? {
        if(rounds != stations || rounds*2 != teams){
            return nil
        }

        //MARK: - Standard Setup - works for odd number rounds cases
        var result = Array(repeating: Array(repeating: 0, count: teams), count: rounds)

        for num in 1...teams {
            result[0][num-1] = num
        }

        //odd number diagonal
        for row in 1..<rounds {
            for col in stride(from: 0, to: teams, by: 2){
                result[row][col] = result[row-1][(col-2+teams)%teams]
            }
        }

        //even number diagonal
        for row in 1..<rounds {
            for col in stride(from: 1, to: teams, by: 2){
                result[row][col] = result[row-1][(col+2)%teams]
            }
        }

        //MARK: - Even rounds & stations
        if teams%4 == 0 && teams >= 8 {
            var half = rounds/2
            if half%2 == 0 {
                for loop in 0..<half {
                    for num in 0..<(teams/4) {
                        if loop%2 == 0{
                            var temp = result[half+loop][num*4]
                            result[half+loop][num*4] = result[half+loop][3+num*4]
                            result[half+loop][3+num*4] = temp
                        } else {
                            var temp = result[half+loop][1+num*4]
                            result[half+loop][1+num*4] = result[half+loop][2+num*4]
                            result[half+loop][2+num*4] = temp
                        }
                    }
                }
            } else {
                for loop in 0..<half-1 {
                    for num in 0..<(teams/4) {
                        if loop%2 == 0{
                            var temp = result[half+loop][num*4]
                            result[half+loop][num*4] = result[half+loop][3+num*4]
                            result[half+loop][3+num*4] = temp
                        } else {
                            var temp = result[half+loop][1+num*4]
                            result[half+loop][1+num*4] = result[half+loop][2+num*4]
                            result[half+loop][2+num*4] = temp
                        }
                    }
                }
            }
        }
        guard !result.isEmpty, !result[0].isEmpty else {
            return nil
        }
        // Convert result to CellData format
        var cellDataGrid = [[CellData]]()
        for (rowIndex, row) in result.enumerated() {
            var rowData = [CellData]()
            for (columnIndex, num) in row.enumerated() {
                let cellData = CellData(number: num, visible: true, index: IntPair(first: rowIndex, second: columnIndex))
                rowData.append(cellData)
            }
            cellDataGrid.append(rowData)
        }
        return cellDataGrid
    }
}

// MARK: - stationListViewController
class StationListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var stationList: [Station] = []
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(cgColor: .init(red: 0.843, green: 0.502, blue: 0.976, alpha: 1))
        view.layer.cornerRadius = 20
        
        ///for animation effect
        view.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        
        return view
    }()
    
    private lazy var  stationLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Station List", comment: "")
        label.font = getFontForLanguage(font: "GemunuLibre-SemiBold", size: 40)
        label.textAlignment = .center
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let stationTableView: UITableView = {
        let tableview = UITableView()
        return tableview
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = getFontForLanguage(font: "GemunuLibre-Bold", size: 20)
        
        // enable
        button.setTitle(NSLocalizedString("Close", comment: ""), for: .normal)
        button.setTitleColor(UIColor(cgColor: .init(red: 0.843, green: 0.502, blue: 0.976, alpha: 1)), for: .normal)
        button.setBackgroundImage(UIColor.white.image(), for: .normal)
        
        // disable
        button.setTitleColor(.gray, for: .disabled)
        button.setBackgroundImage(UIColor.gray.image(), for: .disabled)
        
        // layer
        button.layer.cornerRadius = 6
        button.layer.masksToBounds = true
        
        button.addTarget(self, action: #selector(close), for: .touchUpInside)
        
        return button
    }()
    
    @objc private func close() {
        dismiss(animated: true, completion: nil)
    }
    
    convenience init(stations: [Station]) {
        self.init()
        /// present 시 fullScreen (화면을 덮도록 설정) -> 설정 안하면 pageSheet 형태 (위가 좀 남아서 밑에 깔린 뷰가 보이는 형태)
        self.stationList = stations
        self.modalPresentationStyle = .overFullScreen
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        //curveEaseOut: 시작은 천천히, 끝날 땐 빠르게
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut) { [weak self] in
            self?.containerView.transform = .identity
            self?.containerView.isHidden = false
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        //curveEaseIn: 시작은 빠르게, 끝날 땐 천천히
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn) { [weak self] in
            self?.containerView.transform = .identity
            self?.containerView.isHidden = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        setUpViews()
        makeConstraints()
        print(self.stationList)
    }

    private func configureTableView() {
        stationTableView.delegate = self
        stationTableView.dataSource = self
        stationTableView.register(StationTableViewCell.self, forCellReuseIdentifier: StationTableViewCell.identifier)
        stationTableView.backgroundColor = .clear
        stationTableView.allowsSelection = false
        stationTableView.separatorStyle = .none
        stationTableView.allowsSelection = true
        stationTableView.allowsMultipleSelection = false
        stationTableView.backgroundColor = UIColor(cgColor: .init(red: 0.843, green: 0.502, blue: 0.976, alpha: 1))
    }
    
    private func setUpViews() {
        self.view.addSubview(containerView)
        containerView.addSubview(stationLabel)
        containerView.addSubview(stationTableView)
        containerView.addSubview(closeButton)
        self.view.backgroundColor = .black.withAlphaComponent(0.2)
    }
    
    private func makeConstraints() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        stationLabel.translatesAutoresizingMaskIntoConstraints = false
        stationTableView.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            containerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 210),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -210),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            stationLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            stationLabel.widthAnchor.constraint(equalToConstant: 250),
            stationLabel.heightAnchor.constraint(equalToConstant: 45),
            stationLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            stationTableView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 40),
            stationTableView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -40),
            stationTableView.topAnchor.constraint(equalTo: stationLabel.bottomAnchor, constant: 5),
            stationTableView.bottomAnchor.constraint(equalTo: closeButton.topAnchor, constant: -15),
            stationTableView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            closeButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20),
            closeButton.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.3877),
            closeButton.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.12424),
            closeButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
        ])
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = stationTableView.dequeueReusableCell(withIdentifier: StationTableViewCell.identifier, for: indexPath) as! StationTableViewCell
        let ind = String(indexPath.item + 1)
        cell.configureTableViewCell(index: "\(ind).", name: "\(self.stationList[indexPath.row].name)")
        cell.selectionStyle = .none
        return cell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stationList.count
     }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
}

// MARK: - stationTableViewCell
class StationTableViewCell: UITableViewCell {
    static let identifier = "StationTableViewCell"
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(cgColor: .init(red: 0.843, green: 0.502, blue: 0.976, alpha: 1))
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var indexLbl: UILabel = {
       let label = UILabel()
        label.backgroundColor = UIColor(cgColor: .init(red: 0.843, green: 0.502, blue: 0.976, alpha: 1))
        label.font = UIFont(name: "Dosis-Bold", size: 20)
        label.textAlignment = .center
        label.numberOfLines = 1
        label.clipsToBounds = true
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var stationLabel: UILabel = {
        let label = UILabel()
         label.backgroundColor = UIColor(cgColor: .init(red: 0.843, green: 0.502, blue: 0.976, alpha: 1))
         label.font = UIFont(name: "Dosis-Bold", size: 20)
         label.textAlignment = .left
         label.numberOfLines = 1
         label.clipsToBounds = true
         label.textColor = .white
         label.translatesAutoresizingMaskIntoConstraints = false
         return label
     }()
    
    private lazy var borderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.borderWidth = 3
        return view
    }()
    
    func configureTableViewCell(index: String, name: String) {
        contentView.addSubview(containerView)
        containerView.addSubview(indexLbl)
        containerView.addSubview(stationLabel)
        containerView.addSubview(borderView)
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            indexLbl.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            indexLbl.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 1),
            indexLbl.widthAnchor.constraint(equalTo: self.heightAnchor, multiplier: 1),
            indexLbl.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            stationLabel.leadingAnchor.constraint(equalTo: indexLbl.trailingAnchor),
            stationLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            stationLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
            stationLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            borderView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            borderView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            borderView.heightAnchor.constraint(equalToConstant: 2.0),
            borderView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        indexLbl.text = index
        stationLabel.text = name
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
