//
//  ContentView.swift
//  DialedInWatchApp
//
//  Created by Andrew Coyle on 23/10/2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            Tab {
                TabOne()
            }

            Tab {
                VStack {
                    Image(systemName: "globe")
                        .imageScale(.large)
                        .foregroundStyle(.tint)
                    Text("Hello, world!")
                }
                .padding()
                .background {
                    Color.green
                }
                .cornerRadius(12)

            }

            Tab {
                VStack {
                    Image(systemName: "globe")
                        .imageScale(.large)
                        .foregroundStyle(.tint)
                    Text("Hello, world!")
                }
                .padding()
                .background {
                    Color.red
                }
                .cornerRadius(12)

            }
        }
        .tabViewStyle(.verticalPage)
    }
}

#Preview {
    ContentView()
}
