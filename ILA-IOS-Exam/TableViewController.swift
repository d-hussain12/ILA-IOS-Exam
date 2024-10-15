//
//  ViewController.swift
//  SearchTableViewExample
//
//  Created by John Codeos on 1/18/20.
//  Copyright © 2020 John Codeos. All rights reserved.
//

import UIKit

class TableViewController: UIViewController {
    @IBOutlet var searchBar: UISearchBar!
    
    @IBOutlet var tableView: UITableView!
    
    var countryList = [String]()
    
    var searchedCountry = [String]()
    var searching = false
    
    var selected: String?
    
    var pageCount = 0
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!

    let imageNames = ["imagedan", "bisb", "ila"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.searchBar.delegate = self
        
        self.searchBar.barTintColor = UIColor.colorFromHex("#BC214B")
        self.searchBar.tintColor = UIColor.white
        self.searchBar.showsCancelButton = true
        let searchTextField = self.searchBar.searchTextField
        searchTextField.textColor = UIColor.white
        searchTextField.clearButtonMode = .never
        searchTextField.backgroundColor = UIColor.colorFromHex("#9E1C40")
        let glassIconView = searchTextField.leftView as! UIImageView
        glassIconView.image = glassIconView.image?.withRenderingMode(.alwaysTemplate)
        glassIconView.tintColor = UIColor.colorFromHex("#BC214B")
        
        
        self.searchBar.keyboardAppearance = .dark
        
        self.tableView.separatorStyle = .none
        self.tableView.tintColor = UIColor.white
        self.tableView.backgroundColor = UIColor.colorFromHex("#808080")
        
        self.listOfCountries()
        
        setupScrollView()
         setupPageControl()
        setupVerticalScrollView()
        searchBar.delegate = self
    }
    
    
    @objc func moveViewToTop() {
           // Animate the view to move to the top of the screen
           UIView.animate(withDuration: 1.0, delay: 0, options: [.curveEaseInOut], animations: {
               self.searchBar.frame.origin.y = self.view.safeAreaInsets.top
           }, completion: nil)
       }
    
    func setupVerticalScrollView() {
        let scrollView = UIScrollView()
               scrollView.frame = view.bounds // Set scroll view to the size of the main view
               scrollView.backgroundColor = .lightGray
               view.addSubview(scrollView)
              
               scrollView.addSubview(self.scrollView)
               scrollView.addSubview(self.searchBar)
               scrollView.addSubview(self.tableView)
     
    }
    
    func setupScrollView() {
           scrollView.delegate = self
           scrollView.isPagingEnabled = true
           scrollView.contentSize = CGSize(width: scrollView.frame.width * CGFloat(imageNames.count), height: scrollView.frame.height)

           for (index, imageName) in imageNames.enumerated() {
               let imageView = UIImageView(frame: CGRect(x: scrollView.frame.width * CGFloat(index), y: 0, width: scrollView.frame.width, height: scrollView.frame.height))
               imageView.image = UIImage(named: imageName)
               imageView.contentMode = .scaleAspectFit
               scrollView.addSubview(imageView)
           }
       }

       func setupPageControl() {
           pageControl.numberOfPages = imageNames.count
           pageControl.currentPage = 0
       }

       // MARK: - UIScrollViewDelegate

       func scrollViewDidScroll(_ scrollView: UIScrollView) {
           let pageIndex = round(scrollView.contentOffset.x / scrollView.frame.width)
           pageControl.currentPage = Int(pageIndex)
           
           if Int(pageIndex) == 2{
               let countryListChanged = NSLocale.isoCountryCodes as [String]
               countryList.removeAll()
               tableView.reloadData()
               for code in countryListChanged {
                   let id = NSLocale.localeIdentifier(fromComponents: [NSLocale.Key.countryCode.rawValue: code])
                   let name = NSLocale(localeIdentifier: "en").displayName(forKey: NSLocale.Key.identifier, value: id) ?? "Country not found for code: \(code)"
                   countryList.append(name + " " + countryFlag(country: code))
                   tableView.reloadData()
               }
           }else{
               let countryListChanged = NSLocale.isoCountryCodes as [String]
               countryList.removeAll()
               tableView.reloadData()
               for code in countryListChanged.shuffled() {
                   let id = NSLocale.localeIdentifier(fromComponents: [NSLocale.Key.countryCode.rawValue: code])
                   let name = NSLocale(localeIdentifier: "en").displayName(forKey: NSLocale.Key.identifier, value: id) ?? "Country not found for code: \(code)"
                   countryList.append(name + " " + countryFlag(country: code))
                   tableView.reloadData()
               }
           }
       }
    
    func listOfCountries() {
        for code in NSLocale.isoCountryCodes as [String] {
            let id = NSLocale.localeIdentifier(fromComponents: [NSLocale.Key.countryCode.rawValue: code])
            let name = NSLocale(localeIdentifier: "en").displayName(forKey: NSLocale.Key.identifier, value: id) ?? "Country not found for code: \(code)"
            countryList.append(name + " " + countryFlag(country: code))
            tableView.reloadData()
        }
    }
    
    // Add Flag Emoji
    func countryFlag(country: String) -> String {
        let base: UInt32 = 127397
        var s = ""
        for v in country.unicodeScalars {
            s.unicodeScalars.append(UnicodeScalar(base + v.value)!)
        }
        return String(s)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailsViewController" {
            let DestViewController = segue.destination as! DetailsViewController
            DestViewController.selectedCountry = selected
        }
    }
}

extension TableViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching {
            return searchedCountry.count
        } else {
            return countryList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        if searching {
            cell.textLabel?.text = searchedCountry[indexPath.row]
        } else {
            cell.textLabel?.text = countryList[indexPath.row]
        }
        cell.textLabel?.textColor = UIColor.white
        cell.backgroundColor = UIColor.clear
        let myCustomSelectionColorView = UIView()
        myCustomSelectionColorView.backgroundColor = UIColor.colorFromHex("#BC214B")
        cell.selectedBackgroundView = myCustomSelectionColorView
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if searching {
            let selectedCountry = searchedCountry[indexPath.row]
            selected = selectedCountry
        } else {
            let selectedCountry = countryList[indexPath.row]
            selected = selectedCountry
        }
        performSegue(withIdentifier: "detailsViewController", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
        self.searchBar.searchTextField.endEditing(true)
    }
}

extension TableViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchedCountry = countryList.filter { $0.lowercased().prefix(searchText.count) == searchText.lowercased() }
        searching = true
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searching = false
        searchBar.text = ""
        tableView.reloadData()
        
        UIView.animate(withDuration: 1.0, delay: 0, options: [.curveEaseInOut], animations: {
            searchBar.frame.origin.y = self.view.safeAreaInsets.top
        }, completion: nil)
    }
}
