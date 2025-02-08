//
//  ContentView.swift
//  BasicNetworkApp
//
//  Created by Sameer on 2/8/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var user: GithubUser?
    var body: some View {
        VStack(spacing:20) {
            AsyncImage(url: URL(string: user?.avatarUrl ?? "")) { image in
                image.resizable().aspectRatio(contentMode: .fit).clipShape(Circle())
                
            } placeholder: {
                Circle().foregroundColor(.secondary).frame(width:120, height:120)

            }
            
            Text(user?.login ?? "Login Placeholder").font(.title3).bold()
            
            Text(user?.bio ?? "Bio Placeholder")
            Spacer()
            
        }.padding()
            .task{
                do{
                    user = try await getUser()
                } catch NetworkError.invalidURL {
                    print("invalid url")
                } catch NetworkError.invalidResponse {
                    print("invalid response")
                } catch NetworkError.invalidData {
                    print("invalid data")
                } catch {
                    print("unexpected error")
                }
            }
    }
    
    func getUser() async throws -> GithubUser {
        let endpoint = "https://api.github.com/users/Sameer164"
        guard let url = URL(string: endpoint) else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from:url)
        
        guard let response = response as? HTTPURLResponse,
            response.statusCode == 200 else {
                throw NetworkError.invalidResponse
            }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(GithubUser.self, from:data)
        }
        catch {
            throw NetworkError.invalidData
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}

struct GithubUser: Codable {
    let login: String
    let avatarUrl: String
    let bio: String?
}

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
}
