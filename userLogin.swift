import SwiftUI

struct Login: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var loginError: String?
    @State private var isSignedIn: Bool = false

    var body: some View {
        NavigationStack {
            VStack {
                Text("Sign In")
                    .font(.largeTitle)
                    .padding(.bottom, 20)

                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.bottom, 10)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)

                TextField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.bottom, 20)

                Button(action: {
                    loginError = signIn(email: email, password: password)
                    if loginError == nil {
                        isSignedIn = true
                    }
                }) {
                    Text("Sign In")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 0.5, green: 0.7, blue: 0.6))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.bottom, 10)

                if let loginError = loginError {
                    Text(loginError)
                        .foregroundColor(.red)
                        .padding(.bottom, 10)
                }

                NavigationLink(destination: CreateAccount()) {
                    Text("Create an Account")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                NavigationLink(
                    destination: HomePage(),
                    isActive: $isSignedIn,
                    label: {
                        EmptyView()
                    }
                )
            }
            .padding()
            .navigationTitle("Study Sage")
        }
    }
}

struct CreateAccount: View {
    @State private var isTeacher: Bool? = nil
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var selectedSubjects: [String] = []
    @State private var createAccountError: String?
    @State private var showAlert: Bool = false

    let subjects = ["Math", "English", "Science", "History"]

    var body: some View {
        VStack {
            Text("Are you a teacher?")
                .font(.title)
                .padding(.bottom, 20)

            HStack {
                Button(action: {
                    isTeacher = true
                }) {
                    Text("Yes")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isTeacher == true ? Color.green : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                Button(action: {
                    isTeacher = false
                }) {
                    Text("No")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isTeacher == false ? Color.green : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding(.bottom, 20)

            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.bottom, 10)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)

            TextField("Create Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.bottom, 10)

            TextField("Confirm Password", text: $confirmPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.bottom, 10)

            Text("Select Subjects")
                .font(.headline)
                .padding(.top, 10)

            List {
                ForEach(subjects, id: \.self) { subject in
                    MultipleSelection(title: subject, isSelected: selectedSubjects.contains(subject)) {
                        if selectedSubjects.contains(subject) {
                            selectedSubjects.removeAll { $0 == subject }
                        } else {
                            selectedSubjects.append(subject)
                        }
                    }
                }
            }
            .frame(height: 150)
            .listStyle(PlainListStyle())

            Button(action: {
                let error = createAccount(email: email, password: password, confirmPassword: confirmPassword, isTeacher: isTeacher ?? false, subjects: selectedSubjects)
                if error == nil {
                    showAlert = true
                } else {
                    createAccountError = error
                }
            }) {
                Text("Create Account")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            if let createAccountError = createAccountError {
                Text(createAccountError)
                    .foregroundColor(.red)
                    .padding(.top, 10)
            }
        }
        .padding()
        .navigationTitle("Create Account")
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Account Created"),
                message: Text("Your account has been created successfully. Please go back and log in."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

struct MultipleSelection: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                if isSelected {
                    Spacer()
                    Text("✔")
                }
            }
            .padding()
        }
    }
}

struct User: Codable {
    var email: String
    var password: String
    var isTeacher: Bool
    var subjects: [String]
}

//sandbox
func getDocumentsDirectory() -> URL {
    return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
}

func getUsersFileURL() -> URL {
    return getDocumentsDirectory().appendingPathComponent("users").appendingPathExtension("plist")
}

//saving into sandbox
func saveUsers(_ users: [User]) {
    let encoder = PropertyListEncoder()
    if let encoded = try? encoder.encode(users) {
        try? encoded.write(to: getUsersFileURL(), options: .noFileProtection)
    }
}
//decode
func loadUsers() -> [User] {
    let decoder = PropertyListDecoder()
    if let data = try? Data(contentsOf: getUsersFileURL()),
       let users = try? decoder.decode([User].self, from: data) {
        return users
    }
    return []
}

func createAccount(email: String, password: String, confirmPassword: String, isTeacher: Bool, subjects: [String]) -> String? {
    guard password == confirmPassword else {
        return "Passwords do not match."
    }
    
    var users = loadUsers()
    if users.contains(where: { $0.email == email }) {
        return "Email already in use."
    }
    
    let newUser = User(email: email, password: password, isTeacher: isTeacher, subjects: subjects)
    users.append(newUser)
    saveUsers(users)
    
    return nil
}

func signIn(email: String, password: String) -> String? {
    let users = loadUsers()
    if let user = users.first(where: { $0.email == email && $0.password == password }) {
        print("User signed in: \(user.email)")
        UserDefaults.standard.set(email, forKey: "signedInUserEmail")
        return nil
    } else {
        return "Invalid email or password."
    }
}

#Preview {
    Login()
}
