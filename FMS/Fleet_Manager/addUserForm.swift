//
//  AddUserForm.swift
//  FMS
//
//  Created by Ankush Sharma on 12/02/25.
//

import SwiftUI
import Cloudinary

func sendEmail(to email: String, name: String, password: String) {
    let scriptURL = "https://script.google.com/macros/s/AKfycbxe4IZA_N2g_jO4bu74zbKfvY0mteu1I_tYctnFoU5ffjO-mHCz3bhb_nsn8JuiTGgcgw/exec"
    
    let subject = "Your FMS Account Details"
    let message = """
    Hello \(name),
    
    Your FMS account has been created successfully.
    
    Your login credentials are:
    Email: \(email)
    Password: \(password)
    Best regards,
    FMS Team
    """
    
    let parameters: [String: String] = [
        "recipient": email,
        "subject": subject,
        "message": message
    ]
    
    var request = URLRequest(url: URL(string: scriptURL)!)
    request.httpMethod = "POST"
    request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("❌ Error sending email: \(error.localizedDescription)")
        } else {
            print("✅ Email sent successfully!")
        }
    }.resume()
}

struct AddUserForm: View {
    var body: some View {
        AddUserView()
    }
}

struct AddUserView: View {
    @State private var selectedRole = "Fleet Manager"
    @State private var name = ""
    @State private var email = ""
    @State private var contactNumber = ""
    @State private var generatedPassword: String = ""
    @State private var showPassword: Bool = false
    
    @State private var licenseNumber = ""
    @State private var selectedExperience: Experience = .lessThanOne
    @State private var selectedVehicleType: VehicleType = .truck
    @State private var selectedGeoArea: GeoPreference = .plain
    
    @State private var licensePhoto: UIImage? = nil
    @State private var isShowingImagePicker = false
    @State private var isFormValid = false
    
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    
    let roles = ["Fleet Manager", "Driver", "Maintenance"]
    
    let cloudinary = CLDCloudinary(configuration: CLDConfiguration(cloudName: "dztmc60fg", apiKey: "489983833873463", apiSecret: "UN-I5BTJCTmvx-yGsyMo9i-kpr4"))
    
    var experiencePicker: some View {
        Picker("Select Experience ", selection: $selectedExperience) {
            ForEach(Experience.allCases, id: \.self) { exp in
                Text(exp.rawValue).tag(exp)
            }
        }
    }
    
    var vehicleTypePicker: some View {
        Picker("Select Vehicle", selection: $selectedVehicleType) {
            ForEach(VehicleType.allCases, id: \.self) { type in
                Text(type.rawValue).tag(type)
            }
        }
    }
    
    var geoAreaPicker: some View {
        Picker("Select Specialization Areas", selection: $selectedGeoArea) {
            ForEach(GeoPreference.allCases, id: \.self) { area in
                Text(area.rawValue).tag(area)
            }
        }
    }
    
    
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Picker("Role", selection: $selectedRole) {
                        ForEach(roles, id: \.self) { role in
                            Text(role).tag(role)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.top,10)
                    .padding(.leading,10)
                    .frame(width : 380)
                    .background(Color.clear)
                    .listRowBackground(Color.clear)
                    
                    Section(header: Text("Name").font(.headline)
                        .padding(.leading, -22)) {
                            TextField("Enter your name", text: $name)
                                .padding(5)
                                .background(Color.clear)
                                .frame(height: 47)
                                .listRowBackground(Color.clear)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray, lineWidth: 1)
                                )
                                .frame(width:361)
                        }
                    
                    Section(header: Text("Email").font(.headline).padding(.leading, -22)) {
                        TextField("Enter your email", text: $email)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .padding(5)
                            .background(Color.clear)
                            .frame(height: 47)
                            .listRowBackground(Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                            .frame(width:361)
                    }
                    
                    Section(header: Text("Contact Number").font(.headline).padding(.leading, -22)) {
                        TextField("Enter contact number", text: $contactNumber)
                            .keyboardType(.phonePad)
                            .padding(5)
                            .background(Color.clear)
                            .frame(height: 47)
                            .listRowBackground(Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                            .frame(width:361)
                    }
                    
                    if selectedRole == "Driver" {
                        Section(header: Text("License Photo").font(.headline).padding(.leading, -22)) {
                            Button(action: {
                                isShowingImagePicker = true
                            }) {
                                HStack {
                                    Text("Upload License Photo")
                                    Spacer()
                                    if let _ = licensePhoto {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                    } else {
                                        Text("Tap to upload")
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                        }
                        
                        Section(header: Text("Experience (Years)").font(.headline).padding(.leading, -22)) {
                            experiencePicker
                        }
                        
                        
                        Section(header: Text("Type of Vehicle").font(.headline).padding(.leading, -22)) {
                            vehicleTypePicker
                        }
                        
                        Section(header: Text("Specialization in Geo Areas").font(.headline).padding(.leading, -22)) {
                            geoAreaPicker
                        }
                    }
                    
                    Section {
                        Button(action: {
                            validateForm()
                        }) {
                            Text("Create Account")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .disabled(isLoading)
                    }
                    .listRowBackground(Color.clear)
                }
                
                if isLoading {
                    ProgressView("Creating account...")
                        .padding()
                }
            }
            .navigationTitle("Add New User")
            .toolbarBackground(Color.white, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .sheet(isPresented: $isShowingImagePicker) {
            ImagePicker(image: $licensePhoto)
        }
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("Account Creation"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    private func generateSecurePassword() -> String {
        let length = 12
        let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*"
        return String((0..<length).map { _ in characters.randomElement()! })
    }
    
    private func validateForm() {
        // Validate required fields
        guard !name.isEmpty && !email.isEmpty && !contactNumber.isEmpty else {
            alertMessage = "Please fill in all required fields"
            showingAlert = true
            return
        }
        
        // Email validation
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        guard emailPredicate.evaluate(with: email) else {
            alertMessage = "Please enter a valid email address"
            showingAlert = true
            return
        }
        
        isLoading = true
        let loginModel_t = LoginViewModel()
        generatedPassword = generateSecurePassword()
        
        // Create account
        if selectedRole == "Driver" {
            // Create driver account
            let loginModel_t = LoginViewModel()
            loginModel_t.createDriverAccount(
                name: self.name,
                email: self.email,
                password: generatedPassword,
                phone: contactNumber,
                experience: selectedExperience,
                license: licenseNumber,
                geoPreference: selectedGeoArea,
                vehiclePreference: selectedVehicleType
            )
            uploadLicensePhotoToCloudinary()
        } else if selectedRole == "Fleet Manager" {
            // Create fleet manager account
            let loginModel_t = LoginViewModel()
            loginModel_t.createFleetManagerAccount(
                email: self.email,
                password: generatedPassword,
                name: self.name,
                phone: contactNumber
            )
        }
        
        // Send email with credentials
        sendEmail(to: self.email, name: self.name, password: generatedPassword)
        isLoading = false
        alertMessage = "Account created successfully. Login details have been sent to \(email)"
        showingAlert = true
    }
    
    func uploadLicensePhotoToCloudinary() {
        guard let image = licensePhoto else { return }
        
        isLoading = true
        
        let uploadParams = CLDUploadRequestParams()
            .setPublicId("license_photo_\(UUID().uuidString)")
            .setFolder("fms/") // You can change the folder name
            .setResourceType(.image)
        
        cloudinary.createUploader().upload(data: image.jpegData(compressionQuality: 0.8)!, uploadPreset: "FMS-iNFOSYS", params: uploadParams, completionHandler:  { (result, error) in
            if let error = error {
                print("❌ Error uploading photo: \(error.localizedDescription)")
                alertMessage = "Failed to upload photo"
                showingAlert = true
            } else if let result = result {
                print("✅ Photo uploaded successfully")
                alertMessage = "Photo uploaded successfully!"
                showingAlert = true
            }
            isLoading = false
        })
    }
}

// Image Picker Component
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            picker.dismiss(animated: true)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}

#Preview {
    AddUserForm()
}
