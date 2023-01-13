//
//  FavoriteTeamView.swift
//  OnSZN
//
//  Created by Bennett Yetra on 1/11/23.
//

import SwiftUI

struct FavTeams: Hashable {
    let name: String
    let icon: String
}

    let favTeams = [
        FavTeams(name: "NBA", icon: "NBA"),
        FavTeams(name: "Toronto Raptors", icon: "Raptors"),
        FavTeams(name: "Boston Celtics", icon: "Celtics"),
        FavTeams(name: "Brooklyn Nets", icon: "Nets"),
        FavTeams(name: "New York Knicks", icon: "Knicks"),
        FavTeams(name: "Philadelphia 76ers", icon: "Sixers"),
        FavTeams(name: "Milwaukee Bucks", icon: "Bucks"),
        FavTeams(name: "Indiana Pacers", icon: "Pacers"),
        FavTeams(name: "Chicago Bulls", icon: "Bulls"),
        FavTeams(name: "Detroit Pistons", icon: "Pistons"),
        FavTeams(name: "Cleveland Cavaliers", icon: "Cavaliers"),
        FavTeams(name: "Miami Heat", icon: "Heat"),
        FavTeams(name: "Orlando Magic", icon: "Magic"),
        FavTeams(name: "Charlotte Hornets", icon: "Hornets"),
        FavTeams(name: "Washington Wizards", icon: "Wizards"),
        FavTeams(name: "Atlanta Hawks", icon: "Hawks"),
        FavTeams(name: "Denver Nuggets", icon: "Nuggets"),
        FavTeams(name: "Oklahmoma City Thunder", icon: "Thunder"),
        FavTeams(name: "Utah Jazz", icon: "Jazz"),
        FavTeams(name: "Portland Trail Blazers", icon: "Trail Blazers"),
        FavTeams(name: "Minnesota Timberwolves", icon: "Timberwolves"),
        FavTeams(name: "Los Angeles Lakers", icon: "Lakers"),
        FavTeams(name: "Los Angeles Clippers", icon: "Clippers"),
        FavTeams(name: "Phoenix Suns", icon: "Suns"),
        FavTeams(name: "Sacramento Kings", icon: "Kings"),
        FavTeams(name: "Golden State Warriors", icon: "Warriors"),
        FavTeams(name: "Houston Rockets", icon: "Rockets"),
        FavTeams(name: "Dallas Mavericks", icon: "Mavericks"),
        FavTeams(name: "Memphis Grizzlies", icon: "Grizzlies"),
        FavTeams(name: "San Antonio Spurs", icon: "Spurs"),
        FavTeams(name: "New Orleans Pelicans", icon: "Pelicans")
    ]


struct FavoriteTeamView: View {
    @Binding var selection: String?
    @State private var selectedFavTeam: FavTeams?
    @State var teamTopic: String = ""
    @AppStorage("selected_fav_team") private var storedSelectedFavTeam: String = "NBA"
    
    
    var body: some View {
        VStack {
            HStack {
                Text("Select The NBA Topic:")
                    .font(.body)
                Spacer()
            }
            .padding(EdgeInsets(top: 20, leading: 21, bottom: 0, trailing: 21))
            List {
                ForEach(favTeams, id: \.self) { favTeams in
                    Button(action: {
                        self.selectedFavTeam = favTeams
                        storedSelectedFavTeam = self.selectedFavTeam?.icon ?? "NBA"
                    }) {
                        HStack {
                            Image(favTeams.icon)
                                .resizable()
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                                .shadow(radius: 5)
                                .opacity(self.selectedFavTeam == favTeams ? 1 : 0.5)
                            Text(favTeams.name)
                                .font(.body)
                                .foregroundColor(self.selectedFavTeam == favTeams ? Color.cgBlue : Color.gray)
                        }
                    }
                }
            }
            .padding(EdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0))
            Spacer()
        }
    }
}
