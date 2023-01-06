//
//  TeamView.swift
//  OnSZN
//
//  Created by Bennett Yetra on 11/27/20.
//

import SwiftUI

struct Team: Identifiable {
    var id = UUID()
    var name: String
    var icon: String
    var slogan: String
    var color: Color
}


struct TeamRow: View {
    @Environment(\.colorScheme) private var colorScheme
    var team: Team
    var body: some View {
        HStack {
            Image(team.icon)
                .resizable()
                .frame(width: 50, height: 50)
            Text(team.name)
                .font(.headline)
                .foregroundColor(colorScheme == .light ? Color.oxfordBlue : Color.platinum)
        }
    }
}

struct TeamView: View {
    @State private var fetchedPosts: [Post] = []
    @State private var teamName: String?
    var team: Team
    var body: some View {
        VStack {
            Image(team.icon)
                .resizable()
                .frame(width: 50, height: 50)
            Text(team.name)
                .font(.title)
                .foregroundColor(team.color)
            Text(team.slogan)
                .font(.headline)
                .foregroundColor(team.color)
        }
        VStack {
            ReusableTeamPostsView(basedOnTeamTopic: true, posts: $fetchedPosts, teamName: team.name)
        }
    }
}

struct ContentsView: View {
    var body: some View {
       
        let teams = [
            Team(name: "NBA", icon: "nbaicon", slogan: "#WhereAmazingHappens", color: .blue),
            Team(name: "Toronto Raptors", icon: "Raptors", slogan: "#WeTheNorth", color: .red),
            Team(name: "Boston Celtics", icon: "Celtics", slogan: "#BleedGreen", color: .green),
            Team(name: "Brooklyn Nets", icon: "Nets", slogan: "#BrooklynGrit", color: .black),
            Team(name: "New York Knicks", icon: "Knicks", slogan: "#NewYorkTough", color: .blue),
            Team(name: "Philadelphia 76ers", icon: "Sixers", slogan: "#TrustTheProcess", color: .blue),
            Team(name: "Milwaukee Bucks", icon: "Bucks", slogan: "#FearTheDeer", color: .green),
            Team(name: "Indiana Pacers", icon: "Pacers", slogan: "#IndianaTough", color: .yellow),
            Team(name: "Chicago Bulls", icon: "Bulls", slogan: "#ChicagoGrit", color: .red),
            Team(name: "Detroit Pistons", icon: "Pistons", slogan: "#DetroitTough", color: .blue),
            Team(name: "Cleveland Cavaliers", icon: "Cavaliers", slogan: "#AllForOne", color: .red),
            Team(name: "Miami Heat", icon: "Heat", slogan: "#HeatCulture", color: .red),
            Team(name: "Orlando Magic", icon: "Magic", slogan: "#OrlandoStrong", color: .blue),
            Team(name: "Charlotte Hornets", icon: "Hornets", slogan: "#BuzzCity", color: .teal),
            Team(name: "Washington Wizards", icon: "Wizards", slogan: "#DCFamily", color: .blue),
            Team(name: "Atlanta Hawks", icon: "Hawks", slogan: "#TrueToAtlanta", color: .red),
            Team(name: "Denver Nuggets", icon: "Nuggets", slogan: "#MileHighBasketball", color: .blue),
            Team(name: "Oklahmoma City Thunder", icon: "Thunder", slogan: "#ThunderUp", color: .blue),
            Team(name: "Utah Jazz", icon: "Jazz", slogan: "#TakeNote", color: .green),
            Team(name: "Portland Trail Blazers", icon: "Blazers", slogan: "#RipCity", color: .red),
            Team(name: "Minnesota Timberwolves", icon: "Timberwolves", slogan: "#MinnesotaNice", color: .blue),
            Team(name: "Los Angeles Lakers", icon: "Lakers", slogan: "#LakerNation", color: .purple),
            Team(name: "Los Angeles Clippers", icon: "Clippers", slogan: "#LobCity", color: .red),
            Team(name: "Phoenix Suns", icon: "Suns", slogan: "#ValleyOfTheSun", color: .orange),
            Team(name: "Sacramento Kings", icon: "Kings", slogan: "#SacramentoProud", color: .purple),
            Team(name: "Golden State Warriors", icon: "Warriors", slogan: "#DubNation", color: .blue),
            Team(name: "Houston Rockets", icon: "Rockets", slogan: "#RedNation", color: .red),
            Team(name: "Dallas Mavericks", icon: "Mavericks", slogan: "#MavsMoneyball", color: .blue),
            Team(name: "Memphis Grizzlies", icon: "Grizzlies", slogan: "#MavsMoneyball", color: .blue),
            Team(name: "San Antonio Spurs", icon: "Spurs", slogan: "#MavsMoneyball", color: .gray),
            Team(name: "New Orleans Pelicans", icon: "Pelicans", slogan: "#MavsMoneyball", color: .blue)]
        
        
        return NavigationView {
            List(teams) { team in
                NavigationLink(destination: TeamView(team: team)) {
                    TeamRow(team: team)
                }
            }
            .navigationBarTitle("NBA Teams")
        }
    }
}


