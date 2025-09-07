import SwiftUI

struct ContentView: View {
    @State private var isLoggedIn = false
    @State private var userEmail = ""
    
    var body: some View {
        if isLoggedIn {
            MainTabView(userEmail: $userEmail, isLoggedIn: $isLoggedIn)
        } else {
            LoginView(isLoggedIn: $isLoggedIn, userEmail: $userEmail)
        }
    }
}

struct MainTabView: View {
    @Binding var userEmail: String
    @Binding var isLoggedIn: Bool
    
    var body: some View {
        TabView {
            MoodFeedView()
                .tabItem {
                    Label("Feed", systemImage: "circle.grid.3x3.fill")
                }
            
            AddMoodView(userEmail: userEmail)
                .tabItem {
                    Label("Add Mood", systemImage: "plus.circle.fill")
                }
            
            ProfileView(userEmail: userEmail, isLoggedIn: $isLoggedIn)
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
                }
        }
    }
}

#Preview {
    ContentView()
}
