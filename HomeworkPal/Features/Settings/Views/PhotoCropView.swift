import SwiftUI
import UIKit

/// Lets the student drag and pinch a photo inside a circle matching their profile, then saves that square.
struct PhotoCropView: View {
    private static let cropDiameter: CGFloat = 280
    /// The saved photo's width and height in pixels. Large enough to look sharp, small enough to sync quickly.
    private static let outputPixelSize: CGFloat = 512
    private static let jpegQuality: CGFloat = 0.8
    /// How much the parts of the photo outside the circle are faded.
    private static let outsideCircleOpacity = 0.7
    private static let ringLineWidth: CGFloat = 3
    private static let ringDash: [CGFloat] = [8, 6]

    let image: UIImage
    /// Called with the cropped photo as JPEG data.
    let onUsePhoto: (Data) -> Void

    @State private var zoom: CGFloat = 1
    @State private var offset: CGSize = .zero
    /// Where the zoom and offset stood when the current gesture began.
    @State private var zoomAtGestureStart: CGFloat = 1
    @State private var offsetAtGestureStart: CGSize = .zero
    @State private var isShowingRenderError = false

    private var geometry: PhotoCropGeometry {
        PhotoCropGeometry(imageSize: image.size, cropDiameter: Self.cropDiameter)
    }

    var body: some View {
        VStack(spacing: 24) {
            Text("Drag to move and pinch to zoom.")
                .foregroundStyle(Theme.secondaryText)

            croppedPhoto
                .overlay {
                    // Fades the corners outside the circle, since only the circle shows on the profile.
                    CircleCutout()
                        .fill(Theme.background.opacity(Self.outsideCircleOpacity), style: FillStyle(eoFill: true))
                }
                .overlay {
                    Circle()
                        .stroke(Theme.accent, style: StrokeStyle(lineWidth: Self.ringLineWidth, lineCap: .round, dash: Self.ringDash))
                }
                .contentShape(.rect)
                .gesture(dragGesture.simultaneously(with: zoomGesture))
                .accessibilityLabel(Text("Photo preview"))

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Theme.background)
        .navigationTitle("Crop Photo")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(action: usePhoto) {
                    Text("Use Photo")
                        .foregroundStyle(Theme.primaryText)
                }
                .buttonStyle(.glassProminent)
                .tint(Theme.accent)
            }
        }
        .alert("Something Went Wrong", isPresented: $isShowingRenderError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("The photo couldn't be cropped. Please try again.")
        }
    }

    /// The square that gets saved. Shown on screen and rendered for saving from the same view, so the
    /// saved photo matches exactly what the student lined up.
    private var croppedPhoto: some View {
        Image(uiImage: image)
            .resizable()
            .frame(width: geometry.fillSize.width, height: geometry.fillSize.height)
            .scaleEffect(zoom)
            .offset(offset)
            .frame(width: Self.cropDiameter, height: Self.cropDiameter)
            .clipped()
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                let proposed = CGSize(
                    width: offsetAtGestureStart.width + value.translation.width,
                    height: offsetAtGestureStart.height + value.translation.height
                )
                offset = geometry.clampedOffset(proposed, zoom: zoom)
            }
            .onEnded { _ in
                offsetAtGestureStart = offset
            }
    }

    private var zoomGesture: some Gesture {
        MagnifyGesture()
            .onChanged { value in
                zoom = geometry.clampedZoom(zoomAtGestureStart * value.magnification)
                // Zooming out can leave an edge inside the circle, so the photo is pulled back to cover it.
                offset = geometry.clampedOffset(offset, zoom: zoom)
            }
            .onEnded { _ in
                zoomAtGestureStart = zoom
                offsetAtGestureStart = offset
            }
    }

    private func usePhoto() {
        let renderer = ImageRenderer(content: croppedPhoto)
        renderer.scale = Self.outputPixelSize / Self.cropDiameter
        guard let data = renderer.uiImage?.jpegData(compressionQuality: Self.jpegQuality) else {
            isShowingRenderError = true
            return
        }
        onUsePhoto(data)
    }
}

/// A square with a circular hole, filled with the even-odd rule so only the corners are painted.
private nonisolated struct CircleCutout: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path(rect)
        path.addEllipse(in: rect)
        return path
    }
}

#Preview {
    NavigationStack {
        PhotoCropView(image: UIImage(systemName: "person.crop.square.fill") ?? UIImage()) { _ in }
    }
}
