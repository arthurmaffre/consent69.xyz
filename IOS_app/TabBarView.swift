//
//  TabBarView.swift
//  SwiftUIStarterKitApp
//
//  Created by Osama Naeem on 02/08/2019.
//  Copyright © 2019 NexThings. All rights reserved.
//

import SwiftUI

struct TabbarView: View {
    var body: some View {
        TabView {
            NavigationView {
                ContractsView()  // Nouvelle vue, vire ActivitiesContentView
            }
            .tag(0)
            .tabItem {
                Image(systemName: "doc.text")
                    .resizable()
                    .scaledToFit()
                Text("Contracts")
            }
            
            // NOUVELLE VUE : Remplace l'ancienne ActivitiesCartView complètement
            // Pas de NavigationView ici car QRScanConsentView a déjà le sien
            QRScanConsentView()
            .tag(1)
            .tabItem {
                Image(systemName: "qrcode.viewfinder")  // Icône scanner QR
                    .resizable()
                    .scaledToFit()
                Text("Scan")
            }
            
            NavigationView {
                AccountView()
            }
            .tag(2)
            .tabItem {
                Image(systemName: "person")  // Icône profil
                    .resizable()
                    .scaledToFit()
                Text("Account")
            }
        }
    }
}

#Preview {
    TabbarView()
}
