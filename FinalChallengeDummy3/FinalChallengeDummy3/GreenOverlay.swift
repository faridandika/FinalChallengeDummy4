//
//  GreenOverlay.swift
//  FinalChallengeDummy3
//
//  Created by Farid Andika on 21/10/24.
//

import SwiftUI

struct GreenOverlay: View {
    var overlayColor: Color // Add a parameter to accept color

    var body: some View {
        ZStack {
            // Outer frame
            RoundedRectangle(cornerRadius: 0)
                .stroke(overlayColor, lineWidth: 5) // Use the passed color
                .frame(width: 250, height: 250) // Outer frame size
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Make sure it covers the screen
        .edgesIgnoringSafeArea(.all) // Ensure it takes up the full screen if necessary
    }
}

struct GreenOverlay_Previews: PreviewProvider {
    static var previews: some View {
        GreenOverlay(overlayColor: .green) // Example preview with green
    }
}

