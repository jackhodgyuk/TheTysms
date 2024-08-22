//
//  LoginView.swift
//  The Tysms
//
//  Created by Jack Hodgy on 22/08/2024.
//


import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        VStack {
            TextField("Email", text: $email)
            SecureField("Password", text: $password)
            Button("Login") {
                authViewModel.signIn(email: email, password: password)
            }
        }
    }
}
