//
//  MetUCDApp.swift
//  MetUCD
//
//  Created by Instructor on 05/10/2023.
//

import SwiftUI

@main
struct MetUCDApp: App {
    let viewModel = WeatherViewModel()
    var body: some Scene {
        WindowGroup {
            WeatherView(viewModel: viewModel)
        }
    }
}
