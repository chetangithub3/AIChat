//
//  ProfileView.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 8/6/25.
//
import SwiftUI

struct ProfileView: View {
    @State var showSettingsView: Bool = false
    @State var showCreateAvatarView: Bool = false
    @State var myAvatars: [AvatarModel] = []
    var userProfile: UserModel = .mock
    @State var isLoading = true
    var body: some View {
        NavigationStack {
            List {
                myInfoSection
                    .padding(20)
                myAvatarsSection
            }
                .navigationTitle("Profile")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        settingsButton
                    }
                }
        }
        .sheet(isPresented: $showSettingsView, content: {
            SettingsView()
        })
        .fullScreenCover(isPresented: $showCreateAvatarView) {
            Text("Create Avatar")
        }
        .task {
            await loadData()
        }
    }
    private func loadData() async {
        isLoading = true
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        isLoading = false
        myAvatars = AvatarModel.mocks
    }
    @ViewBuilder
    private var myAvatarsSection: some View {
        Section {
            if myAvatars.isEmpty {
                Group {
                    if isLoading {
                        ProgressView()
                    } else {
                        Text("Click + to create an avatar")
                    }
                }
                .padding(.vertical, 50)
                .frame(maxWidth: .infinity)
                .foregroundStyle(.secondary)
                .removeListRowFormatting()
            } else {
                ForEach(myAvatars, id: \.self) { avatar in
                    CustomListCellView(imageURL: avatar.profileImageName, title: avatar.name)
                        .anyButton(.highlight) {
                                //
                        }
                }
                .onDelete { index in
                    onDelete(at: index)
                }
            }
        } header: {
            HStack {
                Text("My avatars")
                Spacer()
                Image(systemName: "plus.circle.fill")
                    .scaleEffect(1.2)
                    .foregroundStyle(.accent)
                    .anyButton(action: onNewAvatarButtonPressed)
            }
        }
    }
    private var myInfoSection: some View {
        Section {
            Circle()
                .frame(width: 100, height: 100)
                .foregroundStyle(userProfile.colorCalculated)
                .frame(maxWidth: .infinity)
        }
        .removeListRowFormatting()
    }
    private var settingsButton: some View {
        Image(systemName: "gear")
            .font(.title)
            .anyButton(action: onSettingsButtonPressed)
    }
    private func onDelete(at offsets: IndexSet) {
        guard let index = offsets.first else { return }
        myAvatars.remove(at: index)
    }
    private func onSettingsButtonPressed() {
        showSettingsView.toggle()
    }
    private func onNewAvatarButtonPressed() {
        showCreateAvatarView.toggle()
    }
}
#Preview {
    ProfileView()
        .environment(AppState())
}
