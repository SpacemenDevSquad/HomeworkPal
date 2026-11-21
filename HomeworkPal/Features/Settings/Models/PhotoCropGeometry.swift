import CoreGraphics

/// The math behind the circle cropper: how big the photo is drawn, and how far it may be dragged.
///
/// The photo always covers the crop circle's square, so the saved picture never has empty edges.
struct PhotoCropGeometry: Equatable {
    static let minimumZoom: CGFloat = 1
    static let maximumZoom: CGFloat = 4

    let imageSize: CGSize
    /// The width and height of the square the crop circle sits in.
    let cropDiameter: CGFloat

    /// The photo's size at 1× zoom: just large enough to cover the square, keeping its proportions.
    var fillSize: CGSize {
        guard imageSize.width > 0, imageSize.height > 0 else {
            return CGSize(width: cropDiameter, height: cropDiameter)
        }
        let scale = max(cropDiameter / imageSize.width, cropDiameter / imageSize.height)
        return CGSize(width: imageSize.width * scale, height: imageSize.height * scale)
    }

    func clampedZoom(_ zoom: CGFloat) -> CGFloat {
        min(max(zoom, Self.minimumZoom), Self.maximumZoom)
    }

    /// Limits a drag so no edge of the zoomed photo moves inside the square.
    func clampedOffset(_ offset: CGSize, zoom: CGFloat) -> CGSize {
        let zoom = clampedZoom(zoom)
        let maxX = max(0, (fillSize.width * zoom - cropDiameter) / 2)
        let maxY = max(0, (fillSize.height * zoom - cropDiameter) / 2)
        return CGSize(
            width: min(max(offset.width, -maxX), maxX),
            height: min(max(offset.height, -maxY), maxY)
        )
    }
}
