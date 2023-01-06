//
//import CoreData
//import SwiftUI
//
//struct Teams: Hashable {
//    let name: String
//    let icon: String
//}
//
//let teams = [
//    Teams(name: "Bucks", icon: "Bucks"),
//    Teams(name: "Celtics", icon: "Celtics"),
//    Teams(name: "Hawks", icon: "Hawks"),
//    Teams(name: "Heat", icon: "Heat"),
//    Teams(name: "Jazz", icon: "Jazz"),
//    Teams(name: "Kings", icon: "Kings"),
//    Teams(name: "Lakers", icon: "Lakers"),
//    Teams(name: "Mavericks", icon: "Mavericks"),
//    Teams(name: "Nets", icon: "Nets"),
//    Teams(name: "Nuggets", icon: "Nuggets"),
//    Teams(name: "Pacers", icon: "Pacers"),
//    Teams(name: "Pelicans", icon: "Pelicans"),
//    Teams(name: "Pistons", icon: "Pistons"),
//    Teams(name: "Raptors", icon: "Raptors"),
//    Teams(name: "Rockets", icon: "Rockets"),
//    Teams(name: "Sixers", icon: "Sixers"),
//    Teams(name: "Suns", icon: "Suns"),
//    Teams(name: "Thunder", icon: "Thunder"),
//    Teams(name: "Timberwolves", icon: "Timberwolves"),
//    Teams(name: "Trail Blazers", icon: "Trail Blazers"),
//    Teams(name: "Warriors", icon: "Warriors"),
//    Teams(name: "Wizards", icon: "Wizards")
//]
//
//
//struct SelectTeamTopicView: View {
//    @State var selectedTeam: Teams?
//    @State var teamTopic: String = ""
//    @Environment(\.dismiss) private var dismiss
//
//    var body: some View {
//        VStack {
//            HStack {
//                Text("Select The NBA Topic:")
//                    .font(.body)
//                Spacer()
//            }
//            .padding(EdgeInsets(top: 20, leading: 21, bottom: 0, trailing: 21))
//            List {
//                ForEach(teams, id: \.self) { teams in
//                    Button(action: {
//                        let selectedTeam = teams.name
////                        let selectTeam = self.selectedTeam
//                        let teamTopic = selectedTeam
//                        dismiss()
////                        self.saveSelectionToCoreData()
//                    }) {
//                        HStack {
//                            Image(teams.icon)
//                                .resizable()
//                                .frame(width: 50, height: 50)
//                                .clipShape(Circle())
//                                .overlay(Circle().stroke(Color.gray, lineWidth: 2))
//                                .shadow(radius: 5)
//                                .opacity(self.selectedTeam == teams ? 1 : 0.5)
//                            Text(teams.name)
//                                .font(.body)
//                                .foregroundColor(self.selectedTeam == teams ? Color.cgBlue : Color.gray)
//                        }
//                    }
//                }
//            }
//            .padding(EdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0))
//            Spacer()
//        }
//    }
//}
//
////    func saveSelectionToCoreData() {
////        // Initialize the persistent container with the name of your Core Data model file
////        let persistentContainer = NSPersistentContainer(name: "Model")
////
////        // Load the persistent stores and connect the managed object context to the persistent store coordinator
////        persistentContainer.loadPersistentStores { (storeDescription, error) in
////            if let error = error {
////                // Handle the error if the persistent container fails to load
////                print("Unable to load persistent stores: \(error)")
////            } else {
////                let context = persistentContainer.viewContext
////                let team = FavoriteTeam(context: context)
////                team.name = self.selectedTeam?.name
////                print("Saving team: \(team)")
////                do {
////                    try context.save()
////                    print("Team saved?: \(team)")
////                } catch {
////                    print("Error saving data to Core Data: \(error)")
////                }
////                // Navigate to the home view
////                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
////                    let window = windowScene.windows.first
////                    window?.rootViewController = UIHostingController(rootView: AccountView())
////                }
////            }
////        }
////    }
////}
//
//struct SelectTeamTopicView_Previews: PreviewProvider {
//    static var previews: some View {
//        SelectTeamTopicView()
//    }
//}
