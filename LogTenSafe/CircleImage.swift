//
//  CircleImage.swift
//  LogTenSafe
//
//  Created by Tim Morgan on 4/21/20.
//  Copyright © 2020 Tim Morgan. All rights reserved.
//

import SwiftUI

struct CircleImage: View {
    var body: some View {
        Image("Rachel")
            .resizable()
            .scaledToFit()
            .frame(width: 150)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.white, lineWidth: 4))
        .shadow(radius: 10)
    }
}

struct CircleImage_Previews: PreviewProvider {
    static var previews: some View {
        CircleImage()
    }
}
