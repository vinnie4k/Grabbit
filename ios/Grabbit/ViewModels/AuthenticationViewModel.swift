//
//  AuthenticationViewModel.swift
//  Grabbit
//
//  Created by Vin Bui on 6/16/23.
//

import AuthenticationServices
import CryptoKit
import Firebase
import FirebaseAuth
import GoogleSignIn
import SwiftUI

class AuthenticationViewModel: ObservableObject {
        
    // MARK: - Properties
    
    @Published var currentNonce: String? // unhashed nonce
    @Published var errorMessage: String?
    @Published var isAuthenticating: Bool = false
    @Published var state: SignInState = .signedIn
    
    // MARK: - Apple Sign In
    
    func signInWithAppleRequest(_ request: ASAuthorizationAppleIDRequest) {
        request.requestedScopes = [.email]
        let nonce = randomNonceString()
        currentNonce = nonce
        request.nonce = sha256(nonce)
    }
    
    func signInWithAppleCompletion(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let success):
            if let appleIDCredential = success.credential as? ASAuthorizationAppleIDCredential {
                guard let nonce = currentNonce else {
                    isAuthenticating = false
                    fatalError("Invalid state: a login callback was received, but no login request was sent.")
                }
                guard let appleIDToken = appleIDCredential.identityToken else {
                    print("Unable to fetch identity token.")
                    isAuthenticating = false
                    return
                }
                guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                    print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                    isAuthenticating = false
                    return
                }
                
                let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                          idToken: idTokenString,
                                                          rawNonce: nonce)
                
                Auth.auth().signIn(with: credential) { [unowned self] user, error in
                    if let error = error {
                        state = .signedOut
                        isAuthenticating = false
                        print("Error in AuthenticationViewModel.signInWithAppleCompletion: \(error.localizedDescription)")
                    } else {
                        Task {
                            await authenticateUser()
                        }
                    }
                }
            }
        case .failure(let error):
            print("Error in AuthenticationViewModel.signInWithAppleCompletion: \(error.localizedDescription)")
            isAuthenticating = false
        }
    }
    
    // MARK: - Google Sign In
    
    func signInWithGoogle() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        guard let rootViewController = windowScene.windows.first?.rootViewController else { return }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { [unowned self] result, error in
            guard error == nil else {
                print(error!.localizedDescription)
                isAuthenticating = false
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                return
            }
            
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: user.accessToken.tokenString
            )
            
            Auth.auth().signIn(with: credential) { [unowned self] user, error in
                if let error = error {
                    state = .signedOut
                    isAuthenticating = false
                    print("Error in AuthenticationViewModel.signInWithGoogle: \(error.localizedDescription)")
                } else {
                    Task {
                        await authenticateUser()
                    }
                }
            }
        }
    }
    
    func authenticateUser() async -> Result<User, Error> {
        guard let googleUser = Auth.auth().currentUser,
              let email = googleUser.email else {
            DispatchQueue.main.async {
                self.state = .signedOut
                self.isAuthenticating = false
            }
            return .failure(CustomError.authError)
        }
        
        let userId = googleUser.uid
        let deviceId = UserDefaults.standard.object(forKey: "deviceId") as? String
        
        let result = await NetworkManager.shared.fetchUser(deviceId: deviceId ?? "", email: email, userId: userId)
        
        switch result {
        case .success(let user):
            print("User \(user.id) successfully authenticated")
            UserDefaults.standard.set(user.id, forKey: "userId")
            DispatchQueue.main.async {
                self.state = .signedIn
                self.isAuthenticating = false
            }
            return .success(user)
        case .failure(let error):
            print("Error in AuthenticationViewModel.authenticateUser: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.state = .signedOut
                self.isAuthenticating = false
            }
            return .failure(error)
        }
    }
    
    func signOut() {
        state = .signedOut
        do {
            try Auth.auth().signOut()
        } catch {
            print("Unable to sign out")
        }
    }
    
    // MARK: - Helpers
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError(
                "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
            )
        }
        
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        
        let nonce = randomBytes.map { byte in
            // Pick a random character from the set, wrapping around if needed.
            charset[Int(byte) % charset.count]
        }
        
        return String(nonce)
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
}

extension AuthenticationViewModel {
    
    enum SignInState: Equatable {
        case signedIn
        case signedOut
    }
    
}
