//
//  StravaAuthenticationManager.swift
//  DialedIn
//
//  Created by Andrew Coyle on 08/03/2026.
//

import AuthenticationServices

//@Observable
//@MainActor
//class StravaAuthManager {
//    
//    var accessToken: String?
//    private var session: ASWebAuthenticationSession?
//
//    func authenticate(clientId: String, redirectURI: String) {
//        let scope = "activity:write,read_all,profile:read_all"
//        let state = UUID().uuidString
//        let urlString = "https://www.strava.com/oauth/mobile/authorize?client_id=\(clientId)&redirect_uri=\(redirectURI)&response_type=code&approval_prompt=auto&scope=\(scope)&state=\(state)"
//        guard let url = URL(string: urlString) else { return }
//
//        session = ASWebAuthenticationSession(url: url, callbackURLScheme: redirectURI.scheme) { callbackURL, error in
//            if let url = callbackURL, error == nil {
//                let code = URLComponents(url: url, resolvingAgainstBaseURL: false)?
//                    .queryItems?.first(where: { $0.name == "code" })?.value
//                // Exchange code for token via POST /oauth/token
//                self.exchangeCodeForToken(code: code ?? "", clientId: clientId, clientSecret: "YOUR_SECRET")
//            }
//        }
//        session?.presentationContextProvider = self // Conform to ASWebAuthenticationPresentationContextProviding
//        session?.start()
//    }
//
//    private func exchangeCodeForToken(code: String, clientId: String, clientSecret: String) {
//        // Use URLSession to POST to https://www.strava.com/api/v3/oauth/token
//        // Parameters: client_id, client_secret, code, grant_type=authorization_code
//        // Store response access_token and refresh_token securely (Keychain)
//    }
//}
