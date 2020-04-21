import SwiftUI

struct LoginSheetView: View {
    @EnvironmentObject var viewController: MainViewController
    
    @State var email: String = ""
    @State var password: String = ""
        
    var body: some View {
        VStack(alignment: .leading) {
            Text("Please log in to LogTenSafe.").padding(.bottom)
            
            VStack(alignment: .leading, spacing: 0) {
                Text("Email")
                TextField("", text: $email) //TODO make first responder
            }.padding(.bottom, 5)
            VStack(alignment: .leading, spacing: 0) {
                Text("Password")
                SecureField("", text: $password)
            }
            
            if (viewController.loginError != nil) {
                Text(viewController.loginError!.localizedDescription)
                    .foregroundColor(.red)
                    .lineLimit(nil)
                    .fixedSize(horizontal: true, vertical: false)
            }
            
            HStack {
                Button("I don’t have an account.") { self.noAccount() }
                    .buttonStyle(BorderlessButtonStyle())
                    .foregroundColor(.blue)
                Spacer()
                Button("Quit") { self.quit() }
                Button("Log In") { self.logIn() }.disabled(viewController.loggingIn)
            }.padding(.top)
        }.padding()
    }
    
    private func noAccount() {
        NSWorkspace.shared.open(appURL)
    }
    
    private func quit() {
        exit(0) //TODO find a way to do this with NSApplication.shared.terminate()
    }
    
    private func logIn() {
        viewController.logIn(email: email, password: password)
    }
}

struct LoginSheetView_Previews: PreviewProvider {
    @State static var willTerminate = false
    
    static var previews: some View {
        let state = MainViewController()
        //state.loginError = LogTenSafeError.invalidLogin
        return LoginSheetView().frame(maxWidth: 350).environmentObject(state)
    }
}
