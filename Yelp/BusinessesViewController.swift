//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FiltersViewControllerDelegate, UISearchBarDelegate {
    
    var businesses: [Business]!
    @IBOutlet weak var yelpTableView: UITableView!
    let searchBar = UISearchBar()
    var filteredBusinesses: [Business]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        yelpTableView.delegate = self
        yelpTableView.dataSource = self
        yelpTableView.rowHeight = UITableViewAutomaticDimension
        yelpTableView.estimatedRowHeight = 120
        
        Business.searchWithTerm(term: "Restaurants", completion: { (businesses: [Business]?, error: Error?) -> Void in
            
            self.businesses = businesses
            self.filteredBusinesses = self.businesses
            self.yelpTableView.reloadData()
            if let businesses = businesses {
                for business in businesses {
                    print(business.name!)
                    print(business.address!)
                }
            }
          }
        )
        
        searchBar.delegate = self
        searchBar.sizeToFit()
        navigationItem.titleView = searchBar
        
        
        /* Example of Yelp search with more search options specified
         Business.searchWithTerm("Restaurants", sort: .Distance, categories: ["asianfusion", "burgers"], deals: true) { (businesses: [Business]!, error: NSError!) -> Void in
         self.businesses = businesses
         
         for business in businesses {
         print(business.name!)
         print(business.address!)
         }
         }
         */
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //TableViewDelegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filteredBusinesses != nil {
            return filteredBusinesses.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = yelpTableView.dequeueReusableCell(withIdentifier: "BusinessCell", for: indexPath) as! BusinessCell
        cell.business = filteredBusinesses[indexPath.row]
        return cell
    }
    
    //SearchBar Delegates
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredBusinesses = searchText.isEmpty ? businesses : businesses.filter(){(business: Business) -> Bool in
            return (business.name)?.range(of: searchText, options: .caseInsensitive) != nil
        }
        yelpTableView.reloadData()
    }
    
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navigationController = segue.destination as! UINavigationController
        let filtersViewController = navigationController.topViewController as! FiltersViewController
        filtersViewController.delegate = self
    }
    
    func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String : AnyObject]) {
        let categories = filters["categories"] as? [String]
        let sort = filters["sort"] as? YelpSortMode
        let deals = filters["deals_filter"] as? Bool
        let distance = filters["radius_filter"] as? Int
        Business.searchWithTerm(term: "Restaurants", sort: sort, categories: categories, distance: distance, deals: deals,
                                completion: ({businesses, error -> Void in
                self.businesses = businesses
                self.filteredBusinesses = businesses
                self.yelpTableView.reloadData()
        }))
    }
}
