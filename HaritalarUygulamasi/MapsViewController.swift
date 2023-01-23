//
//  ViewController.swift
//  HaritalarUygulamasi
//
//  Created by Muzaffer Baran on 22.01.2023.
//


import UIKit
import MapKit //Haritaları kullanacagım icin bu kütüphaneyi eklemem gerek.
import CoreLocation //Kullanıcının konumunu almak için bu kütüphaneyi eklemem gerek.
import CoreData

class MapsViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    @IBOutlet weak var isimTextField: UITextField!
    @IBOutlet weak var notTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager = CLLocationManager()
    var secilenLatitude = Double()
    var secilenLongitude = Double()
    
    var secilenIsim = ""
    var secilenId : UUID?
    
    var annotationTitle = ""
    var annotationSubtitle = ""
    var anotationLatitude = Double()
    var annotationLongitude = Double()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self //haritamı dogruladım.
        locationManager.delegate = self//Kullanıcının konumunu almak için yazmalıyız.
        locationManager.desiredAccuracy = kCLLocationAccuracyBest //Kullanıcının konumunun nası verilmesi gerektigini belirtiriz best tam konumunu verir ama 100 metre yakını 10 metre yakını gibi şeyleride seçebilirim. kCLL yazdıktan sonra zaten orada hangisini seçmek istedigini soracak.
        locationManager.requestWhenInUseAuthorization()//Uygulama kullanırken konumu almama izin veriyor.
        locationManager.startUpdatingLocation()//konumu güncelemeye başla.
        
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(konumSec(gestureRecognizer: )))
        gestureRecognizer.minimumPressDuration = 3 //kullanıcı 3 saniye basılı tuttugunda oraya basıldıgını anlaycak
        mapView.addGestureRecognizer(gestureRecognizer)
        
        if secilenIsim != "" {
            //Core Data'dan verileri çek
            if let uuidString = secilenId?.uuidString {
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "yer")
                fetchRequest.predicate = NSPredicate(format: "id = %@", uuidString)
                fetchRequest.returnsObjectsAsFaults = false
                
                do {
                    let sonuclar = try context.fetch(fetchRequest)
                    
                    if sonuclar.count > 0 {
                        for sonuc in sonuclar as! [NSManagedObject]{
                            if let isim = sonuc.value(forKey: "isim") as? String {
                                annotationTitle = isim
                            }
                            if let not = sonuc.value(forKey: "not") as? String {
                                annotationSubtitle = not
                            }
                            if let latitude = sonuc.value(forKey: "latitude") as? Double{
                                anotationLatitude = latitude
                            }
                            if let longitude = sonuc.value(forKey: "longitude") as? Double {
                                annotationLongitude = longitude
                            }
                            
                            let annotation = MKPointAnnotation()
                            annotation.title = annotationTitle
                            annotation.subtitle = annotationSubtitle
                            let coordinate = CLLocationCoordinate2D(latitude: anotationLatitude, longitude: annotationLongitude)
                            annotation.coordinate = coordinate
                            
                            mapView.addAnnotation(annotation)
                            isimTextField.text = annotationTitle
                            notTextField.text = annotationSubtitle
                            
                            locationManager.stopUpdatingLocation()
                            
                            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                            let region = MKCoordinateRegion(center: coordinate, span: span)
                            mapView.setRegion(region, animated: true)
                        }
                    }
                    
                } catch {
                    print("hata")
                }
            }
        } else {
            //yeni veri eklemeye geldi
        }
    }
    
    @objc func konumSec(gestureRecognizer : UILongPressGestureRecognizer){
        
        if gestureRecognizer.state == .began { // jest algılayıcı başladığında yani dokundugumuzda ne olcağını if fonksiyonun içine yazacağız.
            
            let dokunulanNokta = gestureRecognizer.location(in: mapView)
            let dokunulanKoordinat = mapView.convert(dokunulanNokta, toCoordinateFrom: mapView)//dokunulan noktanın koordinatını verir.
            
            secilenLatitude = dokunulanKoordinat.latitude
            secilenLongitude = dokunulanKoordinat.longitude
            
            let annotation = MKPointAnnotation()//dokunulan noktayı annotation ile yazarız.Yani pin eklememizi annotation ile yaparız.ÖNEMLİ!
            annotation.coordinate = dokunulanKoordinat
            annotation.title = isimTextField.text//Pinde ne yazmasını istiyorsak bu şekilde ekleriz.Burada kullanıcının yazmasını sağlayacağız.
            annotation.subtitle = notTextField.text//Pine tıklandıgında altyazı olarak ne yazmasını istiyorsak bu şekilde ekleriz.Burada kullanıcının yazmasını sağlayacağız.MUTLAKA CLASS İCİNDE TANIMLAMAN GEREK.
            mapView.addAnnotation(annotation)
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //print(locations[0].coordinate.latitude)//Haritadaki enlem icin.
        //print(locations[0].coordinate.longitude)//Haritadaki boylam icin.
        if secilenIsim == "" {
            let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
            
            let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)//Belirttiğin bölgenin yükseklik ve genişliği.Ne kadar küçük seçersen o kadar zoomlu gösterir ilk başta.
            let region = MKCoordinateRegion(center: location, span: span)
            mapView.setRegion(region, animated: true)
        }
        
    }

    @IBAction func kaydetTiklandi(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate //kaydet butonunun  core data için kodlarını yazıyoruz.
        let context = appDelegate.persistentContainer.viewContext
        
        let yeniYer = NSEntityDescription.insertNewObject(forEntityName: "Yer", into: context)//core data da entity ismin ile burda verdigin isim aynı olmalı.
        yeniYer.setValue(isimTextField.text, forKey: "isim")
        yeniYer.setValue(notTextField.text, forKey: "not")//ismi ve notu kullanıcı girecegi icin bu kodları yazıyoruz ve mutlaka entity de verdigin isimlerle forKey leri aynı olmalı.
        yeniYer.setValue(secilenLatitude, forKey: "latitude")
        yeniYer.setValue(secilenLongitude, forKey: "longitude")
        yeniYer.setValue(UUID(), forKey: "id")
        
        
        do{
            try context.save()
            print("kayıt edildi")
        }  catch {
            print("hata")
        }
        
    }
    
}

