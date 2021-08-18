//
//  WeatherMenager.swift
//  Clima
//
//  Created by Ivan Stoilov on 16.08.21.
//  Copyright © 2021 App Brewery. All rights reserved.
//

import UIKit
import CoreLocation

protocol WeatherManagerDelegate{
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    
    func didFailWithError(error: Error)
}

struct WeatherManager{
    
    var delegate: WeatherManagerDelegate?
    
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=9e77ceb22cb20ff6d674f371fe45e101&units=metric"
    
    func fetchWeather(cityName: String){
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRquest(urlString: urlString)
    }
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees){
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        performRquest(urlString: urlString)
    }
    func performRquest(urlString: String){
        //create url
        if let url = URL(string: urlString){
            //create url session
            let session = URLSession(configuration: .default)
            
            //give sesssion task
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil{
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeDate = data{
                    if let weather = self.parseJSON(weatherData: safeDate){
                        self.delegate?.didUpdateWeather(self,weather: weather)
                    }
                }
            }
            //start task
            task.resume()
        }
    }
    
    func parseJSON(weatherData: Data) -> WeatherModel?{
        let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            
            return weather
            
        }
        catch{
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}


