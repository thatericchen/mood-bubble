import SwiftUI
import FirebaseFirestore

struct MoodFeedView: View {
    @State private var moods: [Mood] = []
    @State private var isLoading = true
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                if isLoading {
                    ProgressView()
                        .padding(.top, 100)
                } else if moods.isEmpty {
                    VStack(spacing: 20) {
                        Text("🫧")
                            .font(.system(size: 60))
                        Text("No moods yet")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        Text("Be the first to share your mood!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 100)
                } else {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(moods) { mood in
                            MoodBubbleView(mood: mood)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Mood Feed")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: fetchMoods) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
        .onAppear {
            fetchMoods()
        }
    }
    
    func fetchMoods() {
        isLoading = true
        let db = Firestore.firestore()
        
        db.collection("moods")
            .order(by: "timestamp", descending: true)
            .limit(to: 30)
            .getDocuments { snapshot, error in
                isLoading = false
                
                if let documents = snapshot?.documents {
                    moods = documents.compactMap { document in
                        try? document.data(as: Mood.self)
                    }
                }
            }
    }
}

struct MoodBubbleView: View {
    let mood: Mood
    
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: mood.timestamp, relativeTo: Date())
    }
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(mood.colorValue)
                    .frame(width: 80, height: 80)
                
                Text(mood.emoji)
                    .font(.system(size: 40))
            }
            
            Text(mood.userName)
                .font(.caption)
                .lineLimit(1)
            
            Text(timeAgo)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    MoodFeedView()
}
