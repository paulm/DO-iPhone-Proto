import SwiftUI

struct BeliefsValuesView: View {
    @State private var bioData = BioData.shared

    var body: some View {
        Form {
            // Religious/Spiritual Section
            Section {
                TextField("Religious/Spiritual Beliefs", text: $bioData.religiousSpiritualBeliefs, axis: .vertical)
                    .lineLimit(3, reservesSpace: false)
            } header: {
                Text("Religious & Spiritual")
            } footer: {
                Text("Your religious affiliation or spiritual practices")
            }

            // Political Views Section
            Section {
                TextField("Political Views (Optional)", text: $bioData.politicalViews, axis: .vertical)
                    .lineLimit(3, reservesSpace: false)
            } header: {
                Text("Political Views")
            } footer: {
                Text("This field is optional and private - share only what you're comfortable with")
            }

            // Core Values Section
            Section {
                TextField("Core Values and Principles", text: $bioData.coreValues, axis: .vertical)
                    .lineLimit(4, reservesSpace: false)
            } header: {
                Text("Core Values")
            } footer: {
                Text("The principles and values that guide your life")
            }

            // Charitable Causes Section
            Section {
                TextField("Charitable Causes Supported", text: $bioData.charitableCauses, axis: .vertical)
                    .lineLimit(3, reservesSpace: false)
            } header: {
                Text("Charitable Causes")
            } footer: {
                Text("Organizations, causes, or volunteer work you support")
            }

            // Life Philosophy Section
            Section {
                TextField("Life Philosophy", text: $bioData.lifePhilosophy, axis: .vertical)
                    .lineLimit(5, reservesSpace: false)
            } header: {
                Text("Life Philosophy")
            } footer: {
                Text("Your personal philosophy, mantras, or guiding beliefs")
            }
        }
        .navigationTitle("Beliefs & Values")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Financial Assets View
struct FinancialAssetsView: View {
    @State private var bioData = BioData.shared

    var body: some View {
        Form {
            // Investment Interests Section
            Section {
                TextField("Investment Interests", text: $bioData.investmentInterests, axis: .vertical)
                    .lineLimit(3, reservesSpace: false)
            } header: {
                Text("Investments")
            } footer: {
                Text("Include stocks, crypto, real estate, or other investment interests")
            }

            // Major Possessions Section
            Section {
                TextField("Major Possessions", text: $bioData.majorPossessions, axis: .vertical)
                    .lineLimit(3, reservesSpace: false)
            } header: {
                Text("Assets")
            } footer: {
                Text("List vehicles, property, or other significant possessions")
            }

            // Financial Goals Section
            Section {
                TextField("Financial Goals", text: $bioData.financialGoals, axis: .vertical)
                    .lineLimit(4, reservesSpace: false)
            } header: {
                Text("Goals")
            } footer: {
                Text("Short-term and long-term financial objectives")
            }

            // Retirement Planning Section
            Section {
                TextField("Retirement Planning Notes", text: $bioData.retirementPlanning, axis: .vertical)
                    .lineLimit(4, reservesSpace: false)
            } header: {
                Text("Retirement")
            } footer: {
                Text("Your retirement plans, timeline, and considerations")
            }
        }
        .navigationTitle("Financial & Assets")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Digital Life View
struct DigitalLifeView: View {
    @State private var bioData = BioData.shared

    private func openURL(_ urlString: String) {
        guard !urlString.isEmpty else { return }

        // Add https:// if no protocol is specified
        var fullURL = urlString
        if !urlString.lowercased().hasPrefix("http://") && !urlString.lowercased().hasPrefix("https://") {
            fullURL = "https://\(urlString)"
        }

        if let url = URL(string: fullURL) {
            UIApplication.shared.open(url)
        }
    }

    var body: some View {
        Form {
            // Personal Websites Section
            Section {
                HStack {
                    TextField("Personal Website URL", text: $bioData.personalWebsite)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)

                    if !bioData.personalWebsite.isEmpty {
                        Button(action: { openURL(bioData.personalWebsite) }) {
                            Image(systemName: "arrow.up.forward.app")
                                .foregroundStyle(Color(hex: "44C0FF"))
                        }
                    }
                }

                HStack {
                    TextField("Blog URL", text: $bioData.blog)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)

                    if !bioData.blog.isEmpty {
                        Button(action: { openURL(bioData.blog) }) {
                            Image(systemName: "arrow.up.forward.app")
                                .foregroundStyle(Color(hex: "44C0FF"))
                        }
                    }
                }
            } header: {
                Text("Websites")
            } footer: {
                Text("Enter complete URLs (e.g., https://example.com)")
            }

            // Social Media Section
            Section {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        TextField("@username", text: $bioData.twitter)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(true)

                        if !bioData.twitter.isEmpty {
                            Button(action: {
                                let handle = bioData.twitter.replacingOccurrences(of: "@", with: "")
                                openURL("https://twitter.com/\(handle)")
                            }) {
                                Image(systemName: "arrow.up.forward.app")
                                    .foregroundStyle(Color(hex: "44C0FF"))
                            }
                        }
                    }
                    if !bioData.twitter.isEmpty {
                        Text("twitter.com/\(bioData.twitter.replacingOccurrences(of: "@", with: ""))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        TextField("Instagram handle", text: $bioData.instagram)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(true)

                        if !bioData.instagram.isEmpty {
                            Button(action: {
                                let handle = bioData.instagram.replacingOccurrences(of: "@", with: "")
                                openURL("https://instagram.com/\(handle)")
                            }) {
                                Image(systemName: "arrow.up.forward.app")
                                    .foregroundStyle(Color(hex: "44C0FF"))
                            }
                        }
                    }
                    if !bioData.instagram.isEmpty {
                        Text("instagram.com/\(bioData.instagram.replacingOccurrences(of: "@", with: ""))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        TextField("Facebook username", text: $bioData.facebook)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(true)

                        if !bioData.facebook.isEmpty {
                            Button(action: {
                                openURL("https://facebook.com/\(bioData.facebook)")
                            }) {
                                Image(systemName: "arrow.up.forward.app")
                                    .foregroundStyle(Color(hex: "44C0FF"))
                            }
                        }
                    }
                    if !bioData.facebook.isEmpty {
                        Text("facebook.com/\(bioData.facebook)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        TextField("LinkedIn username", text: $bioData.linkedin)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(true)

                        if !bioData.linkedin.isEmpty {
                            Button(action: {
                                openURL("https://linkedin.com/in/\(bioData.linkedin)")
                            }) {
                                Image(systemName: "arrow.up.forward.app")
                                    .foregroundStyle(Color(hex: "44C0FF"))
                            }
                        }
                    }
                    if !bioData.linkedin.isEmpty {
                        Text("linkedin.com/in/\(bioData.linkedin)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        TextField("GitHub username", text: $bioData.github)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(true)

                        if !bioData.github.isEmpty {
                            Button(action: {
                                openURL("https://github.com/\(bioData.github)")
                            }) {
                                Image(systemName: "arrow.up.forward.app")
                                    .foregroundStyle(Color(hex: "44C0FF"))
                            }
                        }
                    }
                    if !bioData.github.isEmpty {
                        Text("github.com/\(bioData.github)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        TextField("@channelname", text: $bioData.youtube)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(true)

                        if !bioData.youtube.isEmpty {
                            Button(action: {
                                let handle = bioData.youtube.replacingOccurrences(of: "@", with: "")
                                openURL("https://youtube.com/@\(handle)")
                            }) {
                                Image(systemName: "arrow.up.forward.app")
                                    .foregroundStyle(Color(hex: "44C0FF"))
                            }
                        }
                    }
                    if !bioData.youtube.isEmpty {
                        Text("youtube.com/\(bioData.youtube.hasPrefix("@") ? bioData.youtube : "@\(bioData.youtube)")")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        TextField("@username", text: $bioData.tiktok)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(true)

                        if !bioData.tiktok.isEmpty {
                            Button(action: {
                                let handle = bioData.tiktok.replacingOccurrences(of: "@", with: "")
                                openURL("https://tiktok.com/@\(handle)")
                            }) {
                                Image(systemName: "arrow.up.forward.app")
                                    .foregroundStyle(Color(hex: "44C0FF"))
                            }
                        }
                    }
                    if !bioData.tiktok.isEmpty {
                        Text("tiktok.com/@\(bioData.tiktok.replacingOccurrences(of: "@", with: ""))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        TextField("@user@instance.social", text: $bioData.mastodon)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(true)

                        if !bioData.mastodon.isEmpty {
                            Button(action: {
                                // Handle Mastodon's user@instance format
                                if bioData.mastodon.contains("@") && bioData.mastodon.split(separator: "@").count >= 2 {
                                    let parts = bioData.mastodon.split(separator: "@")
                                    let user = parts[0]
                                    let instance = parts[1]
                                    openURL("https://\(instance)/@\(user)")
                                } else {
                                    openURL("https://mastodon.social/@\(bioData.mastodon)")
                                }
                            }) {
                                Image(systemName: "arrow.up.forward.app")
                                    .foregroundStyle(Color(hex: "44C0FF"))
                            }
                        }
                    }
                    if !bioData.mastodon.isEmpty {
                        if bioData.mastodon.contains("@") && bioData.mastodon.split(separator: "@").count >= 2 {
                            let parts = bioData.mastodon.split(separator: "@")
                            Text("\(parts[1])/@\(parts[0])")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        } else {
                            Text("mastodon.social/@\(bioData.mastodon)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        TextField("@username", text: $bioData.threads)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(true)

                        if !bioData.threads.isEmpty {
                            Button(action: {
                                let handle = bioData.threads.replacingOccurrences(of: "@", with: "")
                                openURL("https://threads.net/@\(handle)")
                            }) {
                                Image(systemName: "arrow.up.forward.app")
                                    .foregroundStyle(Color(hex: "44C0FF"))
                            }
                        }
                    }
                    if !bioData.threads.isEmpty {
                        Text("threads.net/@\(bioData.threads.replacingOccurrences(of: "@", with: ""))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                TextField("Other Social Media URLs", text: $bioData.otherSocialMedia, axis: .vertical)
                    .keyboardType(.URL)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .lineLimit(2, reservesSpace: false)
            } header: {
                Text("Social Media")
            } footer: {
                Text("Enter your username or handle for each platform")
            }
        }
        .navigationTitle("Digital Life")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Preferences And Tastes View
struct PreferencesAndTastesView: View {
    @State private var bioData = BioData.shared

    let dietTypes = ["Omnivore", "Vegetarian", "Vegan", "Pescatarian", "Keto", "Paleo", "Gluten-Free", "Other"]

    var body: some View {
        Form {
            // Media Favorites Section
            Section {
                TextField("Favorite Books", text: $bioData.favoriteBooks, axis: .vertical)
                    .lineLimit(2, reservesSpace: false)

                TextField("Favorite Films", text: $bioData.favoriteFilms, axis: .vertical)
                    .lineLimit(2, reservesSpace: false)

                TextField("Favorite TV Shows", text: $bioData.favoriteTVShows, axis: .vertical)
                    .lineLimit(2, reservesSpace: false)

                TextField("Favorite Music", text: $bioData.favoriteMusic, axis: .vertical)
                    .lineLimit(2, reservesSpace: false)
            } header: {
                Text("Media Favorites")
            } footer: {
                Text("Enter your favorites separated by commas")
            }

            // Food & Diet Section
            Section {
                Picker("Diet Type", selection: $bioData.dietType) {
                    Text("Select diet type").tag("")
                    ForEach(dietTypes, id: \.self) { diet in
                        Text(diet).tag(diet)
                    }
                }

                TextField("Food Dislikes", text: $bioData.foodDislikes, axis: .vertical)
                    .lineLimit(2, reservesSpace: false)

                TextField("Allergens", text: $bioData.foodAllergens, axis: .vertical)
                    .lineLimit(2, reservesSpace: false)

                TextField("Favorite Foods", text: $bioData.favoriteFoods, axis: .vertical)
                    .lineLimit(2, reservesSpace: false)
            } header: {
                Text("Food & Diet")
            } footer: {
                Text("Include any dietary restrictions, preferences, or favorite cuisines, separated by commas")
            }

            // Hobbies Section
            Section {
                TextField("Creative Hobbies", text: $bioData.creativeHobbies, axis: .vertical)
                    .lineLimit(2, reservesSpace: false)

                TextField("Outdoor Activities", text: $bioData.outdoorActivities, axis: .vertical)
                    .lineLimit(2, reservesSpace: false)

                TextField("Collections", text: $bioData.collections, axis: .vertical)
                    .lineLimit(2, reservesSpace: false)

                TextField("Skills You're Learning", text: $bioData.skillsLearning, axis: .vertical)
                    .lineLimit(2, reservesSpace: false)
            } header: {
                Text("Hobbies")
            } footer: {
                Text("Include creative pursuits, outdoor activities, collections, and skills you're developing")
            }

            // Interests & Activities Section
            Section {
                TextField("Sports Teams", text: $bioData.sportsTeams, axis: .vertical)
                    .lineLimit(2, reservesSpace: false)

                TextField("General Interests", text: $bioData.hobbiesInterests, axis: .vertical)
                    .lineLimit(3, reservesSpace: false)

                TextField("Gear & Equipment", text: $bioData.gear, axis: .vertical)
                    .lineLimit(2, reservesSpace: false)
            } header: {
                Text("Sports & Gear")
            } footer: {
                Text("Include sports you follow and any special gear you own (bikes, cameras, instruments, etc.), comma separated")
            }
        }
        .navigationTitle("Preferences & Tastes")
        .navigationBarTitleDisplayMode(.inline)
    }
}

