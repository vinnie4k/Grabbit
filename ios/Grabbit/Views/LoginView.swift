//
//  LoginView.swift
//  Grabbit
//
//  Created by Vin Bui on 6/17/23.
//

import SwiftUI

struct LoginView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @State private var showNotifications: Bool = true
    
    // MARK: - Constants
    
    private struct Constants {
        static let sidePadding: CGFloat = 40
    }
    
    // MARK: - UI
    
    var body: some View {
        ZStack {
            VStack(spacing: 120) {
                HStack(spacing: 16) {
                    Image.grabbit.logo
                        .resizable()
                        .scaledToFit()
                        .frame(width: 64)
                    
                    Text("grabbit")
                        .font(.spartanLight(size: 56))
                        .foregroundColor(Color.grabbit.offWhite)
                }
                
                Button {
                    authViewModel.signInWithGoogle()
                } label: {
                    Image.grabbit.google
                        .resizable()
                        .scaledToFit()
                        .frame(height: 40)
                        .padding(.horizontal, Constants.sidePadding)
                }
                .disabled(showNotifications)
            }
            
            showNotifications ? notificationsView : nil
        }
        .setBackground()
        .onAppear {
            let current = UNUserNotificationCenter.current()
            
            current.getNotificationSettings { permission in
                switch permission.authorizationStatus {
                case .authorized:
                    showNotifications = false
                case .denied:
                    showNotifications = true
                default:
                    showNotifications = true
                }
            }
        }
    }
    
    private var notificationsView: some View {
        VStack(alignment: .center, spacing: 8) {
            Image.grabbit.bell
                .resizable()
                .scaledToFit()
                .foregroundColor(Color.grabbit.offWhite)
                .frame(width: 60, height: 60)
                .padding(.bottom, 8)
            
            Text("Enable notifications")
                .font(.sfProRounded(size: 20, weight: .semibold))
                .foregroundColor(Color.grabbit.offWhite)
            
            Text("We need notifications to alert you when courses are open!")
                .font(.sfProRounded(size: 12, weight: .medium))
                .foregroundColor(Color.grabbit.silver)
                .multilineTextAlignment(.center)
                .padding(.bottom, 8)
            
            Button {
                if let appSettings = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(appSettings) {
                    UIApplication.shared.open(appSettings)
                }
            } label: {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.grabbit.success)
                    .overlay(
                        Text("Open settings")
                            .font(.sfProRounded(size: 14, weight: .semibold))
                            .foregroundColor(Color.grabbit.primary)
                    )
            }
            .frame(height: 33)
        }
        .padding(20)
        .frame(width: 240, height: 240)
        .background(Color.grabbit.primary)
        .cornerRadius(16)
        .shadow(radius: 4)
    }
    
}

//struct LoginView_Previews: PreviewProvider {
//    static var previews: some View {
//        LoginView()
//    }
//}
