import PhotosUI
import SwiftData
import SwiftUI

/// A photo waiting to be named and saved.
struct CapturedPhoto: Identifiable {
    let id = UUID()
    let image: UIImage
}

/// The result of a successful catch, shown on the celebration screen.
struct CatchResult: Identifiable {
    let id = UUID()
    let creature: Creature
    let newBadges: [Badge]
}

struct CatchView: View {
    var onFinished: () -> Void

    @State private var showingCamera = false
    @State private var showingNoCameraAlert = false
    @State private var pendingCameraPhoto: UIImage?
    @State private var libraryItem: PhotosPickerItem?
    @State private var photoToName: CapturedPhoto?
    @State private var catchResult: CatchResult?

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                Text("🔍")
                    .font(.system(size: 96))

                VStack(spacing: 8) {
                    Text("Go on a Creature Hunt!")
                        .font(.largeTitle.bold())
                    Text("Find an animal or a bug, snap a photo, and add it to your collection.")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                .multilineTextAlignment(.center)

                Spacer()

                Button(action: openCamera) {
                    Label("Take a Photo", systemImage: "camera.fill")
                        .font(.title2.bold())
                        .frame(maxWidth: .infinity, minHeight: 64)
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)

                PhotosPicker(selection: $libraryItem, matching: .images) {
                    Label("Choose from Photos", systemImage: "photo.on.rectangle")
                        .font(.title3.weight(.semibold))
                        .frame(maxWidth: .infinity, minHeight: 52)
                }
                .buttonStyle(.bordered)
                .buttonBorderShape(.capsule)

                Label("Look, don't touch! Stay a safe distance from wild animals.", systemImage: "hand.raised.fill")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(24)
            .navigationTitle("Catch")
            .navigationBarTitleDisplayMode(.inline)
        }
        .fullScreenCover(isPresented: $showingCamera, onDismiss: showPendingCameraPhoto) {
            CameraPicker(isPresented: $showingCamera) { image in
                pendingCameraPhoto = image
            }
            .ignoresSafeArea()
        }
        .sheet(item: $photoToName) { photo in
            NameCreatureView(photo: photo.image) { result in
                catchResult = result
            }
        }
        .onChange(of: libraryItem) { _, item in
            Task { await loadLibraryPhoto(item) }
        }
        .alert("No Camera Found", isPresented: $showingNoCameraAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("This device doesn't have a camera. Try \"Choose from Photos\" instead.")
        }
        .overlay {
            if let catchResult {
                CelebrationView(result: catchResult) {
                    self.catchResult = nil
                    onFinished()
                }
                .transition(.opacity)
            }
        }
    }

    private func openCamera() {
        if CameraPicker.isCameraAvailable {
            showingCamera = true
        } else {
            showingNoCameraAlert = true
        }
    }

    /// The naming sheet is shown only after the camera has fully closed,
    /// because SwiftUI can't present a sheet while another one is dismissing.
    private func showPendingCameraPhoto() {
        guard let image = pendingCameraPhoto else { return }
        pendingCameraPhoto = nil
        photoToName = CapturedPhoto(image: image)
    }

    @MainActor
    private func loadLibraryPhoto(_ item: PhotosPickerItem?) async {
        guard let item else { return }
        libraryItem = nil
        guard let data = try? await item.loadTransferable(type: Data.self),
              let image = UIImage(data: data)
        else { return }
        photoToName = CapturedPhoto(image: image)
    }
}

#Preview {
    CatchView(onFinished: {})
        .modelContainer(for: Creature.self, inMemory: true)
}
