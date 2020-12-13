//
//  ListPage.swift
//  TravelListApp
//
//  Created by Dogukan Yolcuoglu on 8.12.2020.
//

import UIKit
import CoreData

class ListPage: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    //MARK: - Variables
    var choosenId = UUID()
    var choosenCountry = ""
    
    var arrayId = [UUID]()
    var arrayImage = [UIImage]()
    var arrayTitle = [String]()
    var arrayCountry = [String]()
    var arrayCity = [String]()
    
    //MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var toolbar: UIToolbar!
    
    //MARK: - Statement func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self;
        tableView.dataSource = self;
        self.tableView.tableFooterView = UIView();
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addClickedButton))
        
        
        
        getData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name(rawValue: "newData"), object: nil )

        let appearance = UINavigationBarAppearance()

        appearance.backgroundColor = UIColor(red: 0.16, green: 0.50, blue: 0.31, alpha: 1.00)
        appearance.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Futura", size: 22)!,NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationItem.title = "MyList"
        
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        toolbar.barTintColor = UIColor(red: 0.16, green: 0.50, blue: 0.31, alpha: 1.00)
        
    }
    
    //MARK: - Functions
    @objc func getData(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchEntity = NSFetchRequest<NSFetchRequestResult>(entityName: "Travel")
        fetchEntity.returnsObjectsAsFaults = false
        
        do {
            let results = try context.fetch(fetchEntity)
            if results.count > 0 {
                
                arrayCountry.removeAll(keepingCapacity: false)
                arrayId.removeAll(keepingCapacity: false)
                arrayImage.removeAll(keepingCapacity: false)
                arrayCity.removeAll(keepingCapacity: false)
                
                
                for result in results as! [NSManagedObject] {
                    if let id = result.value(forKey: "id") as? UUID {
                        arrayId.append(id)
                    }
                    if let country = result.value(forKey: "country") as? String {
                        arrayCountry.append(country)
                    }
                    if let city = result.value(forKey: "city") as? String {
                        arrayCity.append(city)
                    }
                    if let title = result.value(forKey: "title") as? String {
                        arrayTitle.append(title)
                    }
                    if let image = result.value(forKey: "image") as? Data {
                        arrayImage.append(UIImage(data: image)!)
                    }
                    self.tableView.reloadData()
                }
            }
        } catch {
            print("error")
        }
        
        
    }
    @objc func addClickedButton(){
        choosenCountry = ""
        let backItem = UIBarButtonItem()
        backItem.title = "List"
        navigationItem.backBarButtonItem = backItem
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
        
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayCountry.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: TravelCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TravelCell
        
        cell.imageview.image = arrayImage[indexPath.row]
        cell.countryName.text = arrayCountry[indexPath.row]
        cell.cityName.text = arrayCity[indexPath.row]
        
        return cell;
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        choosenId = arrayId[indexPath.row]
        choosenCountry = arrayCountry[indexPath.row]
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchEntity = NSFetchRequest<NSFetchRequestResult>(entityName: "Travel")
            
            let idString = arrayId[indexPath.row].uuidString
            fetchEntity.returnsObjectsAsFaults = false
            fetchEntity.predicate = NSPredicate(format: "id = %@", idString)
            
            do {
                let results = try context.fetch(fetchEntity)
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        if let id = result.value(forKey: "id") as? UUID {
                            if id == arrayId[indexPath.row] {
                                
                                context.delete(result)

                                arrayId.remove(at: indexPath.row)
                                arrayCountry.remove(at: indexPath.row)
                                arrayImage.remove(at: indexPath.row)
                                arrayCity.remove(at: indexPath.row)
                     
                            }
                            self.tableView.reloadData()
                            do {
                                try context.save()
                            } catch {
                                print("Error")
                            }
                        }
                    }
                }
            } catch{
                print("Error")
            }
            
        }
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailsVC" {
            let destinationVC = segue.destination as! DetailsPage
            destinationVC.selectedCountry = choosenCountry
            destinationVC.selectedId = choosenId
        }
    }
    
}
