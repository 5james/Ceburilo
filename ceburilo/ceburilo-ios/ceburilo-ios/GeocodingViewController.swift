//
//  GeocodingViewController.swift
//  ceburilo-ios
//
//  Created by James on 06/06/2017.
//  Copyright © 2017 James. All rights reserved.
//
import UIKit
import CoreLocation

enum GeocodeChoice{
    case Start
    case End
}

protocol GeocodeAddPinDelegate {
    func addStartPinFromLatLon(lat: Double, lon: Double)
    func addEndPinFromLatLon(lat: Double, lon: Double)
}


class GeocodingViewController: UIViewController, UITextFieldDelegate {
    
    public var pinselect: GeocodeChoice = GeocodeChoice.Start
    
    public var delegate: GeocodeAddPinDelegate?
    
    public var userLocation: CLLocation?
    
    
    // MARK:- ---> Textfield Delegates
    func textFieldDidBeginEditing(textField: UITextField) {
        print("TextField did begin editing method called")
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        print("TextField did end editing method called")
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        print("TextField should begin editing method called")
        return true;
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        print("TextField should clear method called")
        return true;
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        print("TextField should snd editing method called")
        return true;
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        print("While entering the characters this method gets called")
        return true;
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        print("TextField should return method called")
        textField.resignFirstResponder();
        return true;
    }
    // MARK: Textfield Delegates <---

    
    private var countryTextField = UITextField()
    
    private var cityTextField = UITextField()
    
    private var streetTextField = UITextField()
    
    private var resultLabel = UILabel()
    
    private var geocodeButton = UIButton(type: .system)
    
    private var currentLocationButton = UIButton(type: .system)
    
    
    override func loadView() {
        super.loadView()
        
        countryTextField.translatesAutoresizingMaskIntoConstraints = false
        countryTextField.layer.cornerRadius = 5
        countryTextField.layer.borderWidth = 0.4
        countryTextField.layer.borderColor = UIColor.black.cgColor
        countryTextField.placeholder = "Country"
        countryTextField.autocorrectionType = UITextAutocorrectionType.no
        countryTextField.keyboardType = UIKeyboardType.default
        countryTextField.returnKeyType = UIReturnKeyType.done
        countryTextField.clearButtonMode = UITextFieldViewMode.whileEditing;
        countryTextField.contentVerticalAlignment = UIControlContentVerticalAlignment.center
        countryTextField.text = ""
        countryTextField.delegate = self
        
        cityTextField.translatesAutoresizingMaskIntoConstraints = false
        cityTextField.layer.cornerRadius = 5
        cityTextField.layer.borderWidth = 0.4
        cityTextField.layer.borderColor = UIColor.black.cgColor
        cityTextField.placeholder = "City"
        cityTextField.autocorrectionType = UITextAutocorrectionType.no
        cityTextField.keyboardType = UIKeyboardType.default
        cityTextField.returnKeyType = UIReturnKeyType.done
        cityTextField.clearButtonMode = UITextFieldViewMode.whileEditing;
        cityTextField.contentVerticalAlignment = UIControlContentVerticalAlignment.center
        cityTextField.text = ""
        cityTextField.delegate = self
        
        streetTextField.translatesAutoresizingMaskIntoConstraints = false
        streetTextField.layer.cornerRadius = 5
        streetTextField.layer.borderWidth = 0.4
        streetTextField.layer.borderColor = UIColor.black.cgColor
        streetTextField.placeholder = "Street"
        streetTextField.autocorrectionType = UITextAutocorrectionType.no
        streetTextField.keyboardType = UIKeyboardType.default
        streetTextField.returnKeyType = UIReturnKeyType.done
        streetTextField.clearButtonMode = UITextFieldViewMode.whileEditing;
        streetTextField.contentVerticalAlignment = UIControlContentVerticalAlignment.center
        streetTextField.text = ""
        streetTextField.delegate = self
        
        resultLabel.translatesAutoresizingMaskIntoConstraints = false
        
        geocodeButton.translatesAutoresizingMaskIntoConstraints = false
        geocodeButton.setTitle("Set Point", for: .normal)
        geocodeButton.addTarget(self, action: #selector(GeocodingViewController.getCoordinates), for: .touchUpInside)
        
        currentLocationButton.translatesAutoresizingMaskIntoConstraints = false
        currentLocationButton.setTitle("Get current location", for: .normal)
        currentLocationButton.addTarget(self, action: #selector(GeocodingViewController.getUserLocation), for: .touchUpInside)
        
        
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 4
        stackView.axis = .vertical
        stackView.backgroundColor = UIColor.blue
        stackView.distribution = .fillEqually
        
        self.view.addSubview(stackView)
        
        // Constraints for stackview
        var constraintsStackView = [NSLayoutConstraint]()
        let csv1 = stackView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
        let csv2 = stackView.widthAnchor.constraint(equalToConstant: self.view.bounds.width*3/4)
        let csv3 = stackView.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor)
        var csv4 = stackView.heightAnchor.constraint(equalToConstant: 160)
        if pinselect == .Start {
            csv4 = stackView.heightAnchor.constraint(equalToConstant: 192)
        }
        
        
        constraintsStackView.append(csv1)
        constraintsStackView.append(csv2)
        constraintsStackView.append(csv3)
        constraintsStackView.append(csv4)
        NSLayoutConstraint.activate(constraintsStackView)
        
        stackView.addArrangedSubview(countryTextField)
        stackView.addArrangedSubview(cityTextField)
        stackView.addArrangedSubview(streetTextField)
        stackView.addArrangedSubview(geocodeButton)
        if pinselect == .Start {
            stackView.addArrangedSubview(currentLocationButton)
        }
        
    }
    
    lazy var geocoder = CLGeocoder()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Geocoding"
        self.view.backgroundColor = UIColor.white
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getCoordinates() {
        //let a = countryTextField
        guard let country = countryTextField.text else { return }
        guard let street = streetTextField.text else { return }
        guard let city = cityTextField.text else { return }
        
        // Create Address String
        let address = "\(country), \(city), \(street)"
        
        // Geocode Address String
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            // Process Response
            self.processResponse(withPlacemarks: placemarks, error: error)
        }
        
        // Update View
        geocodeButton.isHidden = true
    }
    // MARK: - Helper Methods
    
    private func processResponse(withPlacemarks placemarks: [CLPlacemark]?, error: Error?) {
        // Update View
        geocodeButton.isHidden = false
        
        if let error = error {
            print("Unable to Forward Geocode Address (\(error))")
            resultLabel.text = "Unable to Find Location for Address"
            
        } else {
            var location: CLLocation?
            
            if let placemarks = placemarks, placemarks.count > 0 {
                location = placemarks.first?.location
            }
            
            if let location = location {
                let coordinate = location.coordinate
                resultLabel.text = "\(coordinate.latitude), \(coordinate.longitude)"
                if pinselect == .Start {
                    delegate?.addStartPinFromLatLon(lat: coordinate.latitude, lon: coordinate.longitude)
                }
                else {
                    delegate?.addEndPinFromLatLon(lat: coordinate.latitude, lon: coordinate.longitude)

                }
                self.navigationController?.popViewController(animated: true)
            } else {
                resultLabel.text = "No Matching Location Found"
            }
        }
    }

    func getUserLocation() {
        delegate?.addStartPinFromLatLon(lat: (userLocation?.coordinate.latitude)!, lon: (userLocation?.coordinate.longitude)!)
        self.navigationController?.popViewController(animated: true)
    }
}
