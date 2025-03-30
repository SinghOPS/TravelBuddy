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
    
    
    var body: some View {
        VStack{
            
            Image("logo")
                .resizable()
                .frame(width: .infinity, height: 250)
            
                
            VStack(spacing: 25) {
                
                Text("User Login")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                
                TextField("", text: $username)
                    .placeholder(when: username.isEmpty) {
                        Text("Enter Username")
                    }
                    .foregroundStyle(.white)
                    .padding(10)
                    .font(.title2)
                    .fontWeight(.bold)
                    .background(Color.blue.opacity(0.7))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .frame(width: 300)
                
                TextField("", text: $password)
                    .placeholder(when: password.isEmpty) {
                        Text("Enter Password")
                    }
                    .foregroundStyle(.white)
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(10)
                    .background(Color.blue.opacity(0.7))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .frame(width: 300)
                
                Button(action: {
                    print("Login Clicked")
                    path.append("")
                }) {
                    Text("Login")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .frame(width: 100)
                }
                .padding(10)
                .background(Color.red)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                
            }
            .padding()
            .background(Color.gray.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            
            Spacer()
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
