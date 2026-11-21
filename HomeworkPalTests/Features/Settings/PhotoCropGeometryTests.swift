import CoreGraphics
import Testing
@testable import HomeworkPal

@MainActor
struct PhotoCropGeometryTests {
    /// A landscape photo twice as wide as it is tall.
    private let geometry = PhotoCropGeometry(imageSize: CGSize(width: 2000, height: 1000), cropDiameter: 200)

    @Test func photoIsScaledJustEnoughToCoverTheCircle() {
        #expect(geometry.fillSize == CGSize(width: 400, height: 200))
    }

    @Test func zoomStaysWithinLimits() {
        #expect(geometry.clampedZoom(0.5) == PhotoCropGeometry.minimumZoom)
        #expect(geometry.clampedZoom(10) == PhotoCropGeometry.maximumZoom)
        #expect(geometry.clampedZoom(2) == 2)
    }

    @Test func dragStopsBeforeAnEdgeEntersTheCircle() {
        // At 1×, the photo is 200 wider than the circle, so it can slide 100 each way, and not at all vertically.
        let clamped = geometry.clampedOffset(CGSize(width: 500, height: -80), zoom: 1)

        #expect(clamped == CGSize(width: 100, height: 0))
    }

    @Test func zoomingInAllowsMoreMovement() {
        let clamped = geometry.clampedOffset(CGSize(width: 500, height: 500), zoom: 2)

        #expect(clamped == CGSize(width: 300, height: 100))
    }
}
