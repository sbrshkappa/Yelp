//
//  FiltersViewController.swift
//  Yelp
//
//  Created by Sabareesh Kappagantu on 4/8/17.
//  Copyright © 2017 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol FiltersViewControllerDelegate {
    @objc optional func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String:AnyObject])
}

class FiltersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,SwitchCellDelegate {

    @IBOutlet weak var filterTableView: UITableView!
    var categories: [[String:String]]!
    var sorts: [[String:String]]!
    var distances: [[String: String]]!
    var switchStates = [IndexPath:Bool]()
    weak var delegate: FiltersViewControllerDelegate?
    
    //Checkers to see if a section has been selected
    var distanceSelected: Bool! = false
    var sortSelected: Bool! = false
    var categoriesExpanded: Bool! = false
    
    //default values for filters
    var defaultDistance: Int! = 8046
    var defaultDistanceText: String! = "Auto"
    var defaultSort: Int! = 0
    var defaultSortText: String! = "Best Match"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        filterTableView.delegate = self
        filterTableView.dataSource = self
        filterTableView.rowHeight = UITableViewAutomaticDimension
        filterTableView.estimatedRowHeight = 40
        filterTableView.backgroundColor = UIColor.clear

        categories = yelpCategories()
        sorts = yelpSorts()
        distances = yelpDistances()
        
        
        navigationController?.navigationBar.barTintColor = UIColor.red
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //TableView Delegates
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return ""
        case 1:
            return "Distance"
        case 2:
            return "Sort By"
        default:
            return "Cateogry"
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return distanceSelected! ? distances.count : 1
        case 2:
            return sortSelected! ? sorts.count : 1
        case 3:
            return categoriesExpanded! ? categories.count : 5
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = filterTableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as! SwitchCell
        switch indexPath.section {
            case 0:
                cell.switchLabel.text = "Offering Deals"
            case 1:
                if indexPath.row == 0 && !distanceSelected {
                    cell.switchLabel.text = defaultDistanceText
                } else {
                    cell.switchLabel.text = distances[indexPath.row]["name"]
                }
            
            case 2:
                if indexPath.row == 0 && !sortSelected {
                    cell.switchLabel.text = defaultSortText
                } else {
                    cell.switchLabel.text = sorts[indexPath.row]["name"]

                }
            default:
                if indexPath.row == 4 && !categoriesExpanded {
                    cell.switchLabel.text = "See All"
                    cell.switchLabel.textColor = UIColor.lightGray
                    cell.onSwitch.isHidden = true
                } else {
                    cell.switchLabel.text = categories[indexPath.row]["name"]
                    cell.switchLabel.textColor = UIColor.black
                    cell.onSwitch.isHidden = false
                }
        }
        cell.delegate = self
        cell.onSwitch.isOn = switchStates[indexPath] ?? false
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            switch distanceSelected {
                case true:
                    defaultDistance = Int(distances[indexPath.row]["code"]!)
                    defaultDistanceText = distances[indexPath.row]["name"]
                    distanceSelected = false
                    filterTableView.reloadSections(IndexSet([indexPath.section]), with: .automatic)
                default:
                    distanceSelected = true
                    filterTableView.reloadSections(IndexSet([indexPath.section]), with: .automatic)
            }
        } else if indexPath.section == 2 {
            switch sortSelected {
                case true:
                    defaultSort = Int(sorts[indexPath.row]["code"]!)
                    defaultSortText = sorts[indexPath.row]["name"]
                    sortSelected = false
                    filterTableView.reloadData()
                default:
                    sortSelected = true
                    filterTableView.reloadSections(IndexSet([indexPath.section]), with: .automatic)
            }
        } else if indexPath.section == 3 {
            switch categoriesExpanded {
                case true:
                    categoriesExpanded = false
                    filterTableView.reloadSections(IndexSet([indexPath.section]), with: .automatic)
                default:
                    categoriesExpanded = true
                    filterTableView.reloadData()
            }
        }
    }
    
   
    
    func switchCell(switchCell: SwitchCell, didChangeValue value: Bool) {
        let indexPath = filterTableView.indexPath(for: switchCell)!
        switchStates[indexPath] = value
    }
    

    @IBAction func onCancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func onSearchButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        var filters = [String : AnyObject]()
        var selectedCategories = [String]()
        var selectedSort: Int
        var offeringDeals: Bool
        var selectedDistance: Int
            for (index, isSelected) in switchStates {
                if(isSelected && index.section == 0){
                    print(index.row)
                    print("Offering Deals")
                    offeringDeals = true
                    filters["deals_filter"] = offeringDeals as AnyObject
                }
                if(isSelected && index.section == 1){
                    print(index.row)
                    print(distances[index.row]["name"] ?? "Random String")
                    selectedDistance = Int(distances[index.row]["code"]!)!
                    filters["radius_filter"] = selectedDistance as AnyObject
                }
                if(isSelected && index.section == 2){
                    print(index.row)
                    print(sorts[index.row]["name"] ?? "Random String")
                    selectedSort = Int(sorts[index.row]["code"]!)!
                    filters["sort"] = YelpSortMode(rawValue: selectedSort) as AnyObject
                }
                if(isSelected && index.section == 3) {
                    print(index.row)
                    print(categories[index.row]["name"] ?? "Random String")
                    selectedCategories.append(categories[index.row]["code"]!)
                }
            }
        
        if selectedCategories.count > 0 {
            filters["categories"] = selectedCategories as AnyObject
        }
        delegate?.filtersViewController?(filtersViewController: self, didUpdateFilters: filters)
    }
    
    func yelpDistances () -> [[String: String]]{
        return [["name": "Auto", "code": "8046"],
                ["name": "0.3 miles", "code": "483"],
                ["name": "5 miles", "code": "9000"],
                ["name": "10 miles", "code": "20000"],
                ["name": "25 miles", "code": "40000"]]
    }
    
    func yelpSorts () -> [[String: String]]{
        return [["name": "Best Match", "code": "0"],
        ["name": "Distance", "code": "1"],
        ["name": "Highest Rated", "code": "2"]]
    }
    
    func yelpCategories () -> [[String: String]]{
        return [["name" : "Afghan", "code": "afghani"],
         ["name" : "African", "code": "african"],
         ["name" : "American, New", "code": "newamerican"],
         ["name" : "American, Traditional", "code": "tradamerican"],
         ["name" : "Arabian", "code": "arabian"],
         ["name" : "Argentine", "code": "argentine"],
         ["name" : "Armenian", "code": "armenian"],
         ["name" : "Asian Fusion", "code": "asianfusion"],
         ["name" : "Asturian", "code": "asturian"],
         ["name" : "Australian", "code": "australian"],
         ["name" : "Austrian", "code": "austrian"],
         ["name" : "Baguettes", "code": "baguettes"],
         ["name" : "Bangladeshi", "code": "bangladeshi"],
         ["name" : "Barbeque", "code": "bbq"],
         ["name" : "Basque", "code": "basque"],
         ["name" : "Bavarian", "code": "bavarian"],
         ["name" : "Beer Garden", "code": "beergarden"],
         ["name" : "Beer Hall", "code": "beerhall"],
         ["name" : "Beisl", "code": "beisl"],
         ["name" : "Belgian", "code": "belgian"],
         ["name" : "Bistros", "code": "bistros"],
         ["name" : "Black Sea", "code": "blacksea"],
         ["name" : "Brasseries", "code": "brasseries"],
         ["name" : "Brazilian", "code": "brazilian"],
         ["name" : "Breakfast & Brunch", "code": "breakfast_brunch"],
         ["name" : "British", "code": "british"],
         ["name" : "Buffets", "code": "buffets"],
         ["name" : "Bulgarian", "code": "bulgarian"],
         ["name" : "Burgers", "code": "burgers"],
         ["name" : "Burmese", "code": "burmese"],
         ["name" : "Cafes", "code": "cafes"],
         ["name" : "Cafeteria", "code": "cafeteria"],
         ["name" : "Cajun/Creole", "code": "cajun"],
         ["name" : "Cambodian", "code": "cambodian"],
         ["name" : "Canadian", "code": "New)"],
         ["name" : "Canteen", "code": "canteen"],
         ["name" : "Caribbean", "code": "caribbean"],
         ["name" : "Catalan", "code": "catalan"],
         ["name" : "Chech", "code": "chech"],
         ["name" : "Cheesesteaks", "code": "cheesesteaks"],
         ["name" : "Chicken Shop", "code": "chickenshop"],
         ["name" : "Chicken Wings", "code": "chicken_wings"],
         ["name" : "Chilean", "code": "chilean"],
         ["name" : "Chinese", "code": "chinese"],
         ["name" : "Comfort Food", "code": "comfortfood"],
         ["name" : "Corsican", "code": "corsican"],
         ["name" : "Creperies", "code": "creperies"],
         ["name" : "Cuban", "code": "cuban"],
         ["name" : "Curry Sausage", "code": "currysausage"],
         ["name" : "Cypriot", "code": "cypriot"],
         ["name" : "Czech", "code": "czech"],
         ["name" : "Czech/Slovakian", "code": "czechslovakian"],
         ["name" : "Danish", "code": "danish"],
         ["name" : "Delis", "code": "delis"],
         ["name" : "Diners", "code": "diners"],
         ["name" : "Dumplings", "code": "dumplings"],
         ["name" : "Eastern European", "code": "eastern_european"],
         ["name" : "Ethiopian", "code": "ethiopian"],
         ["name" : "Fast Food", "code": "hotdogs"],
         ["name" : "Filipino", "code": "filipino"],
         ["name" : "Fish & Chips", "code": "fishnchips"],
         ["name" : "Fondue", "code": "fondue"],
         ["name" : "Food Court", "code": "food_court"],
         ["name" : "Food Stands", "code": "foodstands"],
         ["name" : "French", "code": "french"],
         ["name" : "French Southwest", "code": "sud_ouest"],
         ["name" : "Galician", "code": "galician"],
         ["name" : "Gastropubs", "code": "gastropubs"],
         ["name" : "Georgian", "code": "georgian"],
         ["name" : "German", "code": "german"],
         ["name" : "Giblets", "code": "giblets"],
         ["name" : "Gluten-Free", "code": "gluten_free"],
         ["name" : "Greek", "code": "greek"],
         ["name" : "Halal", "code": "halal"],
         ["name" : "Hawaiian", "code": "hawaiian"],
         ["name" : "Heuriger", "code": "heuriger"],
         ["name" : "Himalayan/Nepalese", "code": "himalayan"],
         ["name" : "Hong Kong Style Cafe", "code": "hkcafe"],
         ["name" : "Hot Dogs", "code": "hotdog"],
         ["name" : "Hot Pot", "code": "hotpot"],
         ["name" : "Hungarian", "code": "hungarian"],
         ["name" : "Iberian", "code": "iberian"],
         ["name" : "Indian", "code": "indpak"],
         ["name" : "Indonesian", "code": "indonesian"],
         ["name" : "International", "code": "international"],
         ["name" : "Irish", "code": "irish"],
         ["name" : "Island Pub", "code": "island_pub"],
         ["name" : "Israeli", "code": "israeli"],
         ["name" : "Italian", "code": "italian"],
         ["name" : "Japanese", "code": "japanese"],
         ["name" : "Jewish", "code": "jewish"],
         ["name" : "Kebab", "code": "kebab"],
         ["name" : "Korean", "code": "korean"],
         ["name" : "Kosher", "code": "kosher"],
         ["name" : "Kurdish", "code": "kurdish"],
         ["name" : "Laos", "code": "laos"],
         ["name" : "Laotian", "code": "laotian"],
         ["name" : "Latin American", "code": "latin"],
         ["name" : "Live/Raw Food", "code": "raw_food"],
         ["name" : "Lyonnais", "code": "lyonnais"],
         ["name" : "Malaysian", "code": "malaysian"],
         ["name" : "Meatballs", "code": "meatballs"],
         ["name" : "Mediterranean", "code": "mediterranean"],
         ["name" : "Mexican", "code": "mexican"],
         ["name" : "Middle Eastern", "code": "mideastern"],
         ["name" : "Milk Bars", "code": "milkbars"],
         ["name" : "Modern Australian", "code": "modern_australian"],
         ["name" : "Modern European", "code": "modern_european"],
         ["name" : "Mongolian", "code": "mongolian"],
         ["name" : "Moroccan", "code": "moroccan"],
         ["name" : "New Zealand", "code": "newzealand"],
         ["name" : "Night Food", "code": "nightfood"],
         ["name" : "Norcinerie", "code": "norcinerie"],
         ["name" : "Open Sandwiches", "code": "opensandwiches"],
         ["name" : "Oriental", "code": "oriental"],
         ["name" : "Pakistani", "code": "pakistani"],
         ["name" : "Parent Cafes", "code": "eltern_cafes"],
         ["name" : "Parma", "code": "parma"],
         ["name" : "Persian/Iranian", "code": "persian"],
         ["name" : "Peruvian", "code": "peruvian"],
         ["name" : "Pita", "code": "pita"],
         ["name" : "Pizza", "code": "pizza"],
         ["name" : "Polish", "code": "polish"],
         ["name" : "Portuguese", "code": "portuguese"],
         ["name" : "Potatoes", "code": "potatoes"],
         ["name" : "Poutineries", "code": "poutineries"],
         ["name" : "Pub Food", "code": "pubfood"],
         ["name" : "Rice", "code": "riceshop"],
         ["name" : "Romanian", "code": "romanian"],
         ["name" : "Rotisserie Chicken", "code": "rotisserie_chicken"],
         ["name" : "Rumanian", "code": "rumanian"],
         ["name" : "Russian", "code": "russian"],
         ["name" : "Salad", "code": "salad"],
         ["name" : "Sandwiches", "code": "sandwiches"],
         ["name" : "Scandinavian", "code": "scandinavian"],
         ["name" : "Scottish", "code": "scottish"],
         ["name" : "Seafood", "code": "seafood"],
         ["name" : "Serbo Croatian", "code": "serbocroatian"],
         ["name" : "Signature Cuisine", "code": "signature_cuisine"],
         ["name" : "Singaporean", "code": "singaporean"],
         ["name" : "Slovakian", "code": "slovakian"],
         ["name" : "Soul Food", "code": "soulfood"],
         ["name" : "Soup", "code": "soup"],
         ["name" : "Southern", "code": "southern"],
         ["name" : "Spanish", "code": "spanish"],
         ["name" : "Steakhouses", "code": "steak"],
         ["name" : "Sushi Bars", "code": "sushi"],
         ["name" : "Swabian", "code": "swabian"],
         ["name" : "Swedish", "code": "swedish"],
         ["name" : "Swiss Food", "code": "swissfood"],
         ["name" : "Tabernas", "code": "tabernas"],
         ["name" : "Taiwanese", "code": "taiwanese"],
         ["name" : "Tapas Bars", "code": "tapas"],
         ["name" : "Tapas/Small Plates", "code": "tapasmallplates"],
         ["name" : "Tex-Mex", "code": "tex-mex"],
         ["name" : "Thai", "code": "thai"],
         ["name" : "Traditional Norwegian", "code": "norwegian"],
         ["name" : "Traditional Swedish", "code": "traditional_swedish"],
         ["name" : "Trattorie", "code": "trattorie"],
         ["name" : "Turkish", "code": "turkish"],
         ["name" : "Ukrainian", "code": "ukrainian"],
         ["name" : "Uzbek", "code": "uzbek"],
         ["name" : "Vegan", "code": "vegan"],
         ["name" : "Vegetarian", "code": "vegetarian"],
         ["name" : "Venison", "code": "venison"],
         ["name" : "Vietnamese", "code": "vietnamese"],
         ["name" : "Wok", "code": "wok"],
         ["name" : "Wraps", "code": "wraps"],
         ["name" : "Yugoslav", "code": "yugoslav"]]
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
