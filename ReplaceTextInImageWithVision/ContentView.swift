//
//  ContentView.swift
//  ReplaceTextInImageWithVision
//
//  Created by Tatsuya Tobioka on 2023/08/15.
//

import SwiftUI

struct ContentView: View {
    @StateObject var replacer = Replacer()
    @State var target = "サン"
    @State var replacement = "ホゲ"

    var body: some View {
        NavigationView {
            VStack {
                Image(uiImage: replacer.image)
                    .resizable()
                    .scaledToFit()
                VStack(alignment: .leading) {
                    Text("Target")
                    TextField("Target", text: $target)
                        .textFieldStyle(.roundedBorder)
                    Text("Replacement")
                    TextField("Replacement", text: $replacement)
                        .textFieldStyle(.roundedBorder)
                }
                .padding()
                Button("Replace") {
                    replacer.replace(target: target, replacement: replacement)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .navigationTitle("Replace Text in Image with Vision")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
