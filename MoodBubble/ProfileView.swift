import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ProfileView: View {
    var userEmail: String
    @Binding var isLoggedIn: Bool
    
    @State private var userMoods: [Mood] = []
    @State private var isLoading = true
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 15) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.blue)
                        
                        Text(userEmail.components(separatedBy: "@").first ?? "User")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text(userEmail)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("\(userMoods.count) moods logged")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(15)
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading) {
                        Text("Your Mood History")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        if isLoading {
                            ProgressView()
                                .padding()
                        } else if userMoods.isEmpty {
                            VStack(spacing: 15) {
                                Image(systemName: "heart.circle")
                                    .font(.system(size: 50))
                                    .foregroundColor(.gray.opacity(0.6))
                                
                                Text("No moods logged yet")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                
                                Text("Start tracking your mood by adding your first mood entry!")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                                
                                Text("💭 Try the Add Mood tab to get started")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                    .padding(.top, 5)
                            }
                            .padding()
                        } else {
                            LazyVStack(spacing: 10) {
                                ForEach(userMoods) { mood in
                                    MoodHistoryRow(mood: mood)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    Button(action: signOut) {
                        Text("Sign Out")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                    }
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .foregroundColor(.red)
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .padding(.top, 20)
                }
                .padding(.vertical)
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            fetchUserMoods()
        }
    }
    
    func fetchUserMoods() {
        isLoading = true
        let currentUserName = userEmail.components(separatedBy: "@").first ?? "User"
        let db = Firestore.firestore()
        db.collection("moods")
            .whereField("userName", isEqualTo: currentUserName)
            .getDocuments { snapshot, error in
                isLoading = false
                
                if let error = error {
                    userMoods = []
                    return
                }
                
                if let documents = snapshot?.documents {
                    let fetchedMoods: [Mood] = documents.compactMap { document in
                        let data = document.data()
                        
                        guard let userId = data["userId"] as? String,
                              let userName = data["userName"] as? String,
                              let color = data["color"] as? String,
                              let emoji = data["emoji"] as? String,
                              let timestamp = data["timestamp"] as? Timestamp else {
                            return nil
                        }
                        
                        let description = data["description"] as? String ?? ""
                                                
                        return Mood(
                            id: document.documentID,
                            userId: userId,
                            userName: userName,
                            color: color,
                            emoji: emoji,
                            description: description,
                            timestamp: timestamp.dateValue()
                        )
                    }
                    
                    userMoods = fetchedMoods.sorted { $0.timestamp > $1.timestamp }
                    
                } else {
                    userMoods = []
                }
            }
    }
    
    func signOut() {
        try? Auth.auth().signOut()
        isLoggedIn = false
    }
}

struct MoodHistoryRow: View {
    let mood: Mood
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: mood.timestamp)
    }
    
    var body: some View {
        HStack {
            Circle()
                .fill(mood.colorValue)
                .frame(width: 40, height: 40)
                .overlay(
                    Text(mood.emoji)
                        .font(.system(size: 20))
                )
            
            VStack(alignment: .leading) {
                Text(formattedDate)
                    .font(.subheadline)
                Text("Feeling: \(mood.color)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(10)
    }
}

#Preview {
    ProfileView(userEmail: "test@example.com", isLoggedIn: .constant(true))
}
