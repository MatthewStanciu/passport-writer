//
//  ContentView.swift
//  Passport Writer
//
//  Created by Matthew Stanciu on 2/24/24.
//

import SwiftUI

class PassportViewModel: ObservableObject {
    @Published var passports = [Passport]()
    
    func load() {
        fetchData { [weak self] data in
            DispatchQueue.main.async {
                self?.passports = data ?? []
            }
        }
    }
}

struct PassportRowView: View {
    var passport: Passport

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("\(passport.name) \(passport.surname)")
                .foregroundColor(.primary)
                .font(.headline)
            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Image(systemName: "person.text.rectangle.fill")
                    Text(String(passport.id))
                }
                StatusView(activated: passport.activated, size: 12)
            }
            .foregroundColor(.secondary)
            .font(.subheadline)
        }
    }
}

struct FilterButtonView: View {
    let icon: String
    let label: String
    
    @State private var selected = false
    
    @State private var statusOptions = ["None", "Activated", "Not Activated"]
    @State private var statusFilter = "None"
    
    var body: some View {
//        Button(action: {
//            selected = !selected
//        }) {
//            HStack {
//                Image(systemName: icon)
//                Text(label)
//            }
//            .padding([.horizontal], 8)
//            .padding([.vertical], 6)
//        }
//        .background(Color.secondary)
//        .foregroundColor(.black)
//        .cornerRadius(8)
        Picker("Select a paint color", selection: $statusFilter) {
            ForEach(statusOptions, id: \.self) {
                Text($0)
            }
        }
        .pickerStyle(.menu)
                .background(Color.secondary)
                .foregroundColor(.black)
                .cornerRadius(8)
    }
}

struct SkeletonView: View {
    var body: some View {
        List {
            ForEach(1...11, id: \.self) { i in
                VStack(alignment: .leading, spacing: 3) {
                    Text("Loading").font(.headline)
                    Text("Loading longer").font(.headline)
                }
            }
        }.redacted(reason: .placeholder)
            .navigationTitle("Passports")
    }
}

struct PassportListView: View {
    @StateObject private var viewModel = PassportViewModel()
    
    @State private var searchText: String = ""
    
    var filteredPassports: [Passport] {
        if searchText.isEmpty {
            return viewModel.passports
        } else {
            return viewModel.passports.filter { passport in
                passport.name.lowercased().contains(searchText.lowercased()) ||
                passport.surname.lowercased().contains(searchText.lowercased()) ||
                "\(passport.id)".contains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            if viewModel.passports == [] {
                SkeletonView()
            } else {
                HStack {
                    FilterButtonView(icon: "bolt.fill", label: "Status")
                    FilterButtonView(icon: "calendar", label: "Before")
                    FilterButtonView(icon: "calendar", label: "After")
                }
                List {
                    ForEach(filteredPassports) { passport in
                        NavigationLink {
                            PassportDetailView(passport: passport, viewModel: viewModel)
                                .navigationBarTitleDisplayMode(.inline)
                        } label: {
                            PassportRowView(passport: passport)
                        }
                    }
                }
                .refreshable {
                    viewModel.load()
                }
                .navigationTitle("Passports")
            }
        }.onAppear {
            viewModel.load()
        }
        .searchable(text: $searchText)
        .autocorrectionDisabled(true)
    }
}

#Preview {
    PassportListView()
}
