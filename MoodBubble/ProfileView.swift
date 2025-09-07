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
        
        // FIX 1: Proper nil checking instead of force unwrapping
        guard let userId = Auth.auth().currentUser?.uid else {
            isLoading = false
            print("Error: No authenticated user found")
            return
        }
        
        let db = Firestore.firestore()
        db.collection("moods")
            .whereField("userId", isEqualTo: userId)
            .order(by: "timestamp", descending: true)
            .getDocuments { snapshot, error in // FIX 2: Remove capture list since structs don't have retain cycles
                
                // FIX 3: Always update loading state on main thread
                DispatchQueue.main.async { [self] in
                    self.isLoading = false
                }
                
                // FIX 4: Proper error handling
                if let error = error {
                    print("Error fetching moods: \(error.localizedDescription)")
                    DispatchQueue.main.async { [self] in
                        self.userMoods = []
                    }
                    return
                }
                
                // FIX 5: Safe optional binding instead of force unwrapping
                guard let documents = snapshot?.documents else {
                    print("No documents found")
                    DispatchQueue.main.async { [self] in
                        self.userMoods = []
                    }
                    return
                }
                
                let moods = documents.compactMap { document in
                    try? document.data(as: Mood.self)
                }
                
                // FIX 6: Update UI on main thread
                DispatchQueue.main.async { [self] in
                    self.userMoods = moods
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
