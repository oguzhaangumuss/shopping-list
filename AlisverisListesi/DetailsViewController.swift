//
//  DetailsViewController.swift
//  AlisverisListesi
//
//  Created by Oğuzhan Gümüş on 30.09.2023.
//

import UIKit
import CoreData

class DetailsViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate{

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var urunTextField: UITextField!
    @IBOutlet weak var fiyatTextField: UITextField!
    @IBOutlet weak var bedenTextField: UITextField!
    @IBOutlet weak var kaydetBtn: UIButton!
    
    var secilenUrunIsmi = ""
    var secilenUrunUUID : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if secilenUrunIsmi != "" {
            kaydetBtn.isHidden = true
            // Core Data seçilen ürünleri gösterme
            if let uuidString = secilenUrunUUID?.uuidString {
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Alisveris")
                // FILTRELEME ISLEMI - predicate verify'a benzer bir anlamı var
                fetchRequest.predicate = NSPredicate(format: "id = %@", uuidString)
                fetchRequest.returnsObjectsAsFaults = false
                
                do {
                    let sonuclar = try context.fetch(fetchRequest)
                    if sonuclar.count > 0 {
                        for sonuc in sonuclar as! [NSManagedObject] {
                            if let isim = sonuc.value(forKey: "isim") as? String {
                                urunTextField.text = isim
                            }
                            if let fiyat = sonuc.value(forKey: "fiyat") as? Int {
                                fiyatTextField.text = String(fiyat)
                            }
                            if let beden = sonuc.value(forKey: "beden") as? String {
                                bedenTextField.text = beden
                            }
                            if let gorselData = sonuc.value(forKey:"gorsel") as? Data{
                                let image = UIImage(data: gorselData)
                                imageView.image = image
                            }
                            
                        }
                    }
                } catch {
                    print("Çağırılan bilgilerin gösterilme hatası")
                }
                
                
            }
            
            
        } else {
            kaydetBtn.isHidden = false
            kaydetBtn.isEnabled = false
            urunTextField.text = ""
            fiyatTextField.text = ""
            bedenTextField.text = ""
            
        }
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        
        imageView.isUserInteractionEnabled = true
        let imageGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(gorselSec))
        imageView.addGestureRecognizer(imageGestureRecognizer)

        
    }
    
    @objc func gorselSec(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true)
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        if urunTextField.text != "" && fiyatTextField.text != nil && bedenTextField.text != nil {kaydetBtn.isEnabled = true}
        self.dismiss(animated: true)
    }
    
    @objc func closeKeyboard() {
        view.endEditing(true)
    }
    @IBAction func kaydetBtnClicked(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let alisveris = NSEntityDescription.insertNewObject(forEntityName: "Alisveris", into: context)
        if urunTextField.text != "" && bedenTextField.text != "" && fiyatTextField.text != nil {
            alisveris.setValue(urunTextField.text, forKey: "isim")
            alisveris.setValue(bedenTextField.text, forKey: "beden")
            if let fiyat = Int(fiyatTextField.text!){
                alisveris.setValue(fiyat, forKey: "fiyat")}
            alisveris.setValue(UUID(), forKey: "id")
            let data = imageView.image?.jpegData(compressionQuality: 0.5)
            alisveris.setValue(data, forKey: "gorsel")
        }  else {
            print("Lütfen tüm alanları doldurun")
        }
        
        do {
            try context.save()
            print("başarıyla kayıt edildi")
        } catch {
            print("kayıt edilirken hata alındı")
        }
        NotificationCenter.default.post(name: NSNotification.Name("veriGirildi"), object: nil)
        self.navigationController?.popViewController(animated: true)
        
    }
    
    
    
    

}
