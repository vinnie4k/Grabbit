//
//  AuthenticationViewModel.swift
//  Grabbit
//
//  Created by Vin Bui on 6/16/23.
//

import Firebase
import FirebaseAuth
import GoogleSignIn
import SwiftUI

class AuthenticationViewModel: ObservableObject {
        
    // MARK: - Properties
    
    @Published var isAuthenticating: Bool = false
    @Published var state: SignInState = .signedIn
    
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
            isAuthenticating = false
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
    
}

extension AuthenticationViewModel {
    
    enum SignInState: Equatable {
        case signedIn
        case signedOut
    }
    
}
