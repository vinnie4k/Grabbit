//
//  SettingsView.swift
//  Grabbit
//
//  Created by Vin Bui on 6/19/23.
//

import SwiftUI

struct SettingsView: View {
    
    // MARK: - Properties
    
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
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            
            Spacer()
            
            creditsView
        }
        .padding(.horizontal, Constants.sidePadding)
        .setBackground()
        .navigationBarBackButtonHidden(true)
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
                authViewModel.signOut()
                mainUser.id = ""
                self.presentationMode.wrappedValue.dismiss()
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
    
}

//struct SettingsView_Previews: PreviewProvider {
//    static var previews: some View {
//        SettingsView()
//    }
//}
