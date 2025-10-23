//
//  TabOne.swift
//  DialedInWatchApp
//
//  Created by Andrew Coyle on 23/10/2025.
//

import SwiftUI

struct TabOne: View {
    var body: some View {
        NavigationStack {
            VStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("Hello, world!")
                Spacer()
            }
            .navigationTitle("Nav Title")
//            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem {
                    Button {

                    } label: {
                        Image(systemName: "arrow.2.circlepath")
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            Color.blue
        }
//        .ignoresSafeArea()
    }
}

#Preview {
    TabOne()
}
