import SwiftUI
import Firebase

@main
struct MoodBubbleApp: App {
    
    init() {
        FirebaseApp.configure()
        print("Firebase configured!")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
