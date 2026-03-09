//
//  StravaConnectView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 09/03/2026.
//

import SwiftUI

struct StravaConnectView: View {
    @State var presenter: StravaConnectPresenter

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 16) {
                Image(systemName: "figure.run.circle.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(.orange)

                Text("Connect with Strava")
                    .font(.largeTitle.bold())

                Text("Automatically upload every workout to your Strava account the moment you finish a session.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Spacer()

        }
        .navigationTitle("Strava")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { presenter.onViewAppear() }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 12) {
                if presenter.isConnected {
                    Label("Strava Connected", systemImage: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .font(.headline)
                        .padding(.bottom, 8)

                    CallToActionButton {
                        presenter.onContinuePressed()
                    } label: {
                        Text("Continue")
                    }
                } else {
                    CallToActionButton {
                        presenter.onConnectPressed()
                    } label: {
                        Group {
                            if presenter.isConnecting {
                                ProgressView()
                            } else {
                                Text("Connect Strava")
                            }
                        }
                    }
                    .tint(.orange)
                    .disabled(presenter.isConnecting)

                    Button("Skip for now") {
                        presenter.onSkipPressed()
                    }
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
                }
            }
        }
    }
}

extension CoreBuilder {
    func stravaConnectView(router: AnyRouter) -> some View {
        StravaConnectView(
            presenter: StravaConnectPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            )
        )
    }
}

extension CoreRouter {
    func showStravaConnectView() {
        router.showScreen(.push) { router in
            builder.stravaConnectView(router: router)
        }
    }
}

#Preview {
    let builder = CoreBuilder(interactor: CoreInteractor(container: DevPreview.shared.container()))
    RouterView { router in
        builder.stravaConnectView(router: router)
    }
}
