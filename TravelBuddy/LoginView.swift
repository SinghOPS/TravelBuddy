//
//  LoginView.swift
//  TravelBuddy
//
//  Created by Sahajpreet Singh Khasria on 3/30/25.
//

import SwiftUI

struct LoginView: View {
    @Binding var path: NavigationPath
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var isSignUp = false
    @State private var confirmPassword = ""
    @EnvironmentObject var authService: AuthService
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack(spacing: 100) {
            Image("logo")
                .resizable()
                .frame(width: 300, height: 130)
            
            VStack(spacing: 25) {
                Text(isSignUp ? "Create Account" : "User Login")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                
                TextField("", text: $username)
                    .placeholder(when: username.isEmpty) {
                        Text("Email Address")
                    }
                    .foregroundStyle(.white)
                    .padding(10)
                    .font(.title2)
                    .fontWeight(.bold)
                    .background(Color.blue.opacity(0.7))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .frame(width: 300)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                
                SecureField("", text: $password)
                    .placeholder(when: password.isEmpty) {
                        Text("Password")
                    }
                    .foregroundStyle(.white)
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(10)
                    .background(Color.blue.opacity(0.7))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .frame(width: 300)
                
                if isSignUp {
                    SecureField("", text: $confirmPassword)
                        .placeholder(when: confirmPassword.isEmpty) {
                            Text("Confirm Password")
                        }
                        .foregroundStyle(.white)
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(10)
                        .background(Color.blue.opacity(0.7))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .frame(width: 300)
                }
                
                Button(action: isSignUp ? signUp : login) {
                    Text(isSignUp ? "Sign Up" : "Login")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .frame(width: 100)
                }
                .padding(10)
                .background(Color.red)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                
                Button(action: {
                    isSignUp.toggle()
                }) {
                    Text(isSignUp ? "Already have an account? Login" : "Need an account? Sign up")
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        .navigationDestination(for: String.self) { destination in
            if destination == "LandingView" {
                LandingView(path: $path)
            }
        }
    }
    
    private func login() {
        guard !username.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter both email and password"
            showError = true
            return
        }
        
        authService.signIn(email: username, password: password) { result in
            switch result {
            case .success:
                path.append("LandingView")
            case .failure(let error):
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
    
    private func signUp() {
        guard !username.isEmpty, !password.isEmpty, !confirmPassword.isEmpty else {
            errorMessage = "Please fill in all fields"
            showError = true
            return
        }
        
        guard password == confirmPassword else {
            errorMessage = "Passwords don't match"
            showError = true
            return
        }
        
        authService.signUp(email: username, password: password) { result in
            switch result {
            case .success:
                path.append("LandingView")
            case .failure(let error):
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {

        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}



#Preview {
    LoginView(path: .constant(NavigationPath()))
}
