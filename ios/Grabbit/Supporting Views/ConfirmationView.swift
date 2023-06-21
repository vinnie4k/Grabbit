//
//  ConfirmationView.swift
//  Grabbit
//
//  Created by Vin Bui on 6/19/23.
//

import SwiftUI

struct ConfirmationView: View {
    
    let action: String
    let heading: String
    let subheading: String
    
    @Binding var confirmationStatus: ConfirmationStatus
    
    var body: some View {
        VStack(spacing: 0) {
            Text(heading)
                .font(.sfProRounded(size: 20, weight: .semibold))
                .foregroundColor(Color.grabbit.offWhite)
                .padding(.bottom, 8)
            
            Text(subheading)
                .font(.sfProRounded(size: 12, weight: .medium))
                .foregroundColor(Color.grabbit.silver)
                .padding(.bottom, 24)
            
            HStack(spacing: 16) {
                Button {
                    confirmationStatus = .cancel
                } label: {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.grabbit.silver)
                        .frame(width: 92, height: 36)
                        .overlay(
                            Text("Cancel")
                                .font(.sfProRounded(size: 14, weight: .medium))
                                .foregroundColor(Color.grabbit.shadow)
                        )
                }
                
                Button {
                    confirmationStatus = .confirm
                } label: {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.grabbit.error)
                        .frame(width: 92, height: 36)
                        .overlay(
                            Text(action)
                                .font(.sfProRounded(size: 14, weight: .medium))
                                .foregroundColor(Color.grabbit.offWhite)
                        )
                }
            }
        }
        .animation(.easeInOut)
        .frame(width: 256, height: 150)
        .background(Color.grabbit.background)
        .cornerRadius(12)
        .shadow(radius: 4)
    }
}

//struct ConfirmationView_Previews: PreviewProvider {
//    static var previews: some View {
//        ConfirmationView(course: TrackedCourse(courseId: 1, courseTitle: "", number: 1920, pattern: "", sectionId: 0, sectionTitle: "LEC 001", status: .open, subject: "MATH", timeEnd: "", timeStart: ""))
//    }
//}
