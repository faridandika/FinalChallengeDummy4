//
//  GreenOverlay.swift
//  FinalChallengeDummy3
//
//  Created by Farid Andika on 21/10/24.
//

import SwiftUI

struct GreenOverlay: View {
    var overlayColor: Color

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 0)
                .stroke(overlayColor, lineWidth: 5)
                .frame(width: 220, height: 220)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .edgesIgnoringSafeArea(.all)
    }
}

struct GreenOverlay_Previews: PreviewProvider {
    static var previews: some View {
        GreenOverlay(overlayColor: .green)
    }
}
