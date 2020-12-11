//
//  DetailsPage.swift
//  TravelListApp
//
//  Created by Dogukan Yolcuoglu on 8.12.2020.
//

import UIKit
import CoreData
import MapKit
import CoreLocation

class DetailsPage: UIViewController, (UIImagePickerControllerDelegate & UINavigationControllerDelegate), CLLocationManagerDelegate, MKMapViewDelegate {
    
    //MARK: - Variables
    var locationManager = CLLocationManager()
    var choosenLongitude = Double()
    var choosenLatitude = Double()
    
    var selectedCountry = ""
    var selectedId = UUID()
    
    
    var annotationTitle = ""
    var annotationSubtitle = ""
    var annotationLongitude = Double()
    var annotationLatitude = Double()

    //MARK: - IBOutlets
    @IBOutlet weak var imageview: UIImageView!
    @IBOutlet weak var countryText: UITextField!
    @IBOutlet weak var cityText: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var longitudeText: UITextField!
    @IBOutlet weak var latitudeText: UITextField!
    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var subtitleText: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var toolbar: UIToolbar!
    
    
    //MARK: - Statement Func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        if selectedCountry != "" {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchEntity = NSFetchRequest<NSFetchRequestResult>(entityName: "Travels")
            fetchEntity.returnsObjectsAsFaults = false
            
            let idString = selectedId.uuidString
            fetchEntity.predicate = NSPredicate(format: "id = %@", idString)
            
            do {
                let results = try context.fetch(fetchEntity)
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        if let title = result.value(forKey: "title") as? String {
                            annotationTitle = title
                            if let subtitle = result.value(forKey: "subtitle") as? String {
                                annotationSubtitle = subtitle
                                if let longitude = result.value(forKey: "longitude") as? Double {
                                    annotationLongitude = longitude
                                    if let latitude = result.value(forKey: "latitude") as? Double {
                                        annotationLatitude = latitude
                                       
                                        
                                        let annotation = MKPointAnnotation()
                                        let coordinate = CLLocationCoordinate2D(latitude: annotationLatitude, longitude: annotationLongitude)
                                        
                                        annotation.coordinate = coordinate
                                        annotation.title = annotationTitle
                                        annotation.subtitle = annotationSubtitle
                                        
                                        mapView.addAnnotation(annotation)
                                        
                                        titleText.text = annotationTitle
                                        subtitleText.text = annotationSubtitle
                                        longitudeText.text = String(annotationLongitude)
                                        latitudeText.text = String(annotationLatitude)
                                        
                                        
                                        locationManager.stopUpdatingLocation()
                                        
                                        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                        let region = MKCoordinateRegion(center: coordinate, span: span)
                                        mapView.setRegion(region, animated: true)
                                        
                                    }
                                }
                            }
                        }
                        if let country = result.value(forKey: "country") as? String {
                            if let city = result.value(forKey: "city") as? String {
                                countryText.text = country
                                cityText.text = city
                            }
                        }
                        if let image = result.value(forKey: "image") as? Data {
                            imageview.image = UIImage(data: image)
                        }
                    }
                }
            } catch {
                print("Error")
            }
        
        }
        
        
        let keywordGR = UITapGestureRecognizer(target: self, action: #selector(hiddenKeyword))
        view.addGestureRecognizer(keywordGR)
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(chooseLocation))
        gestureRecognizer.minimumPressDuration = 3;
        mapView.addGestureRecognizer(gestureRecognizer)
        
        imageview.isUserInteractionEnabled = true;
        let imageRecongizer = UITapGestureRecognizer(target: self, action: #selector(addImage))
        view.addGestureRecognizer(imageRecongizer)
        
    }
    override func viewWillAppear(_ animated: Bool) {
       toolbar.barTintColor = UIColor(red: 0.20, green: 0.24, blue: 0.22, alpha: 0.86)
        navigationItem.title = "Add a travel"
  
    }
    
    //MARK: - Functions
    @objc func hiddenKeyword(){
        self.view.endEditing(true)
    }
    
    @objc func addImage(){
        let pickerImage = UIImagePickerController()
        pickerImage.allowsEditing = true
        pickerImage.delegate = self
        pickerImage.sourceType = .photoLibrary
        present(pickerImage, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        imageview.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func chooseLocation(gestureRecognizer: UILongPressGestureRecognizer){
        if gestureRecognizer.state == .began {
            
            let touchedPoint = gestureRecognizer.location(in: self.mapView)
            let touchedCoordinates = self.mapView.convert(touchedPoint, toCoordinateFrom: self.mapView)
            
            choosenLongitude = touchedCoordinates.longitude
            choosenLatitude = touchedCoordinates.latitude
            
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchedCoordinates
            annotation.title = titleText.text
            annotation.subtitle = subtitleText.text
            self.mapView.addAnnotation(annotation)
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if selectedCountry == "" {
            
            let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
            
            let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            
            let region = MKCoordinateRegion(center: location, span: span)
            
            mapView.setRegion(region, animated: true)
            
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            
            return nil
        }
        
        let reuseId = "myAnnotation"
        
        var pv = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pv == nil {
            pv = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pv?.canShowCallout = true
            pv?.tintColor = UIColor.black
            
            let button = UIButton(type: UIButton.ButtonType.detailDisclosure)
            pv?.rightCalloutAccessoryView = button
            
        }else {
            
            pv?.annotation = annotation
        }
        
        return pv
    }
    
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if selectedCountry == "" {
            
            let requestLocaiton = CLLocation(latitude: annotationLatitude, longitude: annotationLongitude)
            
            CLGeocoder().reverseGeocodeLocation(requestLocaiton) { (placemarks, error) in
                if let placemark = placemarks {
                    if placemark.count > 0 {
                        
                        let newPlacemark = MKPlacemark(placemark: placemark[0])
                        let item = MKMapItem(placemark: newPlacemark)
                        item.name = self.annotationTitle
                        let launchOption = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving]
                        item.openInMaps(launchOptions: launchOption)
                    }
                }
            }
            
        }
        
    }
    
    //MARK: - IBActions
    @IBAction func searchClickedButton(_ sender: Any) {
        
        
        
        
    }
    
    @IBAction func saveClickedButton(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let db  = NSEntityDescription.insertNewObject(forEntityName: "Travels", into: context)
        
        db.setValue(countryText.text, forKey: "country")
        db.setValue(cityText.text, forKey: "city")
        db.setValue(titleText.text, forKey: "title")
        db.setValue(subtitleText.text, forKey: "subtitle")
        let imageData = imageview.image!.jpegData(compressionQuality: 0.5)
        
        db.setValue(imageData, forKey: "image")
        db.setValue(UUID(), forKey: "id")
        db.setValue(choosenLongitude, forKey: "longitude")
        db.setValue(choosenLatitude, forKey: "latitude")
        
        do {
            try context.save()
        } catch {
            print("error")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newData"), object: nil)
        self.navigationController?.popViewController(animated: true)
    }
}
