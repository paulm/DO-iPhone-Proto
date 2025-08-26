import SwiftUI

struct WelcomeToTodaySheet: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("showWelcomeToTodaySheet") private var showWelcomeToTodaySheet = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Content
            VStack(spacing: 32) {
                // Icon and title
                VStack(spacing: 24) {
                    Image(systemName: "calendar.badge.checkmark")
                        .font(.system(size: 64, weight: .light))
                        .foregroundStyle(Color(hex: "44C0FF"))
                        .padding(.top, 48)
                    
                    VStack(spacing: 16) {
                        Text("Welcome to Today")
                            .font(.title)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        Text("A new tab that brings your daily moments and our new chat based entry creation feature together in one place.")
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }
                }
                
                // Features
                VStack(spacing: 24) {
                    // Journaling Made Easy
                    HStack(alignment: .top, spacing: 16) {
                        VStack {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(hex: "44C0FF").opacity(0.15))
                                    .frame(width: 44, height: 44)
                                
                                Image(systemName: "bubble.left.and.text.bubble.right.fill")
                                    .font(.system(size: 20))
                                    .foregroundStyle(Color(hex: "44C0FF"))
                                    .overlay(alignment: .topTrailing) {
                                        Text("NEW")
                                            .font(.system(size: 9, weight: .bold))
                                            .foregroundStyle(.white)
                                            .padding(.horizontal, 4)
                                            .padding(.vertical, 2)
                                            .background(
                                                RoundedRectangle(cornerRadius: 4)
                                                    .fill(Color.purple)
                                            )
                                            .offset(x: 8, y: -8)
                                    }
                            }
                        }
                        .frame(width: 44)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Journaling, Made Easy")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Text("Chat about your day and we'll turn it into a journal entry for you.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    
                    // Moments to Journal
                    HStack(alignment: .top, spacing: 16) {
                        VStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.purple.opacity(0.15))
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Image(systemName: "photo.on.rectangle.angled")
                                        .font(.system(size: 20))
                                        .foregroundStyle(Color.purple)
                                )
                        }
                        .frame(width: 44)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Moments to Journal")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Text("Create an entry from the moments throughout your day.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                }
                
                Spacer()
                
                // Continue button
                Button(action: {
                    dismiss()
                }) {
                    Text("Continue")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color(hex: "44C0FF"))
                        .clipShape(RoundedRectangle(cornerRadius: 25))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .background(Color(UIColor.systemBackground))
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
        .interactiveDismissDisabled()
    }
}

#Preview {
    WelcomeToTodaySheet()
}