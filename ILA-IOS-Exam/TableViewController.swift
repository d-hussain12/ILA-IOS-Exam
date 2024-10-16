import UIKit

class TableViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!

    private var countryList = [String]()
    private var searchedCountry = [String]()
    private var searching = false
    private var selected: String?
    private let imageNames = ["imagedan", "bisb", "ila"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSearchBar()
        setupTableView()
        setupScrollView()
        setupPageControl()
        populateCountryList()
    }
    
    private func setupSearchBar() {
        searchBar.delegate = self
        searchBar.barTintColor = UIColor.colorFromHex("#BC214B")
        searchBar.tintColor = .white
        searchBar.showsCancelButton = true
        searchBar.keyboardAppearance = .dark
        
        let searchTextField = searchBar.searchTextField
        searchTextField.textColor = .white
        searchTextField.clearButtonMode = .never
        searchTextField.backgroundColor = UIColor.colorFromHex("#9E1C40")
        
        if let glassIconView = searchTextField.leftView as? UIImageView {
            glassIconView.image = glassIconView.image?.withRenderingMode(.alwaysTemplate)
            glassIconView.tintColor = UIColor.colorFromHex("#BC214B")
        }
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.tintColor = .white
        tableView.backgroundColor = UIColor.colorFromHex("#808080")
    }
    
    private func setupScrollView() {
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

    private func setupPageControl() {
        pageControl.numberOfPages = imageNames.count
        pageControl.currentPage = 0
    }
    
    private func populateCountryList() {
        countryList = NSLocale.isoCountryCodes.compactMap { code in
            let id = NSLocale.localeIdentifier(fromComponents: [NSLocale.Key.countryCode.rawValue: code])
            let name = NSLocale(localeIdentifier: "en").displayName(forKey: .identifier, value: id) ?? "Country not found for code: \(code)"
            return "\(name) \(countryFlag(for: code))"
        }
        tableView.reloadData()
    }
    
    private func countryFlag(for countryCode: String) -> String {
        let base: UInt32 = 127397
        return countryCode.unicodeScalars.reduce(into: "") { result, scalar in
            result.unicodeScalars.append(UnicodeScalar(base + scalar.value)!)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailsViewController", let destinationVC = segue.destination as? DetailsViewController {
            destinationVC.selectedCountry = selected
        }
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource

extension TableViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        searching ? searchedCountry.count : countryList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = searching ? searchedCountry[indexPath.row] : countryList[indexPath.row]
        cell.textLabel?.textColor = .white
        cell.backgroundColor = .clear
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = UIColor.colorFromHex("#BC214B")
        cell.selectedBackgroundView = selectedBackgroundView
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selected = searching ? searchedCountry[indexPath.row] : countryList[indexPath.row]
        performSegue(withIdentifier: "detailsViewController", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
        searchBar.searchTextField.resignFirstResponder()
    }
}

// MARK: - UIScrollViewDelegate

extension TableViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x / scrollView.frame.width)
        pageControl.currentPage = Int(pageIndex)
        
        // Dynamic update of country list based on pageIndex
        countryList = NSLocale.isoCountryCodes
            .shuffled()
            .compactMap { code in
                let id = NSLocale.localeIdentifier(fromComponents: [NSLocale.Key.countryCode.rawValue: code])
                let name = NSLocale(localeIdentifier: "en").displayName(forKey: .identifier, value: id) ?? "Country not found for code: \(code)"
                return "\(name) \(countryFlag(for: code))"
            }
        tableView.reloadData()
    }
}

// MARK: - UISearchBarDelegate

extension TableViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchedCountry = countryList.filter { $0.lowercased().contains(searchText.lowercased()) }
        searching = !searchedCountry.isEmpty
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searching = false
        searchBar.text = ""
        tableView.reloadData()
        
        UIView.animate(withDuration: 1.0) {
            searchBar.frame.origin.y = self.view.safeAreaInsets.top
        }
    }
}
