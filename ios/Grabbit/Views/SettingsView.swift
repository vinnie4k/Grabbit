//
//  SettingsView.swift
//  Grabbit
//
//  Created by Vin Bui on 6/19/23.
//

import FirebaseAuth
import SwiftUI

struct SettingsView: View {
    
    // MARK: - Properties
    
    @State private var confirmEmail: Bool = false
    @State private var deleteConfirmationStatus: ConfirmationStatus = .none
    @State private var email: String = ""
    @State private var isInvalid: Bool = false
    @State private var logoutConfirmationStatus: ConfirmationStatus = .none
    @State private var showDeleteAlert: Bool = false
    @State private var showError: Bool = false
    @State private var showLogoutAlert: Bool = false
    @State private var showSpinner: Bool = false
    
    @EnvironmentObject private var authViewModel: AuthenticationViewModel
    @EnvironmentObject private var mainUser: User
    
    @Environment(\.openURL) var openURL
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    // MARK: - Constants
    
    private struct Constants {
        static let sidePadding: CGFloat = 24
    }
    
    // MARK: - UI
    
    var body: some View {
        VStack(spacing: 16) {
            navBar
            
            Group {
                aboutCell
                
                feedbackCell
                
                notificationsCell
                
                deleteAccountCell
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            
            Spacer()
            
            creditsView
        }
        .padding(.horizontal, Constants.sidePadding)
        .setBackground()
        .navigationBarBackButtonHidden(true)
        .showConfirmation(
            action: "Delete",
            heading: "Are you sure?",
            subheading: "Your tracked courses will be removed",
            showConfirmation: showDeleteAlert,
            confirmationStatus: $deleteConfirmationStatus
        )
        .onChange(of: deleteConfirmationStatus) { status in
            showDeleteAlert = false
            deleteConfirmationStatus = .none
            
            switch status {
            case .confirm:
                confirmEmail = true
            default:
                break
            }
        }
        .showConfirmation(
            action: "Sign Out",
            heading: "Sign Out",
            subheading: "Sign out of \(mainUser.email)?",
            showConfirmation: showLogoutAlert,
            confirmationStatus: $logoutConfirmationStatus
        )
        .onChange(of: logoutConfirmationStatus) { status in
            showLogoutAlert = false
            logoutConfirmationStatus = .none
            
            switch status {
            case .confirm:
                authViewModel.signOut()
                mainUser.id = ""
                self.presentationMode.wrappedValue.dismiss()
            default:
                break
            }
        }
        .alert("Confirm Email", isPresented: $confirmEmail) {
            TextField(Auth.auth().currentUser?.email ?? "", text: $email)
            Button("Delete", role: .destructive, action: authenticateEmail)
            Button("Cancel", role: .cancel) { }
        }
        .popup(showPopup: isInvalid, image: Image.grabbit.error, imageColor: Color.grabbit.error, text: "Incorrect email address")
        .popup(showPopup: showError, image: Image.grabbit.error, imageColor: Color.grabbit.error, text: "Unable to delete account")
        .overlay(
            showSpinner ? ProgressView() : nil
        )
    }
    
    private var navBar: some View {
        HStack {
            Button {
                self.presentationMode.wrappedValue.dismiss()
            } label: {
                Image.grabbit.chevronLeft
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(Color.grabbit.offWhite)
                    .frame(width: 16, height: 16)
            }
            
            Spacer()
            
            Text("Settings")
                .font(.sfProRounded(size: 16, weight: .semibold))
                .foregroundColor(Color.grabbit.offWhite)
            
            Spacer()
            
            Button {
                Haptics.shared.play(.light)
                showLogoutAlert = true
            } label: {
                Image.grabbit.logout
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(Color.grabbit.offWhite)
                    .frame(width: 24, height: 24)
            }
        }
        .frame(height: 40)
    }
    
    private var aboutCell: some View {
        Button {
            if let url = URL(string: Secrets.aboutLink) {
                openURL(url)
            }
        } label: {
            HStack(spacing: 16) {
                Image.grabbit.info
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                    .foregroundColor(Color.grabbit.offWhite)
                
                Text("About Grabbit")
                    .font(.sfProRounded(size: 16, weight: .medium))
                    .foregroundColor(Color.grabbit.offWhite)
                
                Spacer()
                
                Image.grabbit.chevronRight
                    .resizable()
                    .scaledToFit()
                    .frame(width: 12, height: 12)
                    .foregroundColor(Color.grabbit.offWhite)
            }
        }
    }
    
    private var feedbackCell: some View {
        Button {
            if let url = URL(string: Secrets.feedbackForm) {
                openURL(url)
            }
        } label: {
            HStack(spacing: 16) {
                Image.grabbit.flag
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                    .foregroundColor(Color.grabbit.offWhite)
                
                Text("Send feedback")
                    .font(.sfProRounded(size: 16, weight: .medium))
                    .foregroundColor(Color.grabbit.offWhite)
                
                Spacer()
                
                Image.grabbit.chevronRight
                    .resizable()
                    .scaledToFit()
                    .frame(width: 12, height: 12)
                    .foregroundColor(Color.grabbit.offWhite)
            }
        }
    }
    
    private var notificationsCell: some View {
        Button {
            if let appSettings = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(appSettings) {
                UIApplication.shared.open(appSettings)
            }
        } label: {
            HStack(spacing: 16) {
                Image.grabbit.bell
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                    .foregroundColor(Color.grabbit.offWhite)
                
                Text("Enable notifications")
                    .font(.sfProRounded(size: 16, weight: .medium))
                    .foregroundColor(Color.grabbit.offWhite)
                
                Spacer()
                
                Image.grabbit.chevronRight
                    .resizable()
                    .scaledToFit()
                    .frame(width: 12, height: 12)
                    .foregroundColor(Color.grabbit.offWhite)
            }
        }
    }
    
    private var deleteAccountCell: some View {
        Button {
            showDeleteAlert = true
        } label: {
            HStack(spacing: 16) {
                Image.grabbit.delete
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                    .foregroundColor(Color.grabbit.offWhite)
                
                Text("Delete account")
                    .font(.sfProRounded(size: 16, weight: .medium))
                    .foregroundColor(Color.grabbit.offWhite)
                
                Spacer()
                
                Image.grabbit.chevronRight
                    .resizable()
                    .scaledToFit()
                    .frame(width: 12, height: 12)
                    .foregroundColor(Color.grabbit.offWhite)
            }
        }
    }
    
    private var creditsView: some View {
        VStack(spacing: 12) {
            Text("Copyright © 2023")
                .font(.sfProRounded(size: 14, weight: .light))

            HStack(spacing: 0) {
                Text("Designed and Developed by ")
                    .font(.sfProRounded(size: 16, weight: .light))
                
                Text("Vin Bui")
                    .font(.sfProRounded(size: 16, weight: .semibold))
            }
        }
        .foregroundColor(Color.grabbit.offWhite)
        .padding(.bottom, 56)
    }
    
    // MARK: - Helpers
    
    /// Authenticate email address input
    private func authenticateEmail() {
        if email == Auth.auth().currentUser?.email {
            showSpinner.toggle()
            Task {
                let result = await NetworkManager.shared.deleteAccount(for: mainUser)
                switch result {
                case .success(_):
                    showSpinner.toggle()
                    authViewModel.signOut()
                    mainUser.id = ""
                    self.presentationMode.wrappedValue.dismiss()
                case .failure(let error):
                    print("Error in SettingsView.authenticateEmail: \(error.localizedDescription)")
                    showSpinner.toggle()
                    showError.toggle()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        showError.toggle()
                    }
                }
            }
        } else {
            isInvalid.toggle()
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                isInvalid.toggle()
            }
        }
    }
}

//struct SettingsView_Previews: PreviewProvider {
//    static var previews: some View {
//        SettingsView()
//    }
//}
