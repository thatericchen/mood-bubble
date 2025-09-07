import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import UserNotifications

struct AddMoodView: View {
    var userEmail: String
    
    @State private var selectedColor = "blue"
    @State private var selectedEmoji = "😊"
    @State private var isSaving = false
    @State private var showSuccess = false
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var isSuccessAlert = false
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 30) {
                    Text("How are you feeling?")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.top)
                    
                    VStack(alignment: .leading) {
                        Text("Choose a color")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(moodColors) { moodColor in
                                Circle()
                                    .fill(moodColor.color)
                                    .frame(width: 70, height: 70)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.black, lineWidth: selectedColor == moodColor.name ? 3 : 0)
                                    )
                                    .scaleEffect(selectedColor == moodColor.name ? 1.1 : 1.0)
                                    .onTapGesture {
                                        withAnimation(.spring()) {
                                            selectedColor = moodColor.name
                                        }
                                    }
                            }
                        }
                        .padding()
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Add an emoji")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 15) {
                            ForEach(moodEmojis, id: \.self) { emoji in
                                Text(emoji)
                                    .font(.system(size: 35))
                                    .padding(8)
                                    .background(
                                        Circle()
                                            .fill(selectedEmoji == emoji ? Color.gray.opacity(0.3) : Color.clear)
                                    )
                                    .onTapGesture {
                                        withAnimation {
                                            selectedEmoji = emoji
                                        }
                                    }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                    
                    Button(action: saveMood) {
                        if isSaving {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Save Mood")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .disabled(isSaving)
                    
                    if showSuccess {
                        Text("✅ Mood saved!")
                            .foregroundColor(.green)
                            .transition(.opacity)
                    }
                }
                
                if showAlert {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation {
                                showAlert = false
                            }
                        }
                    
                    VStack(spacing: 15) {
                        Text(alertTitle)
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text(alertMessage)
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(15)
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                    .padding(.horizontal, 40)
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .navigationTitle("Add Mood")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    func saveMood() {
        isSaving = true
        
        let db = Firestore.firestore()
        let moodData: [String: Any] = [
            "userId": Auth.auth().currentUser?.uid ?? "",
            "userName": userEmail.components(separatedBy: "@").first ?? "User",
            "color": selectedColor,
            "emoji": selectedEmoji,
            "timestamp": Timestamp(date: Date())
        ]
        
        db.collection("moods").addDocument(data: moodData) { error in
            isSaving = false
            
            if let error = error {
                alertTitle = "Error"
                alertMessage = "There was an error saving your mood: \(error.localizedDescription)"
                isSuccessAlert = false
                showAlert = true
            } else {
                alertTitle = "✅ Success!"
                alertMessage = "Mood saved successfully!"
                isSuccessAlert = true
                showAlert = true
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        showAlert = false
                    }
                    selectedColor = "blue"
                    selectedEmoji = "😊"
                }
            }
        }
    }
    
    func scheduleDailyReminder() {
        let content = UNMutableNotificationContent()
        content.title = "How are you feeling?"
        content.body = "Take a moment to log your mood 🫧"
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = 20
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "daily-mood", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
}

#Preview {
    AddMoodView(userEmail: "test@example.com")
}
