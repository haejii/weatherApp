//
//  ViewController.swift
//  weatherApp
//
//  Created by 양혜지 on 2022/01/08.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var cityNameTextField: UITextField!
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var weatherDescriptionLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var maxTempLabel: UILabel!
    @IBOutlet weak var minTempLabel: UILabel!
    @IBOutlet weak var weatherStackView: UIStackView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func tapFetchWeatherButton(_ sender: UIButton) {
        if let cityName = self.cityNameTextField.text {
            print("---\(cityName)")
            self.getCuttentWeather(cityName: cityName)
            self.view.endEditing(true) // 버튼이 눌리면 키보드가 사라지게
        }
    }
    
    func configureView(weatherInformation: WeatherInformation) {
        self.cityNameLabel.text = weatherInformation.name
        if let weather = weatherInformation.weather.first {
            self.weatherDescriptionLabel.text = weather.description
            
        }
        self.tempLabel.text = "\(Int(weatherInformation.temp.temp - 273.15))°C"
        self.minTempLabel.text = "\(Int(weatherInformation.temp.minTemp - 273.15))°C"
        self.maxTempLabel.text = "\(Int(weatherInformation.temp.maxTemp - 273.15))°C"

    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "에러", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func getCuttentWeather(cityName: String) {
        guard let url = URL(string:
                "https://api.openweathermap.org/data/2.5/weather?q=\(cityName)&appid=c0ef88d7a3042c720cfa4a237946017a") else { return }
        
        let session = URLSession(configuration: .default)
        session.dataTask(with: url) { [weak self] data, response, error in
            let successRange = (200..<300)
            guard let data = data, error == nil else { return }
            let decoder = JSONDecoder()
            if let response = response as? HTTPURLResponse, successRange.contains(response.statusCode) {
                guard let weatherInfomation = try? decoder.decode(WeatherInformation.self, from: data) else
                    { return }
                // 메인쓰레드에서 받아서 처리해야해서 이렇게 안하면 메인쓰레드로 가지 않음
                DispatchQueue.main.async {
                    self?.weatherStackView.isHidden = false
                    self?.configureView(weatherInformation: weatherInfomation)
                }
            } else {
                guard let errorMessage = try? decoder.decode(ErrorMessage.self, from: data) else { return }
                DispatchQueue.main.async {
                    self?.showAlert(message: errorMessage.message)
                }
            }
           
            //debugPrint(weatherInfomation)
        }.resume()
        
        
        
    }
    
}

