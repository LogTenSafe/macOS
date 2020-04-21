//
//  MapView.swift
//  LogTenSafe
//
//  Created by Tim Morgan on 4/21/20.
//  Copyright © 2020 Tim Morgan. All rights reserved.
//

import SwiftUI
import MapKit

struct MapView: NSViewRepresentable {
    func makeNSView(context: Context) -> MKMapView {
        return MKMapView(frame: .zero)
    }
    
    func updateNSView(_ nsView: MKMapView, context: Context) {
        let coordinate = CLLocationCoordinate2D(latitude: 34.011286, longitude: -116.166868)
        let span = MKCoordinateSpan(latitudeDelta: 2, longitudeDelta: 2)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        nsView.setRegion(region, animated: true)
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
